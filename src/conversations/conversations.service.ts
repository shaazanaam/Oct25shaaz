import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../services/prisma.service";
import { CreateConversationDto } from "./dto/create-conversation.dto";
import { UpdateConversationDto } from "./dto/update-conversation.dto";
import { CreateMessageDto } from "./dto/create-message.dto";

@Injectable()
export class ConversationsService {
  constructor(private prisma: PrismaService) {}

  async create(createConversationDto: CreateConversationDto, tenantId: string) {
    // Verify agent exists and belongs to tenant
    const agent = await this.prisma.agent.findUnique({
      where: { id: createConversationDto.agentId },
    });

    if (!agent) {
      throw new NotFoundException("Agent not found");
    }

    if (agent.tenantId !== tenantId) {
      throw new NotFoundException("Agent not found");
    }

    const conversation = await this.prisma.conversation.create({
      data: {
        agentId: createConversationDto.agentId,
        tenantId: tenantId,
        userId: createConversationDto.userId,
        channel: createConversationDto.channel || "web",
        state: createConversationDto.state || {},
      },
      include: {
        agent: {
          select: {
            id: true,
            name: true,
            version: true,
            status: true,
          },
        },
        _count: {
          select: { messages: true },
        },
      },
    });

    return conversation;
  }

  async findAll(tenantId: string) {
    const conversations = await this.prisma.conversation.findMany({
      where: { tenantId },
      include: {
        agent: {
          select: {
            id: true,
            name: true,
            version: true,
          },
        },
        _count: {
          select: { messages: true },
        },
      },
      orderBy: {
        updatedAt: "desc",
      },
    });

    return conversations;
  }

  async findOne(id: string, tenantId: string) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id },
      include: {
        agent: {
          select: {
            id: true,
            name: true,
            version: true,
            status: true,
          },
        },
        messages: {
          orderBy: {
            createdAt: "asc",
          },
        },
      },
    });

    if (!conversation) {
      throw new NotFoundException("Conversation not found");
    }

    if (conversation.tenantId !== tenantId) {
      throw new NotFoundException("Conversation not found");
    }

    return conversation;
  }

  async update(
    id: string,
    tenantId: string,
    updateConversationDto: UpdateConversationDto
  ) {
    // Verify ownership
    await this.findOne(id, tenantId);

    try {
      const conversation = await this.prisma.conversation.update({
        where: { id },
        data: updateConversationDto,
        include: {
          agent: {
            select: {
              id: true,
              name: true,
              version: true,
            },
          },
          _count: {
            select: { messages: true },
          },
        },
      });

      return conversation;
    } catch (error) {
      if (error.code === "P2025") {
        throw new NotFoundException("Conversation not found");
      }
      throw error;
    }
  }

  async remove(id: string, tenantId: string) {
    // Verify ownership
    await this.findOne(id, tenantId);

    try {
      await this.prisma.conversation.delete({
        where: { id },
      });

      return { message: "Conversation deleted successfully" };
    } catch (error) {
      if (error.code === "P2025") {
        throw new NotFoundException("Conversation not found");
      }
      throw error;
    }
  }

  // Message operations
  async createMessage(
    conversationId: string,
    tenantId: string,
    createMessageDto: CreateMessageDto
  ) {
    // Verify conversation exists and belongs to tenant
    await this.findOne(conversationId, tenantId);

    const message = await this.prisma.message.create({
      data: {
        convoId: conversationId,
        role: createMessageDto.role,
        content: createMessageDto.content,
        metadata: createMessageDto.metadata || {},
      },
    });

    // Update conversation's updatedAt timestamp
    await this.prisma.conversation.update({
      where: { id: conversationId },
      data: { updatedAt: new Date() },
    });

    return message;
  }

  async getMessages(conversationId: string, tenantId: string) {
    // Verify ownership
    await this.findOne(conversationId, tenantId);

    const messages = await this.prisma.message.findMany({
      where: { convoId: conversationId },
      orderBy: {
        createdAt: "asc",
      },
    });

    return messages;
  }
}
