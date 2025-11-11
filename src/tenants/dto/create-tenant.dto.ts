import { IsString, IsNotEmpty, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateTenantDto {
  @ApiProperty({ 
    example: 'acme-corp',
    description: 'Unique tenant name/identifier' 
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ 
    example: 'PRO',
    description: 'Tenant subscription plan',
    enum: ['FREE', 'PRO', 'ENTERPRISE'],
    default: 'FREE'
  })
  @IsEnum(['FREE', 'PRO', 'ENTERPRISE'])
  @IsOptional()
  plan?: string;
}