-- CreateTable
CREATE TABLE "app_updates" (
    "id" TEXT NOT NULL,
    "platform" TEXT NOT NULL DEFAULT 'android',
    "version_name" TEXT NOT NULL,
    "version_code" INTEGER NOT NULL,
    "minimum_version_code" INTEGER NOT NULL DEFAULT 1,
    "download_url" TEXT NOT NULL,
    "release_notes" TEXT,
    "force_update" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "app_updates_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "app_updates_platform_is_active_version_code_idx" ON "app_updates"("platform", "is_active", "version_code" DESC);

