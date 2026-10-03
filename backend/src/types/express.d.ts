import { UserRole } from "@prisma/client";

declare global {
  namespace Express {
    interface Request {
      validatedQuery?: unknown;
      user?: {
        id: string;
        firstName: string;
        lastName: string | null;
        username: string;
        email: string;
        role: UserRole;
        canPost: boolean;
        isActive: boolean;
        isVerified: boolean;
        universityId: string;
        collegeId: string;
        courseId: string;
        currentSemester: number;
      };
    }
  }
}

export {};