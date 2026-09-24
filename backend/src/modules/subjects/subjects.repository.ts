
import prisma from "./../../config/prisma";

export const findSubjectById = async (subjectId: string) => {
    const subject = await prisma.subject.findUnique({
        where: { id: subjectId },
    });
    return subject;
};

export const findSubjectsByCourseId = async (
    courseId: string,
    filters?: { semester?: number; type?: string }
) => {
    const subjects = await prisma.subject.findMany({
        where: {
            courseId: courseId,
            ...(filters?.semester ? { semester: filters.semester } : {}),
            ...(filters?.type ? { type: filters.type as any } : {}),
        },
    });
    return subjects;
};


