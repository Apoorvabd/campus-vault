import {
  createAppUpdate,
  findLatestActiveUpdate,
  listAppUpdates,
} from "./app_update.repository";
import type { CreateAppUpdateInput } from "./app_update.validation";
import type { AppUpdateCheckResult } from "./app_update.types";

export const checkAppUpdateService = async (
  platform: string = "android",
  clientVersionCode?: number
): Promise<AppUpdateCheckResult | null> => {
  const latest = await findLatestActiveUpdate(platform);

  if (!latest) {
    return null;
  }

  const updateAvailable =
    clientVersionCode !== undefined
      ? clientVersionCode < latest.versionCode
      : true;

  const forceUpdate =
    latest.forceUpdate ||
    (clientVersionCode !== undefined &&
      clientVersionCode < latest.minimumVersionCode);

  // Parse release notes into structured list of bullet points for the mobile app
  const rawNotes = latest.releaseNotes || "";
  const releaseNotesList = rawNotes
    .split(/\r?\n/)
    .map((line) => line.replace(/^[\s•*-]+/, "").trim())
    .filter((line) => line.length > 0);

  return {
    updateAvailable,
    forceUpdate,
    currentVersionCode: clientVersionCode,
    latestVersionName: latest.versionName,
    latestVersionCode: latest.versionCode,
    minimumVersionCode: latest.minimumVersionCode,
    downloadUrl: latest.downloadUrl,
    releaseNotes: rawNotes,
    releaseNotesList,
    publishedAt: latest.createdAt,
  };
};

export const createAppUpdateService = async (input: CreateAppUpdateInput) => {
  const platform = input.platform || "android";
  const versionName = input.version_name ?? input.versionName!;
  const versionCode = input.version_code ?? input.versionCode!;
  const minimumVersionCode =
    input.minimum_version_code ?? input.minimumVersionCode ?? 1;
  const downloadUrl = input.download_url ?? input.downloadUrl!;

  let releaseNotes = input.release_notes ?? input.releaseNotes;
  if (Array.isArray(releaseNotes)) {
    releaseNotes = releaseNotes.join("\n");
  }

  const forceUpdate = input.force_update ?? input.forceUpdate ?? false;
  const isActive = input.is_active ?? input.isActive ?? true;

  return createAppUpdate({
    platform,
    versionName,
    versionCode,
    minimumVersionCode,
    downloadUrl,
    releaseNotes: releaseNotes ?? null,
    forceUpdate,
    isActive,
  });
};

export const listAppUpdatesService = async (platform?: string) => {
  return listAppUpdates(platform);
};

