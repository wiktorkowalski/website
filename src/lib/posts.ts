import { SITE } from "../consts";

export interface Post {
  title: string;
  description: string;
  date: Date;
  tags: string[];
  url: string;
}

// The NAS: latest posts from the blog's /posts.json, read at build time.
// A failed fetch never breaks the build; the NAS just shows its link to the blog.
// BLOG_URL overrides the source, e.g. a local blog dev server.
const BLOG = process.env.BLOG_URL ?? SITE.blog;

export async function getPosts(limit = 6): Promise<Post[]> {
  try {
    const res = await fetch(`${BLOG}/posts.json`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const raw: Record<string, unknown>[] = await res.json();
    return raw
      .map((p) => ({
        title: String(p.title),
        description: String(p.description ?? ""),
        // New blog: date + url. Old AstroPaper feed: pubDate + link.
        date: new Date(String(p.date ?? p.pubDate)),
        tags: Array.isArray(p.tags) ? p.tags.map(String) : [],
        url: p.url ? String(p.url) : new URL(String(p.link), BLOG).href,
      }))
      .filter((p) => !Number.isNaN(p.date.valueOf()))
      .sort((a, b) => b.date.valueOf() - a.date.valueOf())
      .slice(0, limit);
  } catch (err) {
    console.warn(`[posts] could not load ${BLOG}/posts.json: ${err}`);
    return [];
  }
}
