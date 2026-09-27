import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateCompanyInfoDto } from './dto/update-company-info.dto';

const DEFAULTS = {
  telephone: '',
  email: '',
  adresse: '',
  horraire: '',
};

@Injectable()
export class CompanyInfoService {
  constructor(private prisma: PrismaService) {}

  async get() {
    const existing = await this.prisma.companyInfo.findFirst();
    if (existing) return existing;
    return this.prisma.companyInfo.create({ data: DEFAULTS });
  }

  async update(dto: UpdateCompanyInfoDto) {
    const existing = await this.get();
    return this.prisma.companyInfo.update({ where: { id: existing.id }, data: dto });
  }
}
