import {
  Injectable,
  NotFoundException,
  ConflictException,
} from "@nestjs/common";
import { PrismaService } from "../services/prisma.service";
import { CreateAgentDto } from "./dto/create-agent.dto";
import { UpdateAgentDto } from "./dto/update-agent.dto";
import { Prisma } from "@prisma/client";

@Injectable()
export class AgentsService {
  constructor(private prisma: PrismaService) {}

  async create(createAgentDto: CreateAgentDto) {
    try {
      return await this.prisma.agent.create({
        data: {
          name: createAgentDto.name,
          version: createAgentDto.version || "0.1.0",
          flowJson: createAgentDto.flowJson,
          tenantId: createAgentDto.tenantId,
          status: "DRAFT", // Default status
        },
      });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === "P2002") {
          throw new ConflictException(
            "Agent with this name already exists for this tenant"
          );
        }
      }
      throw error;
    }
  }

  async findAll(tenantId: string) {
    return await this.prisma.agent.findMany({
      where: { tenantId },
      include: {
        _count: {
          select: { conversations: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async findOne(id: string, tenantId: string) {
    const agent = await this.prisma.agent.findFirst({
      where: { id, tenantId },
      include: {
        _count: {
          select: { conversations: true },
        },
      },
    });

    if (!agent) {
      throw new NotFoundException(`Agent with ID ${id} not found`);
    }

    return agent;
  }

  async update(id: string, tenantId: string, updateAgentDto: UpdateAgentDto) {
    // First verify the agent exists and belongs to the tenant
    await this.findOne(id, tenantId);

    try {
      return await this.prisma.agent.update({
        where: { id },
        data: updateAgentDto,
      });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === "P2002") {
          throw new ConflictException(
            "Agent with this name already exists for this tenant"
          );
        }
        if (error.code === "P2025") {
          throw new NotFoundException(`Agent with ID ${id} not found`);
        }
      }
      throw error;
    }
  }

  async updateStatus(
    id: string,
    tenantId: string,
    status: "DRAFT" | "PUBLISHED" | "DISABLED"
  ) {
    // Verify the agent exists and belongs to the tenant
    await this.findOne(id, tenantId);

    return await this.prisma.agent.update({
      where: { id },
      data: { status },
    });
  }

  async remove(id: string, tenantId: string) {
    // Verify the agent exists and belongs to the tenant
    const agent = await this.findOne(id, tenantId);

    // Check if there are any conversations
    const conversationCount = await this.prisma.conversation.count({
      where: {
        agentId: id,
      },
    });

    if (conversationCount > 0) {
      throw new ConflictException(
        `Cannot delete agent with ${conversationCount} conversation(s). Please delete conversations first.`
      );
    }

    await this.prisma.agent.delete({
      where: { id },
    });

    return { message: "Agent deleted successfully", id };
  }
}
