import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import { findAllUniversities } from "./university.repository";

export const getUniversities = asyncHandler(async (req: Request, res: Response) => {
  const universities = await findAllUniversities();

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Universities fetched successfully.",
      data: { universities },
    })
  );
});
