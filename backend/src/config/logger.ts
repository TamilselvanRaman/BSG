import pino from "pino";
import { env } from "./env";

export const logger = pino({
  level: env.NODE_ENV === "test" ? "silent" : "info",
  base: { service: "click-smart-chart-api" },
  timestamp: pino.stdTimeFunctions.isoTime,
});
