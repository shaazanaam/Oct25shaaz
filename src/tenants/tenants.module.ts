import { Module } from '@nestjs/common';
import { TenantsService } from './tenants.service';
import { TenantsController } from './tenants.controller';
import { PrismaService } from '../services/prisma.service';

@Module({
  controllers: [TenantsController],
  providers: [TenantsService, PrismaService],
  exports: [TenantsService], // Export so other modules can use TenantsService
})
export class TenantsModule {}