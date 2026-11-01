import prisma from "../../config/prisma";

export const findLatestActiveUpdate = async (platform: string) => {
  return prisma.appUpdate.findFirst({
    where: {
      platform: platform.toLowerCase(),
      isActive: true,
    },
    orderBy: {
      versionCode: "desc",
    },
  });
};

export const createAppUpdate = async (data: {
  platform: string;
  versionName: string;
  versionCode: number;
  minimumVersionCode: number;
  downloadUrl: string;
  releaseNotes?: string | null;
  forceUpdate?: boolean;
  isActive?: boolean;
}) => {
  return prisma.appUpdate.create({
    data: {
      platform: data.platform.toLowerCase(),
      versionName: data.versionName,
      versionCode: data.versionCode,
      minimumVersionCode: data.minimumVersionCode,
      downloadUrl: data.downloadUrl,
      releaseNotes: data.releaseNotes ?? null,
      forceUpdate: data.forceUpdate ?? false,
      isActive: data.isActive ?? true,
    },
  });
};

export const listAppUpdates = async (platform?: string) => {
  return prisma.appUpdate.findMany({
    where: platform ? { platform: platform.toLowerCase() } : undefined,
    orderBy: {
      versionCode: "desc",
    },
  });
};

