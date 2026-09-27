import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateServiceDto } from './dto/create-service.dto';

@Injectable()
export class ServicesService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateServiceDto) {
    return this.prisma.service.create({ data: dto });
  }

  async findAll(includeUnpublished = false) {
    return this.prisma.service.findMany({
      where: includeUnpublished ? undefined : { isPublished: true },
      orderBy: [{ order: 'asc' }, { createdAt: 'desc' }],
    });
  }

  async findOne(id: number) {
    const service = await this.prisma.service.findUnique({ where: { id } });
    if (!service) throw new NotFoundException('Service not found');
    return service;
  }

  async update(id: number, dto: Partial<CreateServiceDto>) {
    await this.findOne(id);
    return this.prisma.service.update({ where: { id }, data: dto });
  }

  async remove(id: number) {
    await this.findOne(id);
    return this.prisma.service.delete({ where: { id } });
  }
}
