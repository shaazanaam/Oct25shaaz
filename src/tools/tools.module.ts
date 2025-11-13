import { Module } from "@nestjs/common";
import { ToolsService } from "./tools.service";
import { ToolsController } from "./tools.controller";
import { PrismaService } from "../services/prisma.service";

@Module({
  controllers: [ToolsController],
  providers: [ToolsService, PrismaService],
  exports: [ToolsService],
})
export class ToolsModule {}
