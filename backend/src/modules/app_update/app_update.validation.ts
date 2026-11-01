import { z } from "zod";

export const getAppUpdateQuerySchema = z.object({
  platform: z.string().optional().default("android"),
  version_code: z.coerce.number().int().positive().optional(),
  versionCode: z.coerce.number().int().positive().optional(),
  current_version_code: z.coerce.number().int().positive().optional(),
});

export const createAppUpdateSchema = z.object({
  platform: z.string().optional().default("android"),
  
  // Accepts either snake_case or camelCase
  version_name: z.string().min(1, "version_name is required").optional(),
  versionName: z.string().min(1, "versionName is required").optional(),

  version_code: z.coerce.number().int().positive("version_code must be a positive integer").optional(),
  versionCode: z.coerce.number().int().positive("versionCode must be a positive integer").optional(),

  minimum_version_code: z.coerce.number().int().positive().optional(),
  minimumVersionCode: z.coerce.number().int().positive().optional(),

  download_url: z.string().url("Valid download_url is required").optional(),
  downloadUrl: z.string().url("Valid downloadUrl is required").optional(),

  release_notes: z.union([z.string(), z.array(z.string())]).optional(),
  releaseNotes: z.union([z.string(), z.array(z.string())]).optional(),

  force_update: z.boolean().optional(),
  forceUpdate: z.boolean().optional(),

  is_active: z.boolean().optional(),
  isActive: z.boolean().optional(),
}).refine(
  (data) => data.version_name || data.versionName,
  { message: "version_name (or versionName) is required", path: ["version_name"] }
).refine(
  (data) => data.version_code || data.versionCode,
  { message: "version_code (or versionCode) is required", path: ["version_code"] }
).refine(
  (data) => data.download_url || data.downloadUrl,
  { message: "download_url (or downloadUrl) is required", path: ["download_url"] }
);

export type CreateAppUpdateInput = z.infer<typeof createAppUpdateSchema>;
export type GetAppUpdateQuery = z.infer<typeof getAppUpdateQuerySchema>;

