import { IsString, IsOptional, IsArray, IsBoolean, IsInt, IsDateString, Min, Max } from 'class-validator';

export class CreateTestimonialDto {
  @IsString()
  nomClient: string;

  @IsOptional()
  @IsString()
  titre?: string;

  @IsOptional()
  @IsString()
  modeleVoiture?: string;

  @IsString()
  contenu: string;

  @IsInt()
  @Min(1)
  @Max(5)
  note: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  photos?: string[];

  @IsOptional()
  @IsString()
  video?: string;

  @IsDateString()
  date: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
