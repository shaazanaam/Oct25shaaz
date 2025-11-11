import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsObject, IsOptional } from 'class-validator';

export class CreateAgentDto {
  @ApiProperty({ 
    example: 'IT Support Bot',
    description: 'Name of the AI agent' 
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ 
    example: '1.0.0',
    description: 'Version of the agent',
    default: '0.1.0'
  })
  @IsString()
  @IsOptional()
  version?: string;

  @ApiProperty({ 
    example: {
      nodes: [
        { id: 'kb_search', type: 'tool' },
        { id: 'get_feedback', type: 'user_input' }
      ],
      edges: [
        { from: 'kb_search', to: 'get_feedback' }
      ]
    },
    description: 'LangGraph workflow definition as JSON' 
  })
  @IsObject()
  @IsNotEmpty()
  flowJson: object;

  @ApiProperty({ 
    example: 'clxxx123abc',
    description: 'ID of the tenant that owns this agent' 
  })
  @IsString()
  @IsNotEmpty()
  tenantId: string;
}