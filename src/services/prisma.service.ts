import {Injectable,OnModuleInit} from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()   // thsi decorator tells NestJS to manage this for me 
export class PrismaService extends PrismaClient implements OnModuleInit{
    async onModuleInit(){
        await this.$connect();
    }

    async onModuleDestroy(){
        await this.$disconnect();
    }
}