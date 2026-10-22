import express, { Express, Request, Response } from "express";
import cors from "cors";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import { globalErrorHandler, notFoundHandler } from "./middleware";
import autroutes from "./routes";
// app.ts me temporarily (ya routes/index.ts me)
import { z } from "zod";
import { validate } from "./middleware";
import routes from "./routes";

const app: Express = express();

// Render sits behind one proxy; without this every client shares the proxy's IP
// and the rate limiters would count them all together.
app.set("trust proxy", 1);

app.use(helmet());

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
    message: "Semester Forge API is running 🚀",
  });
});

app.use("/api/v1", routes);


app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;