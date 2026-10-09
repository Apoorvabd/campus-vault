import { z } from "zod";

export const usernameParamsSchema = z.object({
  username: z.string().trim().min(3).max(30),
});

export const updateProfileSchema = z
  .object({
    firstName: z.string().trim().min(3, "First name must be at least 3 characters").max(80).optional(),
    lastName: z.string().trim().min(3, "Last name must be at least 3 characters").max(80).nullable().optional(),
    username: z
      .string()
      .trim()
      .min(3, "Username must be at least 3 characters")
      .max(30, "Username must be at most 30 characters")
      .regex(
        /^[a-zA-Z0-9_]+$/,
        "Username can contain letters, numbers, and underscores"
      )
      .optional(),
    bio: z.string().trim().max(500).nullable().optional(),
    headline: z.string().trim().max(120).nullable().optional(),
    currentSemester: z.coerce.number().int().min(1).optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one profile field is required",
  });

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
