import prisma from "../../config/prisma";

export const findCourseById = async (courseId: string) => {
    const course = await prisma.course.findUnique({
        where: { id: courseId },
    });
    return course;
};

export const findCoursesByUniversityId = async (universityId: string) => {
    const courses = await prisma.course.findMany({
        where: { universityId: universityId },
    });
    return courses;
};
