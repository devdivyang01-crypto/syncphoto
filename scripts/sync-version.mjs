#!/usr/bin/env node
/**
 * Synchronize the semantic version from VERSION (or an explicit argument)
 * across desktop, mobile, and backend config files.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const requested = process.argv[2];
const version = (requested ?? readFileSync(join(root, "VERSION"), "utf8"))
  .trim()
  .replace(/^v/, "");

if (!/^\d+\.\d+\.\d+$/.test(version)) {
  console.error(`Invalid semantic version: ${version}`);
  process.exit(1);
}

function replace(path, pattern, replacement) {
  const full = join(root, path);
  const before = readFileSync(full, "utf8");
  if (!pattern.test(before)) {
    throw new Error(`Failed to update version in ${path}`);
  }
  writeFileSync(full, before.replace(pattern, replacement));
}

writeFileSync(join(root, "VERSION"), `${version}\n`);

replace("desktop/package.json", /"version":\s*"[^"]+"/, `"version": "${version}"`);
replace("desktop/src-tauri/tauri.conf.json", /"version":\s*"[^"]+"/, `"version": "${version}"`);
replace("desktop/src-tauri/Cargo.toml", /^version = "[^"]+"/m, `version = "${version}"`);
replace("mobile/pubspec.yaml", /^version:\s*[^\n]+/m, `version: ${version}+1`);
replace("backend/.env.example", /^APP_VERSION=.*/m, `APP_VERSION=${version}`);
replace("backend/config/syncbox.php", /env\('APP_VERSION', '[^']+'\)/, `env('APP_VERSION', '${version}')`);

console.log(`Synchronized application version to ${version}`);
