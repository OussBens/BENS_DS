import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateContactMessageDto } from './dto/create-contact-message.dto';
import { UpdateContactMessageDto } from './dto/update-contact-message.dto';
import { MessageStatus } from '@prisma/client';

@Injectable()
export class ContactMessagesService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateContactMessageDto) {
    return this.prisma.contactMessage.create({ data: dto });
  }

  async findAll() {
    return this.prisma.contactMessage.findMany({ orderBy: { createdAt: 'desc' } });
  }

  async findOne(id: number) {
    const message = await this.prisma.contactMessage.findUnique({ where: { id } });
    if (!message) throw new NotFoundException('Message not found');
    return message;
  }

  async update(id: number, dto: UpdateContactMessageDto) {
    await this.findOne(id);
    return this.prisma.contactMessage.update({
      where: { id },
      data: {
        ...dto,
        respondedAt: dto.status === MessageStatus.RESPONDED ? new Date() : undefined,
      },
    });
  }

  async remove(id: number) {
    await this.findOne(id);
    return this.prisma.contactMessage.delete({ where: { id } });
  }
}
