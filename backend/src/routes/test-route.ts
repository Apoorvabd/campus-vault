// app.ts ya routes/index.ts me temporarily (test ke baad hata dena)
import {request, Response, response} from 'express';
import { Router } from "express";
import { authenticate } from "./../middleware";
import { upload } from "../middleware/upload.middleware";
import { uploadToCloudinary } from "./../config";
import { asyncHandler, sendResponse } from "./../utils";
import { uploadAndSave } from "./../modules/upload/upload.service";


const testRouter = Router();
// test route me badlav — uploadToCloudinary ki jagah uploadAndSave use karo


testRouter.post(
  "/upload",
  authenticate,
  upload.single("file"),
  asyncHandler(async (req: { file: Express.Multer.File; user: any; }, res: Response<any, Record<string, any>>) => {
    if (!req.file) {
      return res.status(400).json({ success: false, message: "No file uploaded." });
    }

    const uploadRecord = await uploadAndSave(req.file, "resources", req.user!.id);

    console.log("✅ [test-upload] DB me Upload row bani:", uploadRecord);

    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "File uploaded and saved successfully.",
        data: uploadRecord,
      })
    );
  })
);
export default testRouter;