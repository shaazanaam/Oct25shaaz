import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';

export class UpdateAgentStatusDto {
  @ApiProperty({
    description: 'Status of the agent',
    enum: ['DRAFT', 'PUBLISHED', 'DISABLED'],
    example: 'PUBLISHED',
  })
  @IsEnum(['DRAFT', 'PUBLISHED', 'DISABLED'], {
    message: 'Status must be one of: DRAFT, PUBLISHED, DISABLED',
  })
  status: string;
}