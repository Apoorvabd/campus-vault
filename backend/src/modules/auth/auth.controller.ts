// src/modules/auth/auth.controller.ts

import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import { loginUser, registerUser,refreshTokens ,getMeService, logoutUser} from "./auth.service";
import { sendEmailCode, verifyEmailCode } from "./emailVerification.service";

export const register = asyncHandler(async (req: Request, res: Response) => {
  const { user, tokens } = await registerUser(req.body);

  res.status(201).json(
    sendResponse(res, {
      statusCode: 201,
      message: "Registered successfully.",
      data: { user, tokens },
    })
  );
});

export const sendEmailVerificationCode = asyncHandler(async (req: Request, res: Response) => {
  const result = await sendEmailCode(req.body.email);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Verification code sent.",
      data: result,
    })
  );
});

export const verifyEmailVerificationCode = asyncHandler(async (req: Request, res: Response) => {
  const result = await verifyEmailCode(req.body.email, req.body.code);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Email verified.",
      data: result,
    })
  );
});

export const login =asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const { user, tokens } = await loginUser(email, password);
    
    res.status(200).json(
        sendResponse(res, {
            statusCode: 200,
            message: "Logged in successfully.",
            data: { user, tokens },
        })
    );
});

export const refreshToken = asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body;
    const { tokens } = await refreshTokens(refreshToken);

    res.status(200).json(
        sendResponse(res, {
            statusCode: 200,
            message: "Tokens refreshed successfully.",
            data: { tokens },
        })
    );
});

export const getMe = asyncHandler(async (req: Request, res: Response) => {
  const user = await getMeService(req.user!.id);   
  
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Current user fetched.",
      data: { user },
    })
  );
});

export const logout = asyncHandler(async (req: Request, res: Response) => {
  await logoutUser(req.user!.id);

  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Logged out successfully.",
    })
  );
});