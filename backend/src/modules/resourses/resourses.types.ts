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
  resourceType?: ResourceType;
  status?: ResourceStatus;
  search?: string;
  page?: number;
  limit?: number;
};

export type RejectResourceInput = {
  rejectionReason: string;
};
