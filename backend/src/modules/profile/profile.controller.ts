import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import {
  getMyProfileService,
  getPublicProfileService,
  removeMyAvatarService,
  updateMyAvatarService,
  updateMyProfileService,
} from "./profile.service";
import type { UpdateProfileInput } from "./profile.validation";

export const getMyProfile = asyncHandler(async (req: Request, res: Response) => {
  const profile = await getMyProfileService(req.user!.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Profile fetched successfully.",
      data: { profile },
    })
  );
});

export const getPublicProfile = asyncHandler(
  async (req: Request, res: Response) => {
    const profile = await getPublicProfileService(
      req.params.username as string
    );
    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "Profile fetched successfully.",
        data: { profile },
      })
    );
  }
);

export const updateMyProfile = asyncHandler(
  async (req: Request, res: Response) => {
    const profile = await updateMyProfileService(
      req.user!.id,
      req.body as UpdateProfileInput
    );
    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "Profile updated successfully.",
        data: { profile },
      })
    );
  }
);

export const updateMyAvatar = asyncHandler(
  async (req: Request, res: Response) => {
    const profile = await updateMyAvatarService(req.user!.id, req.file);
    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "Profile avatar updated successfully.",
        data: { profile },
      })
    );
  }
);

export const removeMyAvatar = asyncHandler(
  async (req: Request, res: Response) => {
    const profile = await removeMyAvatarService(req.user!.id);
    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "Profile avatar removed successfully.",
        data: { profile },
      })
    );
  }
);
