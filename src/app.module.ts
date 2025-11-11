import { Module } from '@nestjs/common';                                //The@Module decorator from NestJS
import { ConfigModule } from '@nestjs/config';                          // For loading the .env variables
import { AppController } from './controllers/app.controller';           // Your main controller
import { UsersController } from './controllers/users.controller';
import {PrismaService} from './services/prisma.service';
import { UsersService } from './services/users.service';
import { TenantsModule } from './tenants/tenants.module';




@Module({
  imports: [                      // Other modules this module depends on 
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TenantsModule, // ← Tenants CRUD module (Phase 3.2)
  ],
  controllers: [AppController, UsersController],   //HTTP route handlers
  providers: [PrismaService, UsersService],  // business login, service utilities and database connection 
})
export class AppModule {}   // services other modules want to access// think of it as what other modules borrow from me 
