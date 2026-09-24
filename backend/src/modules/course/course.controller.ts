import { Request, Response } from "express";
import { asyncHandler, sendResponse, AppError } from "../../utils";
import { findCoursesByUniversityId } from "./course.repository";

export const getCourses = asyncHandler(async (req: Request, res: Response) => {
  const { universityId } = req.query;

  if (!universityId || typeof universityId !== "string") {
    throw new AppError("universityId query param is required.", 400);
  }

  const courses = await findCoursesByUniversityId(universityId);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Courses fetched successfully.",
      data: { courses },
    })
  );
});
