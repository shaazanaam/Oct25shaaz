import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getHello(): string {
    return 'Hello NestJS!  app is running correctly!';
  }

  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      message: 'NestJS API is running',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
    };
  }
}