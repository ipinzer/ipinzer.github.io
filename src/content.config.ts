import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";

const projects = defineCollection({
  loader: glob({ pattern: "*.md", base: "./src/content/projects" }),
  schema: z.object({
    title: z.string(),
    category: z.enum(["featured", "other", "internship"]),
    order: z.number().default(0),
    cover: z.string().optional(),
    meta: z.record(z.string()).optional(),
  }),
});

export const collections = { projects };
