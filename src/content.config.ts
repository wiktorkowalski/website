import { defineCollection } from "astro:content";
import { file, glob } from "astro/loaders";
import { z } from "astro/zod";

// One project = one 2U server: src/content/projects/<slug>.md
const projects = defineCollection({
  loader: glob({ base: "./src/content/projects", pattern: "*.md" }),
  schema: z.object({
    title: z.string(),
    summary: z.string(),
    repo: z.url().optional(),
    url: z.url().optional(),
    stack: z.array(z.string()).default([]),
    status: z.enum(["active", "maintained", "archived"]).default("active"),
    order: z.number().default(100),
    hidden: z.boolean().default(false),
  }),
});

const period = z.object({
  from: z.string(),
  to: z.string().optional(),
});

// CV = tape library / log server. One yaml key = one entry, `kind` picks the shape.
const cv = defineCollection({
  loader: file("./src/data/cv.yaml"),
  schema: z.discriminatedUnion("kind", [
    z.object({
      kind: z.literal("job"),
      role: z.string(),
      company: z.string(),
      location: z.string().optional(),
      ...period.shape,
      notes: z.array(z.string()).default([]),
    }),
    z.object({ kind: z.literal("school"), degree: z.string(), school: z.string(), ...period.shape }),
    z.object({
      kind: z.literal("cert"),
      name: z.string(),
      issuer: z.string().optional(),
      year: z.string().optional(),
      url: z.string().optional(),
    }),
  ]),
});

// Stack = switch ports. One yaml key = one switch.
const stack = defineCollection({
  loader: file("./src/data/stack.yaml"),
  schema: z.object({ items: z.array(z.string()) }),
});

export const collections = { projects, cv, stack };
