import { IsString, IsNotEmpty, IsOptional, IsObject } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class CreateConversationDto {
  @ApiProperty({
    description: "Agent ID to use for this conversation",
    example: "clxxx123456789",
  })
  @IsString()
  @IsNotEmpty()
  agentId: string;

  @ApiProperty({
    description: "User ID who started the conversation (optional)",
    required: false,
    example: "clyyyy987654321",
  })
  @IsString()
  @IsOptional()
  userId?: string;

  @ApiProperty({
    description: "Channel where conversation happens",
    required: false,
    example: "web",
    enum: ["web", "slack", "teams", "api"],
  })
  @IsString()
  @IsOptional()
  channel?: string;

  @ApiProperty({
    description: "Initial conversation state (LangGraph state)",
    required: false,
    example: { step: "initial", context: {} },
  })
  @IsObject()
  @IsOptional()
  state?: object;
}
