import { IsEnum, IsOptional, IsString } from 'class-validator';
import { MessageStatus } from '@prisma/client';

export class UpdateContactMessageDto {
  @IsOptional()
  @IsEnum(MessageStatus)
  status?: MessageStatus;

  @IsOptional()
  @IsString()
  adminNote?: string;
}
