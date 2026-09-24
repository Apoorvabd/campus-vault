import { AppError } from "../../utils";
import { uploadAndSave } from "../upload/upload.service";
import {
  createResource,
  findResourceById,
  findResources,
  updateResourceStatus,
} from "./resourses.repository";
import { CreateResourceInput, ResourceFilters } from "./resourses.types";

export const createResourceService = async (
  input: CreateResourceInput,
  file: Express.Multer.File | undefined,
  uploadedById: string
) => {
  let uploadId: string | undefined;

  if (input.sourceType === "HOSTED") {
    if (!file) {
      throw new AppError("A file is required for HOSTED resources.", 400);
    }
    const uploadRecord = await uploadAndSave(file, "resources", uploadedById);
    uploadId = uploadRecord.id;
  }

  return createResource({
    title: input.title,
    description: input.description,
    resourceType: input.resourceType,
    subjectId: input.subjectId,
    sourceType: input.sourceType,
    externalUrl: input.sourceType === "EXTERNAL_LINK" ? input.externalUrl : null,
    uploadId,
    uploadedById,
    status: "PENDING",
  });
};

export const listResourcesService = async (filters: ResourceFilters) => {
  const page = filters.page ?? 1;
  const limit = filters.limit ?? 20;

  return findResources({
    subjectId: filters.subjectId,
    resourceType: filters.resourceType,
    status: filters.status,
    search: filters.search,
    page,
    limit,
  });
};

export const getResourceByIdService = async (id: string) => {
  const resource = await findResourceById(id);
  if (!resource) {
    throw new AppError("Resource not found.", 404);
  }
  return resource;
};

export const approveResourceService = async (id: string, approvedById: string) => {
  const existing = await findResourceById(id);
  if (!existing) {
    throw new AppError("Resource not found.", 404);
  }
  return updateResourceStatus(id, "APPROVED", approvedById);
};

export const rejectResourceService = async (id: string, rejectionReason: string) => {
  const existing = await findResourceById(id);
  if (!existing) {
    throw new AppError("Resource not found.", 404);
  }
  return updateResourceStatus(id, "REJECTED", undefined, rejectionReason);
};
