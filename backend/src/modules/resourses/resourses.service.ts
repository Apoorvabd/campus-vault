import { ResourceStatus } from "@prisma/client";
import { AppError } from "../../utils";
import { uploadAndSave } from "../upload/upload.service";
import {
  createResource,
  findResourceById,
  findResources,
  findSubjectById,
  incrementDownloadCount,
  updateResourceStatus,
} from "./resourses.repository";
import {
  CreateResourceInput,
  ResourceFilters,
  ResourceViewer,
} from "./resourses.types";

const ADMIN_ROLES = ["SUPER_ADMIN", "UNIVERSITY_ADMIN"];
const isAdmin = (viewer?: ResourceViewer) =>
  !!viewer && ADMIN_ROLES.includes(viewer.role);

// Turns the per-user `bookmarks` array (0 or 1 rows) into a boolean
export const presentResource = <T extends { bookmarks?: { id: string }[] }>(
  resource: T
) => {
  const { bookmarks, ...data } = resource;
  return {
    ...data,
    ...(bookmarks ? { isBookmarked: bookmarks.length > 0 } : {}),
  };
};

// Non-approved resources are visible only to their uploader and to admins
const canView = (
  resource: { status: ResourceStatus; uploadedById: string },
  viewer?: ResourceViewer
) =>
  resource.status === "APPROVED" ||
  isAdmin(viewer) ||
  (!!viewer && resource.uploadedById === viewer.id);

export const createResourceService = async (
  input: CreateResourceInput,
  file: Express.Multer.File | undefined,
  uploadedById: string
) => {
  if (!(await findSubjectById(input.subjectId))) {
    throw new AppError("Subject not found.", 404);
  }

  let uploadId: string | undefined;

  if (input.sourceType === "HOSTED") {
    if (!file) {
      throw new AppError("A file is required for HOSTED resources.", 400);
    }
    const uploadRecord = await uploadAndSave(file, "resources", uploadedById);
    uploadId = uploadRecord.id;
  }

  const created = await createResource({
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

  // Re-read with upload / subject / uploader so the client gets a complete card
  const full = await findResourceById(created.id, uploadedById);
  return presentResource(full!);
};

export const listResourcesService = async (
  filters: ResourceFilters & { mine?: boolean },
  viewer?: ResourceViewer
) => {
  if (filters.mine && !viewer) {
    throw new AppError("Authentication token is required.", 401);
  }

  // Who may see which statuses:
  //  - mine=true : the caller's own uploads, any status (or the ?status they asked for)
  //  - admin     : the ?status they asked for (default APPROVED), e.g. the PENDING queue
  //  - everyone  : APPROVED only, whatever ?status says
  let status: ResourceStatus | undefined;
  if (filters.mine) {
    status = filters.status;
  } else if (isAdmin(viewer)) {
    status = filters.status ?? "APPROVED";
  } else {
    status = "APPROVED";
  }

  const result = await findResources({
    subjectId: filters.subjectId,
    courseId: filters.courseId,
    semester: filters.semester,
    resourceType: filters.resourceType,
    status,
    search: filters.search,
    uploadedById: filters.mine ? viewer!.id : undefined,
    sort: filters.sort ?? "recent",
    viewerId: viewer?.id,
    page: filters.page ?? 1,
    limit: filters.limit ?? 20,
  });

  return { ...result, resources: result.resources.map(presentResource) };
};

export const getResourceByIdService = async (
  id: string,
  viewer?: ResourceViewer
) => {
  const resource = await findResourceById(id, viewer?.id);
  // Hidden resources look exactly like missing ones
  if (!resource || !canView(resource, viewer)) {
    throw new AppError("Resource not found.", 404);
  }
  return presentResource(resource);
};

export const recordDownloadService = async (
  id: string,
  viewer: ResourceViewer
) => {
  const resource = await findResourceById(id);
  if (!resource || !canView(resource, viewer)) {
    throw new AppError("Resource not found.", 404);
  }
  return incrementDownloadCount(id);
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
