import { Response } from "express";
export class ApiResponse<T> {
    public readonly statusCode: number;
    public readonly message: string;
    public readonly data?: T | null;
    public readonly meta?: Record<string, any>;
    public readonly success: boolean = true;

    constructor(
        statusCode: number,
        message: string,
        data?: T | null,
        meta?: Record<string, any>
    ) {
        this.statusCode = statusCode;
        this.message = message;
        this.data = data;
        this.meta = meta;
    }
}

interface sendResponseOtions<T> {
    statusCode: number;
    message: string;
    data?: T | null;
    meta?: Record<string, any>;
}

export function sendResponse<T>(
   res:Response,
   { statusCode, message, data, meta }: sendResponseOtions<T>
): ApiResponse<T> {
    return new ApiResponse<T>(statusCode, message, data, meta);
}