import { defineConfig } from "tsup";

export default defineConfig((options) => ({
  entryPoints: ["src/index.ts"],
  external: ["@azure/functions-core", "@azure/functions"],
  clean: true,
  format: "esm",
  ...options,
}));
