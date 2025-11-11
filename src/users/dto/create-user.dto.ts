import {
  IsEmail,
  IsOptional,
  IsString,
  IsNotEmpty,
  IsEnum,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateUserDto {
  @ApiProperty({
    example: "user@example.com",
    description: "User email address",
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiPropertyOptional({
    example: "John Doe",
    description: "User full name",
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({
    example: "clxxx...xxx",
    description: "Tenant ID this user belongs to",
  })
  @IsString()
  @IsNotEmpty()
  tenantId: string;

  @ApiPropertyOptional({
    example: "VIEWER",
    description: "User role",
    enum: ["ADMIN", "AUTHOR", "VIEWER"],
  })
  @IsEnum(["ADMIN", "AUTHOR", "VIEWER"])
  @IsOptional()
  role?: string;
}
