import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../services/prisma.service";
import { CreateToolDto } from "./dto/create-tool.dto";
import { UpdateToolDto } from "./dto/update-tool.dto";
import {
  createCipheriv,
  createDecipheriv,
  randomBytes,
  scryptSync,
} from "crypto";

@Injectable()
export class ToolsService {
  private readonly ENCRYPTION_KEY: Buffer;
  private readonly ALGORITHM = "aes-256-cbc";

  constructor(private prisma: PrismaService) {
    // Derive encryption key from environment variable
    const secret =
      process.env.ENCRYPTION_SECRET || "default-secret-change-in-production";
    this.ENCRYPTION_KEY = scryptSync(secret, "salt", 32);
  }

  /**
   * Encrypt sensitive data (API keys, tokens)
   */
  private encrypt(text: string): string {
    const iv = randomBytes(16);
    const cipher = createCipheriv(this.ALGORITHM, this.ENCRYPTION_KEY, iv);
    let encrypted = cipher.update(text, "utf8", "hex");
    encrypted += cipher.final("hex");
    return iv.toString("hex") + ":" + encrypted;
  }

  /**
   * Decrypt sensitive data
   */
  private decrypt(text: string): string {
    const parts = text.split(":");
    const iv = Buffer.from(parts.shift(), "hex");
    const encryptedText = parts.join(":");
    const decipher = createDecipheriv(this.ALGORITHM, this.ENCRYPTION_KEY, iv);
    let decrypted = decipher.update(encryptedText, "hex", "utf8");
    decrypted += decipher.final("utf8");
    return decrypted;
  }

  /**
   * Encrypt sensitive fields in authConfig before storing
   */
  private encryptAuthConfig(authConfig: any): any {
    const encrypted = { ...authConfig };

    // Encrypt common sensitive fields
    const sensitiveFields = [
      "apiKey",
      "token",
      "clientSecret",
      "password",
      "privateKey",
    ];

    for (const field of sensitiveFields) {
      if (encrypted[field]) {
        encrypted[field] = this.encrypt(encrypted[field]);
      }
    }

    return encrypted;
  }

  /**
   * Decrypt sensitive fields in authConfig after retrieval
   */
  private decryptAuthConfig(authConfig: any): any {
    const decrypted = { ...authConfig };

    const sensitiveFields = [
      "apiKey",
      "token",
      "clientSecret",
      "password",
      "privateKey",
    ];

    for (const field of sensitiveFields) {
      if (decrypted[field] && typeof decrypted[field] === "string") {
        try {
          decrypted[field] = this.decrypt(decrypted[field]);
        } catch (error) {
          // If decryption fails, field might not be encrypted (backwards compatibility)
          console.warn(`Failed to decrypt ${field}, using as-is`);
        }
      }
    }

    return decrypted;
  }

  async create(createToolDto: CreateToolDto, tenantId: string) {
    try {
      // Encrypt sensitive fields in authConfig
      const encryptedAuthConfig = this.encryptAuthConfig(
        createToolDto.authConfig
      );

      const tool = await this.prisma.tool.create({
        data: {
          name: createToolDto.name,
          title: createToolDto.title,
          type: createToolDto.type,
          inputSchema: createToolDto.inputSchema,
          outputSchema: createToolDto.outputSchema,
          authType: createToolDto.authType,
          authConfig: encryptedAuthConfig,
          tenantId: tenantId,
        },
      });

      return tool;
    } catch (error) {
      if (error.code === "P2002") {
        throw new ConflictException("Tool with this name already exists");
      }
      throw error;
    }
  }

  async findAll(tenantId: string) {
    const tools = await this.prisma.tool.findMany({
      where: { tenantId },
      select: {
        id: true,
        name: true,
        title: true,
        type: true,
        inputSchema: true,
        outputSchema: true,
        authType: true,
        // Don't expose authConfig in list view for security
        createdAt: true,
        updatedAt: true,
      },
    });

    return tools;
  }

  async findOne(id: string, tenantId: string) {
    const tool = await this.prisma.tool.findUnique({
      where: { id },
    });

    if (!tool) {
      throw new NotFoundException("Tool not found");
    }

    if (tool.tenantId !== tenantId) {
      throw new NotFoundException("Tool not found");
    }

    // Decrypt authConfig for authorized access
    return {
      ...tool,
      authConfig: this.decryptAuthConfig(tool.authConfig),
    };
  }

  async update(id: string, tenantId: string, updateToolDto: UpdateToolDto) {
    // First verify ownership
    await this.findOne(id, tenantId);

    try {
      // Encrypt authConfig if being updated
      const updateData: any = { ...updateToolDto };
      if (updateToolDto.authConfig) {
        updateData.authConfig = this.encryptAuthConfig(
          updateToolDto.authConfig
        );
      }

      const tool = await this.prisma.tool.update({
        where: { id },
        data: updateData,
      });

      return {
        ...tool,
        authConfig: this.decryptAuthConfig(tool.authConfig),
      };
    } catch (error) {
      if (error.code === "P2002") {
        throw new ConflictException("Tool with this name already exists");
      }
      if (error.code === "P2025") {
        throw new NotFoundException("Tool not found");
      }
      throw error;
    }
  }

  async remove(id: string, tenantId: string) {
    // Verify ownership
    await this.findOne(id, tenantId);

    try {
      await this.prisma.tool.delete({
        where: { id },
      });

      return { message: "Tool deleted successfully" };
    } catch (error) {
      if (error.code === "P2025") {
        throw new NotFoundException("Tool not found");
      }
      throw error;
    }
  }

  /**
   * Test tool execution (placeholder for Phase 9 MCP integration)
   */
  async testTool(id: string, tenantId: string, testInput: any) {
    const tool = await this.findOne(id, tenantId);

    // TODO: Phase 9 - Actually call the MCP service here
    // For now, just validate the tool exists and return mock response

    return {
      success: true,
      message: "Tool test endpoint (will call MCP service in Phase 9)",
      toolId: tool.id,
      toolName: tool.name,
      toolType: tool.type,
      testInput: testInput,
      mockOutput: {
        status: "success",
        result: "This will be replaced with actual MCP service call in Phase 9",
      },
    };
  }
}
