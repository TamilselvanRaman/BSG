import express from "express";
import cors from "cors";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import rateLimit from "express-rate-limit";
import swaggerUi from "swagger-ui-express";
import { env } from "./config/env";
import { openApiSpec } from "./config/swagger";
import { apiV1Router } from "./routes";
import { errorHandler } from "./middleware/errorHandler";

export const app = express();

app.use(helmet());
app.use(
  cors({
    origin: env.CORS_ORIGIN.split(",").map((o) => o.trim()),
    credentials: true,
  })
);
app.use(express.json({ limit: "5mb" }));
app.use(cookieParser());

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: "RATE_LIMIT_EXCEEDED",
      message: "Too many login attempts. Please wait 15 minutes.",
    },
  },
});

app.get("/health", (_req, res) => {
  res.json({
    status: "healthy",
    service: "click-smart-chart-api",
    timestamp: new Date().toISOString(),
  });
});

app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(openApiSpec));
app.use("/api/v1/auth/login", authLimiter);
app.use("/api/v1", apiV1Router);

app.use(errorHandler);
