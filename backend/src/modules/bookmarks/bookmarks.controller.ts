import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import {
  bookmarkPostService,
  bookmarkResourceService,
  listBookmarkedPostsService,
  listBookmarkedResourcesService,
  unbookmarkPostService,
  unbookmarkResourceService,
} from "./bookmarks.service";
import type { ListBookmarksQuery } from "./bookmarks.validation";

export const bookmarkPost = asyncHandler(async (req: Request, res: Response) => {
  const data = await bookmarkPostService(req.user!.id, req.params.postId as string);
  res.status(200).json(
    sendResponse(res, { statusCode: 200, message: "Post bookmarked.", data })
  );
});

export const unbookmarkPost = asyncHandler(async (req: Request, res: Response) => {
  const data = await unbookmarkPostService(req.user!.id, req.params.postId as string);
  res.status(200).json(
    sendResponse(res, { statusCode: 200, message: "Bookmark removed.", data })
  );
});

export const bookmarkResource = asyncHandler(
  async (req: Request, res: Response) => {
    const data = await bookmarkResourceService(
      req.user!.id,
      req.params.resourceId as string
    );
    res.status(200).json(
      sendResponse(res, { statusCode: 200, message: "Resource bookmarked.", data })
    );
  }
);

export const unbookmarkResource = asyncHandler(
  async (req: Request, res: Response) => {
    const data = await unbookmarkResourceService(
      req.user!.id,
      req.params.resourceId as string
    );
    res.status(200).json(
      sendResponse(res, { statusCode: 200, message: "Bookmark removed.", data })
    );
  }
);

export const listBookmarkedPosts = asyncHandler(
  async (req: Request, res: Response) => {
    const { page, limit } = req.validatedQuery as ListBookmarksQuery;
    const result = await listBookmarkedPostsService(req.user!.id, page, limit);
    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "Bookmarked posts fetched successfully.",
        data: { posts: result.posts },
        meta: result.meta,
      })
    );
  }
);

export const listBookmarkedResources = asyncHandler(
  async (req: Request, res: Response) => {
    const { page, limit } = req.validatedQuery as ListBookmarksQuery;
    const result = await listBookmarkedResourcesService(req.user!.id, page, limit);
    res.status(200).json(
      sendResponse(res, {
        statusCode: 200,
        message: "Bookmarked resources fetched successfully.",
        data: { resources: result.resources },
        meta: result.meta,
      })
    );
  }
);
