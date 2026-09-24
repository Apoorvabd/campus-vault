import { Request, Response } from "express";
import { asyncHandler, sendResponse, AppError } from "../../utils";
import { findCollegesByUniversityId } from "./college.repository";

export const getColleges = asyncHandler(async (req: Request, res: Response) => {
  const { universityId } = req.query;

  if (!universityId || typeof universityId !== "string") {
    throw new AppError("universityId query param is required.", 400);
  }

  const colleges = await findCollegesByUniversityId(universityId);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Colleges fetched successfully.",
      data: { colleges },
    })
  );
});
