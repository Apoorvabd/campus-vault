import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import {
  createResourceService,
  listResourcesService,
  getResourceByIdService,
  approveResourceService,
  rejectResourceService,
} from "./resourses.service";

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

export const listResources = asyncHandler(async (req: Request, res: Response) => {
  const { subjectId, resourceType, status, search, page, limit } = req.query;

  const result = await listResourcesService({
    subjectId: subjectId as string | undefined,
    resourceType: resourceType as any,
    status: status as any,
    search: search as string | undefined,
    page: page ? Number(page) : undefined,
    limit: limit ? Number(limit) : undefined,
  });

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
  const resource = await getResourceByIdService(req.params.id as string);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Resource fetched successfully.",
      data: { resource },
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
