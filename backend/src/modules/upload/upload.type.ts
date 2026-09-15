export type UploadRecordInput = {
  originalName: string;
  fileName: string;
  publicId: string;
  url: string;
  secureUrl: string;
  mimeType: string;
  extension: string;
  size: number;
  type: "IMAGE" | "PDF" | "VIDEO" | "DOCUMENT";
  uploadedById: string;
};

