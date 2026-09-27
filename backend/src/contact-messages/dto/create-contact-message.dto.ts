import { IsString, IsEmail, IsOptional } from 'class-validator';

export class CreateContactMessageDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsString()
  subject: string;

  @IsString()
  message: string;
}
