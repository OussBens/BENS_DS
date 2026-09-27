-- CreateTable
CREATE TABLE "CompanyInfo" (
    "id" SERIAL NOT NULL,
    "telephone" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "adresse" TEXT NOT NULL,
    "horraire" TEXT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CompanyInfo_pkey" PRIMARY KEY ("id")
);
