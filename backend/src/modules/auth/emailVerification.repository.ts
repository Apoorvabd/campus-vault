import prisma from "../../config/prisma";

const purpose = "EMAIL_VERIFY" as const;
const byEmail = (email: string) => ({ email_purpose: { email, purpose } });

export const findEmailOtp = async (email: string) => {
  return prisma.emailOtp.findUnique({ where: byEmail(email) });
};

export const saveEmailOtp = async (data: {
  email: string;
  codeHash: string;
  expiresAt: Date;
  sentAt: Date;
}) => {
  const { email, ...code } = data;
  return prisma.emailOtp.upsert({
    where: byEmail(email),
    create: { email, purpose, ...code },
    // A fresh code starts clean: no wrong attempts, nothing verified yet
    update: { ...code, attempts: 0, verifiedAt: null, proofHash: null },
  });
};

export const addEmailOtpAttempt = async (email: string) => {
  return prisma.emailOtp.update({
    where: byEmail(email),
    data: { attempts: { increment: 1 } },
    select: { attempts: true },
  });
};

export const markEmailOtpVerified = async (email: string, proofHash: string) => {
  return prisma.emailOtp.update({
    where: byEmail(email),
    data: { verifiedAt: new Date(), proofHash },
  });
};

export const deleteEmailOtp = async (email: string) => {
  return prisma.emailOtp.deleteMany({ where: { email, purpose } });
};

// Anything sent over a day ago is dead: its code and its proof have both expired
export const deleteStaleEmailOtps = async () => {
  return prisma.emailOtp.deleteMany({
    where: { sentAt: { lt: new Date(Date.now() - 24 * 60 * 60 * 1000) } },
  });
};
