import { Module } from '@nestjs/common';
import { ContactMessagesService } from './contact-messages.service';
import { ContactMessagesController } from './contact-messages.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ContactMessagesController],
  providers: [ContactMessagesService],
})
export class ContactMessagesModule {}
