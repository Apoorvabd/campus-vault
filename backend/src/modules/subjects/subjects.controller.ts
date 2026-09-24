import { Request, Response } from "express";
import { asyncHandler, sendResponse, AppError } from "../../utils";
import { findSubjectsByCourseId } from "./subjects.repository";

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
