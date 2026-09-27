import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ProjectsModule } from './projects/projects.module';
import { ServicesModule } from './services/services.module';
import { TestimonialsModule } from './testimonials/testimonials.module';
import { ContactMessagesModule } from './contact-messages/contact-messages.module';
import { UploadsModule } from './uploads/uploads.module';
import { CompanyInfoModule } from './company-info/company-info.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsersModule,
    ProjectsModule,
    ServicesModule,
    TestimonialsModule,
    ContactMessagesModule,
    UploadsModule,
    CompanyInfoModule,
  ],
})
export class AppModule {}
