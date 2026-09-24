import prisma from "../../config/prisma";

export const findAllUniversities = async () => {
    const universities = await prisma.university.findMany();
    return universities;
};

export const findUniversityById = async (universityId: string) => {
    const university = await prisma.university.findUnique({
        where: { id: universityId },
    });
    return university;
};

export const findUniversityByName = async (name: string) => {
    const university = await prisma.university.findFirst({
        where: { name: name },
    });
    return university;
};

export const createUniversity = async (name: string, shortName: string) => {
    const university = await prisma.university.create({
        data: { name, shortName },
    });
    return university;
};




