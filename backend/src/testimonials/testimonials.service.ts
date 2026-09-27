import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTestimonialDto } from './dto/create-testimonial.dto';

@Injectable()
export class TestimonialsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateTestimonialDto, creePar: string) {
    return this.prisma.testimonial.create({
      data: { ...dto, date: new Date(dto.date), creePar },
    });
  }

  async findAll(includeInactive = false) {
    return this.prisma.testimonial.findMany({
      where: includeInactive ? undefined : { isActive: true },
      orderBy: { date: 'desc' },
    });
  }

  async findOne(id: number) {
    const testimonial = await this.prisma.testimonial.findUnique({ where: { id } });
    if (!testimonial) throw new NotFoundException('Testimonial not found');
    return testimonial;
  }

  async update(id: number, dto: Partial<CreateTestimonialDto>, modifiePar: string) {
    await this.findOne(id);
    return this.prisma.testimonial.update({
      where: { id },
      data: {
        ...dto,
        date: dto.date ? new Date(dto.date) : undefined,
        modifiePar,
        modifieLe: new Date(),
      },
    });
  }

  async remove(id: number) {
    await this.findOne(id);
    return this.prisma.testimonial.delete({ where: { id } });
  }
}
