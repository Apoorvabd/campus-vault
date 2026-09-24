//only prishma to store db record at time of uploading

import prisma from "../../config/prisma";
import { UploadRecordInput } from "./upload.type";

export const createUploadRecord = async (uploadRecordInput: UploadRecordInput) => {
    return prisma.upload.create({
        data: uploadRecordInput,
        
    });
    };