import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsOptional,
  IsObject,
} from "class-validator";
import { ApiProperty } from "@nestjs/swagger";
import { MessageRole } from "@prisma/client";

export class CreateMessageDto {
  @ApiProperty({
    description: "Message role",
    enum: MessageRole,
    example: "USER",
  })
  @IsEnum(MessageRole)
  role: MessageRole;

  @ApiProperty({
    description: "Message content",
    example: "How do I reset my password?",
  })
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiProperty({
    description: "Optional metadata (tool calls, feedback, etc.)",
    required: false,
    example: { toolCalls: [], feedback: "positive" },
  })
  @IsObject()
  @IsOptional()
  metadata?: object;
}
