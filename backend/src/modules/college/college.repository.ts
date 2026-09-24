import prisma from "../../config/prisma";

export const findCollegeById = async (collegeId: string) => {
    const college = await prisma.college.findUnique({
        where: { id: collegeId },
    });
    return college;
};

export const findCollegeByName = async (name: string) => {
    const college = await prisma.college.findFirst({
        where: { name: name },
    });
    return college;
};
export const findCollegesByUniversityId = async (universityId: string) => {
    const colleges = await prisma.college.findMany({
        where: { universityId: universityId },
    });
    return colleges;
};
