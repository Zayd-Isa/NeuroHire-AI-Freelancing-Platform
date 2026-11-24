import sql from "mssql";

export { sql };
export function databaseConfig(overrides = {}) {
  if (!process.env.SQL_PASSWORD)
    throw new Error("SQL_PASSWORD is required in the local environment.");
  return {
    server: process.env.SQL_SERVER || "127.0.0.1",
    port: Number(process.env.SQL_PORT || 1433),
    database: process.env.SQL_DATABASE || "NeuroLanceHubDB",
    user: process.env.SQL_USER,
    password: process.env.SQL_PASSWORD,
    options: {
      encrypt: process.env.SQL_ENCRYPT !== "false",
      trustServerCertificate: process.env.SQL_TRUST_CERTIFICATE === "true",
      enableArithAbort: true,
    },
    pool: { min: 0, max: 8, idleTimeoutMillis: 30000 },
    requestTimeout: 15000,
    ...overrides,
  };
}
