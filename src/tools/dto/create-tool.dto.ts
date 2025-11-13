import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsJSON,
  IsOptional,
  IsObject,
} from "class-validator";
import { ApiProperty } from "@nestjs/swagger";
import { ToolType } from "@prisma/client";

export class CreateToolDto {
  @ApiProperty({
    description: "Tool name (unique identifier)",
    example: "zammad_ticket_creator",
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: "Human-readable title for the tool",
    example: "Zammad Ticket Creator",
  })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({
    description: "Tool type",
    enum: ToolType,
    example: "TICKET_CREATE",
  })
  @IsEnum(ToolType)
  type: ToolType;

  @ApiProperty({
    description: "JSON Schema for tool input validation",
    example: {
      type: "object",
      properties: {
        title: { type: "string" },
        description: { type: "string" },
        group: { type: "string" },
      },
      required: ["title", "description"],
    },
  })
  @IsObject()
  inputSchema: object;

  @ApiProperty({
    description: "JSON Schema for tool output validation",
    example: {
      type: "object",
      properties: {
        ticketId: { type: "string" },
        ticketUrl: { type: "string" },
      },
    },
  })
  @IsObject()
  outputSchema: object;

  @ApiProperty({
    description: "Authentication type",
    example: "api_key",
    enum: ["service_account", "oauth", "api_key"],
  })
  @IsString()
  @IsNotEmpty()
  authType: string;

  @ApiProperty({
    description: "Authentication configuration (API keys, tokens, etc.)",
    example: {
      apiUrl: "https://zammad.company.com/api/v1",
      apiKey: "your-secret-key",
      defaultGroup: "Support",
    },
  })
  @IsObject()
  authConfig: object;

  @ApiProperty({
    description: "Tenant ID (automatically set from X-Tenant-Id header)",
    required: false,
  })
  @IsString()
  @IsOptional()
  tenantId?: string;
}
