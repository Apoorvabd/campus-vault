//upload service. mapMimeTypeToUploadType(mimetype: string) — chhota switch/if-else 
// jo application/pdf → "PDF", image/* → "IMAGE", baaki → "DOCUMENT" return kare.

import { UploadRecordInput } from "./upload.type";
import { createUploadRecord } from "./upload.repository";
import { uploadToCloudinary } from "../../config/cloudinary";


//helper functions 
export const uploadAndSave = async (
    file: Express.Multer.File,
    folder: string,
    uploadedById: string

) => {
    const result = await uploadToCloudinary(file.buffer, folder, "auto");

    const type = mapMimeTypeToUploadType(file.mimetype);

    const uploadRecord= await saveUploadRecord({
         originalName: file.originalname,
         fileName: result.public_id,
         publicId: result.public_id,
         url: result.url,
         secureUrl: result.secure_url,
         mimeType: file.mimetype,
         extension: result.format,
         size: result.bytes,
         type,
         uploadedById,

    });
    return uploadRecord;
};
 
const mapMimeTypeToUploadType = (mimetype: string) => {
    if( mimetype === "application/pdf") {
        return "PDF";
    } else if (mimetype.startsWith("image/")) {
        return "IMAGE";
    } else if (mimetype.startsWith("video/")) {
        return "VIDEO";
    } else {
        return "DOCUMENT";    }
};

 const saveUploadRecord = async (uploadRecordInput: UploadRecordInput) => {
    return createUploadRecord(uploadRecordInput);
};
