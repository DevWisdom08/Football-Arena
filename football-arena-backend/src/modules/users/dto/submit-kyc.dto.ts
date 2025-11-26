import { IsString, IsDateString } from 'class-validator';

export class SubmitKycDto {
  @IsString()
  fullName: string;

  @IsDateString()
  dateOfBirth: string;

  @IsString()
  idNumber: string;

  @IsString()
  idPhotoUrl: string; // URL to uploaded ID photo

  @IsString()
  selfieUrl: string; // URL to uploaded selfie
}

