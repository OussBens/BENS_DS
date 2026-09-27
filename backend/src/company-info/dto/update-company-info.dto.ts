import { IsOptional, IsString } from 'class-validator';

export class UpdateCompanyInfoDto {
  @IsOptional()
  @IsString()
  telephone?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  adresse?: string;

  @IsOptional()
  @IsString()
  horraire?: string;
}
