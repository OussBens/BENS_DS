import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  ['uploads/images', 'uploads/videos'].forEach((dir) => {
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  });

  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.enableCors({
    origin: true,
    credentials: true,
  });

  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.setGlobalPrefix('api');
  app.useStaticAssets(join(__dirname, '..', 'uploads'), { prefix: '/uploads/' });

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`Server running on http://localhost:${port}/api`);
}
bootstrap();
