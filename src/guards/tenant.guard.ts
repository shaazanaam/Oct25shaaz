import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../services/prisma.service';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    // Extract tenant ID from request header
    const tenantId = request.headers['x-tenant-id'];

    // Check if header exists
    if (!tenantId) {
      throw new BadRequestException(
        'X-Tenant-Id header is required. Please provide a valid tenant identifier.',
      );
    }

    // Validate tenant exists in database
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
    });

    // Reject if tenant doesn't exist
    if (!tenant) {
      throw new ForbiddenException(
        `Tenant with ID '${tenantId}' not found or you do not have access to this tenant.`,
      );
    }

    // Attach tenant object to request for downstream use
    request.tenant = tenant;

    // Allow request to proceed
    return true;
  }
}