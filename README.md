# Izzy Pinzer — Interior Architecture Portfolio

A fast, self-hosted portfolio for **Isadora (Izzy) Pinzer**, built with [Astro](https://astro.build).
It replaces the paid Wix site and deploys as static files to any free host
(GitHub Pages, Netlify, Cloudflare Pages).

- Zero client-side JavaScript, optimized/responsive images (WebP/AVIF)
- Content lives in easy-to-edit Markdown + JSON — no CMS, no database
- Clean Scandinavian-minimal design (self-hosted Fraunces + Inter fonts)

## Local development

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # outputs static site to dist/
npm run preview  # serve the production build locally
```

## Project structure

```
src/
  assets/            # source images (optimized at build time by astro:assets)
    projects/<slug>/ # gallery images per project (00.jpg is the cover)
    about/           # about-page photos
    home/            # home hero image (hero.*)
  content/projects/  # one Markdown file per project
  data/
    site.json        # name, contact, socials, home about blurb
    about.json       # about-page bio paragraphs
    resume.json      # structured resume content
    manifest.json    # maps image files -> alt text (auto-generated)
  components/         # Nav, Footer, Hero, ProjectCard, Gallery
  layouts/           # BaseLayout
  pages/             # index, portfolio, portfolio/[slug], about, resume
public/
  resume.pdf         # downloadable resume
```

## Editing content

### Add or edit a project

1. Create `src/content/projects/<slug>.md`:

   ```markdown
   ---
   title: "My New Project"
   category: featured   # featured | other | internship
   order: 0             # sort order within its category
   meta:
     When: "Spring 2024"
     Class: "Studio IV"
     Professor: "Jane Doe"
     School: "Endicott College"
     Programs: "Revit, Enscape"
   ---

   Your project description in Markdown. Use **Abstract:**, **Concept:**, etc.
   ```

2. Drop the images in `src/assets/projects/<slug>/`, named so they sort in the
   order you want (`00.jpg`, `01.jpg`, ...). `00` is used as the cover and hero.

That's it — the project appears on the Portfolio page automatically.

### Update text / contact info

Edit the JSON files in `src/data/`. To replace the resume PDF, overwrite
`public/resume.pdf`.

### Change the home hero

Replace the file in `src/assets/home/` (keep a single image there).

## Deploying

The site deploys to **GitHub Pages** at the custom domain **izzypinzer.com**
via GitHub Actions. Every push to `main` triggers
`.github/workflows/deploy.yml`, which builds the Astro site and publishes it.

### One-time setup

1. In the repo, go to **Settings → Pages** and set **Source** to
   **GitHub Actions**.
2. Under **Settings → Pages → Custom domain**, enter `izzypinzer.com`
   (this matches `public/CNAME`, which is published to the site root).
3. Point DNS for `izzypinzer.com` at GitHub Pages:
   - Apex (`izzypinzer.com`) → four `A` records:
     `185.199.108.153`, `185.199.109.153`, `185.199.110.153`,
     `185.199.111.153` (and the matching `AAAA` records if you want IPv6).
   - `www` → `CNAME` to `ipinzer.github.io`.
4. Leave **Enforce HTTPS** checked once the certificate is issued.

`site` is set to `https://izzypinzer.com` and `base` is unset in
`astro.config.mjs`. To use the default project URL instead
(`https://ipinzer.github.io/izzypinzer.com/`), set `base: "/izzypinzer.com"`,
update `site`, and delete `public/CNAME`.

### Deploying changes

```bash
git add -A && git commit -m "Update content"
git push            # Actions builds and deploys automatically
```

### Other hosts

Any static host works: build with `npm run build` and serve the `dist/`
folder (e.g. Netlify/Cloudflare Pages — build command `npm run build`,
publish directory `dist`). A `scripts/deploy-fastmail.sh` helper for
Fastmail WebDAV hosting is also included.

## Notes

Images are downscaled to 2000px in the repo and further optimized at build time,
so pages stay sharp but load fast.
