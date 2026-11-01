import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import {
  checkAppUpdateService,
  createAppUpdateService,
  listAppUpdatesService,
} from "./app_update.service";
import type { CreateAppUpdateInput, GetAppUpdateQuery } from "./app_update.validation";

export const getAppUpdate = asyncHandler(
  async (req: Request, res: Response) => {
    const query = req.query as unknown as GetAppUpdateQuery;
    const platform = (query.platform as string) || "android";
    const versionCodeRaw =
      query.version_code ?? query.versionCode ?? query.current_version_code;
    const clientVersionCode =
      versionCodeRaw !== undefined ? Number(versionCodeRaw) : undefined;

    const result = await checkAppUpdateService(platform, clientVersionCode);

    if (!result) {
      return res.status(200).json(
        sendResponse(res, {
          statusCode: 200,
          message: "No active app updates found.",
          data: {
            updateAvailable: false,
            forceUpdate: false,
          },
        })
      );
    }

    return res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: result.updateAvailable
          ? "A new app update is available."
          : "App is up to date.",
        data: result,
      })
    );
  }
);

export const postAppUpdate = asyncHandler(
  async (req: Request, res: Response) => {
    const update = await createAppUpdateService(
      req.body as CreateAppUpdateInput
    );

    return res.status(201).json(
      sendResponse(res, {
        statusCode: 201,
        message: "App update published successfully.",
        data: { update },
      })
    );
  }
);

export const getAllAppUpdates = asyncHandler(
  async (req: Request, res: Response) => {
    const platform = req.query.platform as string | undefined;
    const updates = await listAppUpdatesService(platform);

    return res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "App updates fetched successfully.",
        data: { updates },
      })
    );
  }
);

