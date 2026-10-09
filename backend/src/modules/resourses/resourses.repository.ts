import prisma from "../../config/prisma";
import { Prisma, ResourceStatus } from "@prisma/client";

const uploaderSelect = {
  id: true,
  firstName: true,
  lastName: true,
  username: true,
} as const;

const subjectSelect = {
  id: true,
  name: true,
  code: true,
  semester: true,
  type: true,
  courseId: true,
} as const;

// One include used by list, detail and create so every card has the same fields
const resourceInclude = (viewerId?: string) => ({
  upload: true,
  subject: { select: subjectSelect },
  uploadedBy: { select: uploaderSelect },
  ...(viewerId
    ? { bookmarks: { where: { userId: viewerId }, select: { id: true } } }
    : {}),
});

export const createResource = async (data: Prisma.ResourceUncheckedCreateInput) => {
  return prisma.resource.create({ data });
};

export const findSubjectById = async (id: string) => {
  return prisma.subject.findUnique({ where: { id }, select: { id: true } });
};

export const findResourceById = async (id: string, viewerId?: string) => {
  return prisma.resource.findUnique({
    relationLoadStrategy: "join",
    where: { id },
    include: resourceInclude(viewerId),
  });
};

export const findResources = async (filters: {
  subjectId?: string;
  courseId?: string;
  semester?: number;
  resourceType?: string;
  status?: ResourceStatus;
  search?: string;
  uploadedById?: string;
  sort: "recent" | "downloads";
  viewerId?: string;
  page: number;
  limit: number;
}) => {
  const {
    subjectId,
    courseId,
    semester,
    resourceType,
    status,
    search,
    uploadedById,
    sort,
    viewerId,
    page,
    limit,
  } = filters;

  const subjectFilter = {
    ...(courseId ? { courseId } : {}),
    ...(semester ? { semester } : {}),
  };

  const where: Prisma.ResourceWhereInput = {
    ...(subjectId ? { subjectId } : {}),
    ...(Object.keys(subjectFilter).length ? { subject: subjectFilter } : {}),
    ...(resourceType ? { resourceType: resourceType as any } : {}),
    ...(status ? { status } : {}),
    ...(uploadedById ? { uploadedById } : {}),
    ...(search
      ? {
          OR: [
            { title: { contains: search, mode: "insensitive" } },
            { description: { contains: search, mode: "insensitive" } },
          ],
        }
      : {}),
  };

  const orderBy: Prisma.ResourceOrderByWithRelationInput[] =
    sort === "downloads"
      ? [{ downloadCount: "desc" }, { createdAt: "desc" }]
      : [{ createdAt: "desc" }];

  const [resources, total] = await Promise.all([
    prisma.resource.findMany({
      relationLoadStrategy: "join",
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy,
      include: resourceInclude(viewerId),
    }),
    prisma.resource.count({ where }),
  ]);

  return {
    resources,
    meta: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

export const updateResourceStatus = async (
  id: string,
  status: ResourceStatus,
  approvedById?: string,
  rejectionReason?: string
) => {
  return prisma.resource.update({
    where: { id },
    data: {
      status,
      approvedById: status === "APPROVED" ? approvedById : null,
      approvedAt: status === "APPROVED" ? new Date() : null,
      rejectionReason: status === "REJECTED" ? rejectionReason : null,
    },
  });
};

export const incrementDownloadCount = async (id: string) => {
  return prisma.resource.update({
    where: { id },
    data: { downloadCount: { increment: 1 } },
    select: { downloadCount: true },
  });
};
