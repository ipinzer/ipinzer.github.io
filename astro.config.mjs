// @ts-check
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
  site: "https://izzypinzer.com",
  build: {
    inlineStylesheets: "always",
  },
});
