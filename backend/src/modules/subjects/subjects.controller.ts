import { Request, Response } from "express";
import { asyncHandler, sendResponse, AppError } from "../../utils";
import { findSubjectsByCourseId } from "./subjects.repository";
import {
  getMySubjectsService,
  getSubjectsFormService,
  saveMySubjectsService,
  searchSubjectsService,
} from "./subjects.service";
import type { SaveMySubjectsInput } from "./subjects.validation";

export const getSubjects = asyncHandler(async (req: Request, res: Response) => {
  const { courseId, semester, type } = req.query;

  if (!courseId || typeof courseId !== "string") {
    throw new AppError("courseId query param is required.", 400);
  }

  const subjects = await findSubjectsByCourseId(courseId, {
    semester: semester ? Number(semester) : undefined,
    type: typeof type === "string" ? type : undefined,
  });

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Subjects fetched successfully.",
      data: { subjects },
    })
  );
});

export const getMySubjects = asyncHandler(async (req: Request, res: Response) => {
  const subjects = await getMySubjectsService(req.user!.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Your subjects fetched successfully.",
      data: { subjects },
    })
  );
});

export const getSubjectsForm = asyncHandler(async (req: Request, res: Response) => {
  const form = await getSubjectsFormService(req.user!.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Subjects form fetched successfully.",
      data: form,
    })
  );
});

export const saveMySubjects = asyncHandler(async (req: Request, res: Response) => {
  const subjects = await saveMySubjectsService(
    req.user!.id,
    req.body as SaveMySubjectsInput
  );
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Subjects saved successfully.",
      data: { subjects },
    })
  );
});

export const searchMySubjects = asyncHandler(async (req: Request, res: Response) => {
  const q = typeof req.query.q === "string" ? req.query.q : "";
  const subjects = await searchSubjectsService(req.user!.id, q);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Subjects fetched successfully.",
      data: { subjects },
    })
  );
});
