// @ts-check
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
  // Update `site` to your final URL (custom domain or https://<user>.github.io).
  // For a GitHub *project* page (…github.io/<repo>), also set `base: "/<repo>"`.
  site: "https://izzypinzer.example.com",
  build: {
    inlineStylesheets: "always",
  },
});
