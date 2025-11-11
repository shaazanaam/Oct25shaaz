import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { UsersService } from '../services/users.service';
import { CreateUserDto } from '../dto/create-user.dto';
import { TenantGuard } from '../guards/tenant.guard';

@ApiTags('users')
@Controller('users')
@UseGuards(TenantGuard)  // ← Protect all user endpoints
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all users for the current tenant' })
  @ApiResponse({ status: 200, description: 'List of all users for this tenant' })
  @ApiResponse({ status: 400, description: 'X-Tenant-Id header missing' })
  @ApiResponse({ status: 403, description: 'Invalid tenant ID' })
  async findAll(@Request() req) {
    return this.usersService.findAll(req.tenant.id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  @ApiResponse({ status: 201, description: 'User created successfully' })
  @ApiResponse({ status: 409, description: 'User with this email already exists' })
  async create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiResponse({ status: 200, description: 'User found' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }
}