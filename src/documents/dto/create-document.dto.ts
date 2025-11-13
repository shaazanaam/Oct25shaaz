import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsObject,
  IsEnum,
} from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class CreateDocumentDto {
  @ApiProperty({
    description: "Document source",
    example: "upload",
    enum: ["upload", "sharepoint", "confluence", "url"],
  })
  @IsEnum(["upload", "sharepoint", "confluence", "url"])
  source: string;

  @ApiProperty({
    description: "Document URI (file path, URL, etc.)",
    example: "s3://bucket/documents/manual.pdf",
  })
  @IsString()
  @IsNotEmpty()
  uri: string;

  @ApiProperty({
    description: "Document title",
    example: "Password Reset Manual",
  })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({
    description: "Document metadata (tags, category, etc.)",
    required: false,
    example: { tags: ["manual", "security"], category: "IT Support" },
  })
  @IsObject()
  @IsOptional()
  metadata?: object;
}
