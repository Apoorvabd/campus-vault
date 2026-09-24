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
