import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { CompanyInfoService } from './company-info.service';
import { UpdateCompanyInfoDto } from './dto/update-company-info.dto';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@Controller('company-info')
export class CompanyInfoController {
  constructor(private companyInfoService: CompanyInfoService) {}

  @Get()
  get() {
    return this.companyInfoService.get();
  }

  @Patch()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  update(@Body() dto: UpdateCompanyInfoDto) {
    return this.companyInfoService.update(dto);
  }
}
