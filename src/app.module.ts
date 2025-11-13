import { Module } from "@nestjs/common"; //The@Module decorator from NestJS
import { ConfigModule } from "@nestjs/config"; // For loading the .env variables
import { AppController } from "./controllers/app.controller"; // Your main controller
import { PrismaService } from "./services/prisma.service";
import { TenantsModule } from "./tenants/tenants.module";
import { UsersModule } from "./users/users.module";
import { AgentsModule } from "./agents/agents.module";
import { ToolsModule } from "./tools/tools.module";
import { ConversationsModule } from "./conversations/conversations.module";
import { DocumentsModule } from "./documents/documents.module";

@Module({
  imports: [
    // Other modules this module depends on
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ".env",
    }),
    TenantsModule, // ← Tenants CRUD module (Phase 3.2)
    UsersModule, // ← Users CRUD module (Phase 3.3)
    AgentsModule, // ← Agents CRUD module (Phase 4)
    ToolsModule, // ← Tools CRUD module (Phase 5)
    ConversationsModule, // ← Conversations & Messages CRUD (Phase 6)
    DocumentsModule, // ← Documents CRUD (Phase 7)
  ],
  controllers: [AppController], //HTTP route handlers
  providers: [PrismaService], // business login, service utilities and database connection
})
export class AppModule {} // services other modules want to access// think of it as what other modules borrow from me
