import { ResourceType, ResourceSourceType, ResourceStatus } from "@prisma/client";

export type CreateResourceInput = {
  title: string;
  description?: string;
  resourceType: ResourceType;
  subjectId: string;
  sourceType: ResourceSourceType;
  externalUrl?: string;
};

export type ResourceFilters = {
  subjectId?: string;
  courseId?: string;
  semester?: number;
  resourceType?: ResourceType;
  status?: ResourceStatus;
  search?: string;
  uploadedById?: string;
  sort?: "recent" | "downloads";
  page?: number;
  limit?: number;
};

// Who is asking (undefined = anonymous). Decides what they may see.
export type ResourceViewer = { id: string; role: string };

export type RejectResourceInput = {
  rejectionReason: string;
};
