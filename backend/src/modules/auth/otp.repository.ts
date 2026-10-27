import { OtpPurpose } from "@prisma/client";
import prisma from "../../config/prisma";

const byEmail = (email: string, purpose: OtpPurpose) => ({
  email_purpose: { email, purpose },
});

export const findOtp = async (email: string, purpose: OtpPurpose) => {
  return prisma.emailOtp.findUnique({ where: byEmail(email, purpose) });
};

export const saveOtp = async (data: {
  email: string;
  purpose: OtpPurpose;
  codeHash: string;
  expiresAt: Date;
  sentAt: Date;
}) => {
  const { email, purpose, ...code } = data;
  return prisma.emailOtp.upsert({
    where: byEmail(email, purpose),
    create: { email, purpose, ...code },
    // A fresh code starts clean: no wrong attempts, nothing verified yet
    update: { ...code, attempts: 0, verifiedAt: null, proofHash: null },
  });
};

export const addOtpAttempt = async (email: string, purpose: OtpPurpose) => {
  return prisma.emailOtp.update({
    where: byEmail(email, purpose),
    data: { attempts: { increment: 1 } },
    select: { attempts: true },
  });
};

export const markOtpVerified = async (
  email: string,
  purpose: OtpPurpose,
  proofHash: string
) => {
  return prisma.emailOtp.update({
    where: byEmail(email, purpose),
    data: { verifiedAt: new Date(), proofHash },
  });
};

export const deleteOtp = async (email: string, purpose: OtpPurpose) => {
  return prisma.emailOtp.deleteMany({ where: { email, purpose } });
};

// Anything sent over a day ago is dead: its code and its proof have both expired
export const deleteStaleOtps = async () => {
  return prisma.emailOtp.deleteMany({
    where: { sentAt: { lt: new Date(Date.now() - 24 * 60 * 60 * 1000) } },
  });
};
