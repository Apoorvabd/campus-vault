import { z } from "zod";

const resourceTypeEnum = z.enum([
  "PYQ",
  "NOTES",
  "SYLLABUS",
  "BOOK",
  "ASSIGNMENT",
  "LAB_MANUAL",
  "OTHER",
]);

const statusEnum = z.enum(["PENDING", "APPROVED", "REJECTED"]);

const sourceTypeEnum = z.enum(["HOSTED", "EXTERNAL_LINK", "REFERENCE_ONLY"]);

export const createResourceSchema = z
  .object({
    title: z.string().min(1, "Title is required"),
    description: z.string().optional(),
    resourceType: resourceTypeEnum,
    subjectId: z.string().min(1, "Subject is required"),
    sourceType: sourceTypeEnum,
    externalUrl: z.string().url("Invalid URL").optional(),
  })
  .superRefine((data, ctx) => {
    // XOR rule: EXTERNAL_LINK needs externalUrl, HOSTED/REFERENCE_ONLY must not have it
    // (HOSTED gets its file from multer/req.file, not from the JSON body)
    if (data.sourceType === "EXTERNAL_LINK" && !data.externalUrl) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "externalUrl is required when sourceType is EXTERNAL_LINK",
        path: ["externalUrl"],
      });
    }
    if (data.sourceType !== "EXTERNAL_LINK" && data.externalUrl) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "externalUrl should only be provided when sourceType is EXTERNAL_LINK",
        path: ["externalUrl"],
      });
    }
  });

export const rejectResourceSchema = z.object({
  rejectionReason: z.string().min(1, "Rejection reason is required"),
});

export const listResourcesQuerySchema = z.object({
  subjectId: z.string().min(1).optional(),
  courseId: z.string().min(1).optional(),
  semester: z.coerce.number().int().min(1).max(12).optional(),
  resourceType: resourceTypeEnum.optional(),
  status: statusEnum.optional(),
  search: z.string().trim().max(100).optional(),
  sort: z.enum(["recent", "downloads"]).default("recent"),
  // "true" = only my own uploads (any status). z.coerce.boolean() would treat "false" as true.
  mine: z
    .enum(["true", "false"])
    .transform((value) => value === "true")
    .optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const resourceIdParamsSchema = z.object({
  id: z.string().min(1, "Resource ID is required"),
});

export type ListResourcesQuery = z.infer<typeof listResourcesQuerySchema>;
