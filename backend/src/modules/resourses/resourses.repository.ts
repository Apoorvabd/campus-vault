import prisma from "../../config/prisma";
import { Prisma, ResourceStatus } from "@prisma/client";

export const createResource = async (data: Prisma.ResourceUncheckedCreateInput) => {
  return prisma.resource.create({ data });
};

export const findResourceById = async (id: string) => {
  return prisma.resource.findUnique({
    where: { id },
    include: {
      upload: true,
      subject: true,
      uploadedBy: {
        select: { id: true, firstName: true, lastName: true, username: true },
      },
    },
  });
};

export const findResources = async (filters: {
  subjectId?: string;
  resourceType?: string;
  status?: string;
  search?: string;
  page: number;
  limit: number;
}) => {
  const { subjectId, resourceType, status, search, page, limit } = filters;

  // Public listing shows only APPROVED by default — a PENDING/REJECTED filter
  // is only meaningful when an admin explicitly asks for it via ?status=
  const where: Prisma.ResourceWhereInput = {
    ...(subjectId ? { subjectId } : {}),
    ...(resourceType ? { resourceType: resourceType as any } : {}),
    status: (status as ResourceStatus) ?? "APPROVED",
    ...(search
      ? {
          OR: [
            { title: { contains: search, mode: "insensitive" } },
            { description: { contains: search, mode: "insensitive" } },
          ],
        }
      : {}),
  };

  const [resources, total] = await Promise.all([
    prisma.resource.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: "desc" },
      include: { upload: true },
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
