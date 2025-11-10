import { Injectable, ConflictException } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { CreateUserDto } from '../dto/create-user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      include: {
        tenant: true, // Include tenant info in response
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(createUserDto: CreateUserDto) {
    try {
      return await this.prisma.user.create({
        data: {
          email: createUserDto.email,
          name: createUserDto.name,
          tenantId: createUserDto.tenantId,
          role: createUserDto.role as any, // Cast role to UserRole enum
        },
        include: {
          tenant: true, // Return tenant info with created user
        },
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException('User with this email already exists');
      }
      throw error;
    }
  }

  async findOne(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      include: {
        tenant: true, // Include tenant info
      },
    });
  }
}