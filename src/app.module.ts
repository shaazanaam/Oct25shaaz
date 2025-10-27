import { Module } from '@nestjs/common';                                //The@Module decorator from NestJS
import { ConfigModule } from '@nestjs/config';                          // For loading the .env variables
import { AppController } from './controllers/app.controller';           // Your main controller
import { UsersController } from './controllers/users.controller';
import {PrismaService} from './services/prisma.service';
import { UsersService } from './services/users.service';




@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
  ],
  controllers: [AppController, UsersController],
  providers: [PrismaService, UsersService],
})
export class AppModule {}