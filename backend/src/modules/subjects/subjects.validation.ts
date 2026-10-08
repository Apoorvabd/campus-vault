import { z } from "zod";

const subjectId = z.string().trim().min(1);

export const saveMySubjectsSchema = z.object({
  dsc: z.array(subjectId).min(1, "Select at least one DSC subject").max(3, "At most 3 DSC subjects"),
  ge: subjectId.nullish(),
  dse: z.array(subjectId).max(2, "At most 2 DSE subjects").default([]),
  sec: subjectId.nullish(),
  vac: subjectId.nullish(),
  aec: subjectId.nullish(),
});

export type SaveMySubjectsInput = z.infer<typeof saveMySubjectsSchema>;
