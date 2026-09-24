// src/config/cloudinary.ts

import { v2 as cloudinary, UploadApiResponse } from "cloudinary";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

export const uploadToCloudinary = (
  fileBuffer: Buffer,
  folder: string,
  resourceType: "image" | "raw" | "auto" = "auto"
): Promise<UploadApiResponse> => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: `dukestudent/${folder}`,
        resource_type: resourceType,
      },
      (error, result) => {
        if (error || !result) {
          return reject(error);
        }
        resolve(result);
      }
    );

    uploadStream.end(fileBuffer);
  });
};

export const deleteFromCloudinary = async (
  publicId: string,
  resourceType: "image" | "raw" | "auto" = "auto"
): Promise<void> => {
  await cloudinary.uploader.destroy(publicId, { resource_type: resourceType });
};

export default cloudinary;