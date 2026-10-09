import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import {
  createResourceService,
  listResourcesService,
  getResourceByIdService,
  recordDownloadService,
  approveResourceService,
  rejectResourceService,
} from "./resourses.service";
import type { ListResourcesQuery } from "./resourses.validation";

export const createResource = asyncHandler(async (req: Request, res: Response) => {
  const resource = await createResourceService(req.body, req.file, req.user!.id);

  res.status(201).json(
    sendResponse(res, {
      statusCode: 201,
      message: "Resource created successfully.",
      data: { resource },
    })
  );
});

const viewerOf = (req: Request) =>
  req.user ? { id: req.user.id, role: req.user.role } : undefined;

export const listResources = asyncHandler(async (req: Request, res: Response) => {
  const query = req.validatedQuery as ListResourcesQuery;

  const result = await listResourcesService(query, viewerOf(req));

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Resources fetched successfully.",
      data: { resources: result.resources },
      meta: result.meta,
    })
  );
});

export const getResource = asyncHandler(async (req: Request, res: Response) => {
  const resource = await getResourceByIdService(
    req.params.id as string,
    viewerOf(req)
  );

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Resource fetched successfully.",
      data: { resource },
    })
  );
});

export const recordDownload = asyncHandler(async (req: Request, res: Response) => {
  const result = await recordDownloadService(
    req.params.id as string,
    viewerOf(req)!
  );

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Download recorded.",
      data: result,
    })
  );
});

export const approveResource = asyncHandler(async (req: Request, res: Response) => {
  const resource = await approveResourceService(req.params.id as string, req.user!.id);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Resource approved.",
      data: { resource },
    })
  );
});

export const rejectResource = asyncHandler(async (req: Request, res: Response) => {
  const resource = await rejectResourceService(req.params.id as string, req.body.rejectionReason);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Resource rejected.",
      data: { resource },
    })
  );
});
