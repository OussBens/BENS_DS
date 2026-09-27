import { IsString, IsOptional, IsArray, IsBoolean, IsInt, IsNumber, Min } from 'class-validator';

export class CreateServiceDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsString()
  icon: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  technologies?: string[];

  @IsOptional()
  @IsNumber()
  @Min(0)
  priceFrom?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  order?: number;

  @IsOptional()
  @IsBoolean()
  isPublished?: boolean;
}
