
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



const subjectSelect = {
    id: true,
    name: true,
    code: true,
    semester: true,
    credits: true,
    type: true,
    courseId: true,
    course: { select: { name: true, shortName: true, universityId: true } },
} as const;

const TYPE_ORDER = ["DSC", "GE", "DSE", "SEC", "VAC", "AEC"];

export const sortSubjects = <T extends { type: string; name: string }>(list: T[]) =>
    [...list].sort(
        (a, b) =>
            TYPE_ORDER.indexOf(a.type) - TYPE_ORDER.indexOf(b.type) ||
            a.name.localeCompare(b.name)
    );

export const findUserSubjectState = async (userId: string) =>
    prisma.user.findUnique({
        where: { id: userId },
        select: {
            courseId: true,
            universityId: true,
            currentSemester: true,
            selectedSubjectIds: true,
            subjectsSemester: true,
            subjectsConfirmedAt: true,
        },
    });

export const findSubjectsByIds = async (ids: string[]) =>
    prisma.subject.findMany({
        where: { id: { in: ids }, isActive: true },
        select: subjectSelect,
    });

export const findSemesterSubjects = async (courseId: string, semester: number) =>
    prisma.subject.findMany({
        where: { courseId, semester, isActive: true },
        select: subjectSelect,
    });

// Dropdown options for the setup form.
// - DSC / DSE belong to the student's own course (DSC lists every semester so a
//   wrongly pre-filled subject can be corrected; DSE follows the semester).
// - GE / SEC / VAC / AEC are shared across courses: SEC, VAC and AEC live under
//   placeholder courses ("Skill Enhancement Course", ...) and GE under the course
//   of the department offering it, so they are looked up by type across the
//   whole university.
export const findFormOptions = async (
    courseId: string,
    universityId: string,
    semester: number
) =>
    prisma.subject.findMany({
        where: {
            isActive: true,
            OR: [
                { courseId, type: "DSC" },
                { courseId, type: "DSE", OR: [{ semester }, { semester: null }] },
                {
                    type: { in: ["GE", "SEC", "VAC", "AEC"] },
                    course: { universityId },
                },
            ],
        },
        select: subjectSelect,
    });

export const saveUserSubjects = async (
    userId: string,
    data: { selectedSubjectIds: string[]; subjectsSemester: number }
) =>
    prisma.user.update({
        where: { id: userId },
        data: { ...data, subjectsConfirmedAt: new Date() },
        select: { subjectsConfirmedAt: true, subjectsSemester: true },
    });

// Free-text subject search (name or code) across the user's whole university.
export const searchSubjects = async (
    universityId: string,
    query: string,
    limit: number
) =>
    prisma.subject.findMany({
        where: {
            isActive: true,
            course: { universityId },
            OR: [
                { name: { contains: query, mode: "insensitive" } },
                { code: { contains: query, mode: "insensitive" } },
            ],
        },
        select: subjectSelect,
        orderBy: { name: "asc" },
        take: limit,
    });
