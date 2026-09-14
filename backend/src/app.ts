import express, { Express, Request, Response } from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import { globalErrorHandler, notFoundHandler } from "./middleware";
import autroutes from "./routes";
// app.ts me temporarily (ya routes/index.ts me)
import { z } from "zod";
import { validate } from "./middleware";
import routes from "./routes";

const app: Express = express();

app.use(
  cors({
    origin: process.env.CLIENT_URL,
    credentials: true,
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

app.get("/", (req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: "Campus Vault API is running 🚀",
  });
});

app.use("/api/v1", routes);


app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;