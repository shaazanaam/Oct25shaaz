import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../services/prisma.service';
import { CreateTenantDto } from './dto/create-tenant.dto';
import { UpdateTenantDto } from './dto/update-tenant.dto';

@Injectable()
export class TenantsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create a new tenant
   * Throws ConflictException if tenant name already exists
   */
  async create(createTenantDto: CreateTenantDto) {
    try {
      return await this.prisma.tenant.create({
        data: {
          name: createTenantDto.name,
          plan: createTenantDto.plan as any || 'FREE',
        },
      });
    } catch (error) {
      // P2002 is Prisma's unique constraint violation code
      if (error.code === 'P2002') {
        throw new ConflictException(
          `Tenant with name '${createTenantDto.name}' already exists`,
        );
      }
      throw error;
    }
  }

  /**
   * Get all tenants
   * Returns array of tenants ordered by creation date
   */
  async findAll() {
    return this.prisma.tenant.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: {
            users: true,
            agents: true,
            conversations: true,
            documents: true,
          },
        },
      },
    });
  }

  /**
   * Get a single tenant by ID
   * Throws NotFoundException if tenant doesn't exist
   */
  async findOne(id: string) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            users: true,
            agents: true,
            conversations: true,
            documents: true,
          },
        },
      },
    });

    if (!tenant) {
      throw new NotFoundException(`Tenant with ID '${id}' not found`);
    }

    return tenant;
  }

  /**
   * Update a tenant's information
   * Throws NotFoundException if tenant doesn't exist
   * Throws ConflictException if new name conflicts with existing tenant
   */
  async update(id: string, updateTenantDto: UpdateTenantDto) {
    // First check if tenant exists
    await this.findOne(id); // This will throw NotFoundException if not found

    try {
      return await this.prisma.tenant.update({
        where: { id },
        data: {
          ...(updateTenantDto.name && { name: updateTenantDto.name }),
          ...(updateTenantDto.plan && { plan: updateTenantDto.plan as any }),
        },
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException(
          `Tenant with name '${updateTenantDto.name}' already exists`,
        );
      }
      throw error;
    }
  }

  /**
   * Delete a tenant
   *   WARNING: This will CASCADE DELETE all related data:
   * - All users belonging to this tenant
   * - All agents belonging to this tenant
   * - All conversations belonging to this tenant
   * - All messages in those conversations
   * - All documents belonging to this tenant
   * 
   * Throws NotFoundException if tenant doesn't exist
   */
  async remove(id: string) {
    // First check if tenant exists
    await this.findOne(id);

    return this.prisma.tenant.delete({
      where: { id },
    });
  }
}