// src/server.ts

import "dotenv/config"; 
import app from "./app";
import prisma from "./config/prisma";

const PORT: number = Number(process.env.PORT) || 5000;

const start = async () => {
  // Open the database connection BEFORE the first user request. Otherwise the
  // first request pays for the connection set-up (1.5-2.5 s).
  try {
    await prisma.$connect();
    await prisma.$queryRaw`SELECT 1`;
    console.log("✅ Database connected");
  } catch (error) {
    // Still start the server; requests will retry the connection themselves
    console.error("⚠️  Database not reachable at startup:", error);
  }

  // Cheap ping every 4 minutes so idle connections are not dropped by the
  // pooler (which would make the next request slow again).
  setInterval(() => {
    prisma.$queryRaw`SELECT 1`.catch(() => undefined);
  }, 4 * 60 * 1000).unref();

  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
};

start();
