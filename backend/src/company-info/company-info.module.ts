import { Module } from '@nestjs/common';
import { CompanyInfoService } from './company-info.service';
import { CompanyInfoController } from './company-info.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [CompanyInfoController],
  providers: [CompanyInfoService],
})
export class CompanyInfoModule {}
