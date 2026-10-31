# wiktorkowalski.pl

Personal website as a 42U server rack. Astro 7, fully static, hosted on Cloudflare Workers (static assets).

## Develop

```sh
npm install
npm run dev      # http://localhost:4321, hot reload
npm run check    # astro check (also runs in CI)
npm run build
```

## Content

| What         | Where                                                                                               | Rack device         |
| ------------ | --------------------------------------------------------------------------------------------------- | ------------------- |
| Projects     | `src/content/projects/<slug>.md` (one file = one 2U server, `order` sorts, `hidden: true` unmounts) | SRV-xx              |
| CV           | `src/data/cv.yaml` (`kind: job / school / cert`)                                                    | LOG-01              |
| Stack        | `src/data/stack.yaml` (one key = one switch, ports in order)                                        | SW-01               |
| About        | `src/pages/index.astro`                                                                             | KVM-01              |
| Socials, nav | `src/consts.ts`                                                                                     | PDU-01, patch panel |

Latest posts (NAS-01) come from `https://blog.wiktorkowalski.pl/posts.json` at build time. Set `BLOG_URL` to read
another blog (e.g. a local `npm run dev` of the blog). If the fetch fails the build still passes, the NAS just
shows the link to the blog.

## Deploy

Cloudflare Workers Builds: `npm run build`, assets from `dist/` (see `wrangler.jsonc`). Every PR gets a preview URL.
A blog deploy triggers a rebuild of this site through a Cloudflare deploy hook so the NAS stays fresh.
