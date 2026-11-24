import { randomBytes, scrypt as derive, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";
const scrypt = promisify(derive);
const options = { N: 131072, r: 8, p: 1, maxmem: 256 * 1024 * 1024 };

export async function hashPassword(password) {
  const salt = randomBytes(16).toString("hex");
  const hash = await scrypt(password, salt, 64, options);
  return `scrypt$131072$8$1$${salt}$${hash.toString("hex")}`;
}

export async function verifyPassword(password, encoded) {
  const parts = String(encoded).split("$");
  if (
    parts.length !== 6 ||
    parts.slice(0, 4).join("$") !== "scrypt$131072$8$1" ||
    !/^[a-f0-9]{32}$/.test(parts[4]) ||
    !/^[a-f0-9]{128}$/.test(parts[5])
  )
    return false;
  const actual = await scrypt(password, parts[4], 64, options);
  return timingSafeEqual(actual, Buffer.from(parts[5], "hex"));
}
