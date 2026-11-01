export interface AppUpdateData {
  id: string;
  platform: string;
  versionName: string;
  versionCode: number;
  minimumVersionCode: number;
  downloadUrl: string;
  releaseNotes: string | null;
  forceUpdate: boolean;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface AppUpdateCheckResult {
  updateAvailable: boolean;
  forceUpdate: boolean;
  currentVersionCode?: number;
  latestVersionName: string;
  latestVersionCode: number;
  minimumVersionCode: number;
  downloadUrl: string;
  releaseNotes: string;
  releaseNotesList: string[];
  publishedAt: Date;
}

