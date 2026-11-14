import { app } from "./app";
import { env } from "./config/env";
import { logger } from "./config/logger";

app.listen(env.PORT, () => {
  logger.info(
    `CLICK Smart Chart SaaS API listening on http://localhost:${env.PORT} (Swagger: http://localhost:${env.PORT}/api/docs)`
  );
});
