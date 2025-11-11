import { IsString, IsEnum, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateTenantDto {
  @ApiPropertyOptional({ 
    example: 'acme-corporation',
    description: 'Updated tenant name' 
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({ 
    example: 'ENTERPRISE',
    description: 'Updated subscription plan',
    enum: ['FREE', 'PRO', 'ENTERPRISE']
  })
  @IsEnum(['FREE', 'PRO', 'ENTERPRISE'])
  @IsOptional()
  plan?: string;
}