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

### Fastmail file hosting (custom domain)

Fastmail serves a static site from a folder in your file storage. **Do not
drag the whole `dist` folder into the Fastmail web UI** — browser folder-drag
uploads silently drop files when there are many of them, so images end up
404ing. Use WebDAV instead, via the included script:

1. Create a Fastmail **app password** with *Files (WebDAV)* access
   (Settings → Privacy & Security → App passwords).
2. Build, then export your credentials and deploy:

   ```bash
   npm run build

   export FM_USER="you@yourdomain"     # your full Fastmail login
   export FM_PASS="the-app-password"

   # Find the folder that serves your site:
   ./scripts/deploy-fastmail.sh list

   # Upload every file into that folder (with retries + verification):
   FM_TARGET="/izzy.pinzer.family" ./scripts/deploy-fastmail.sh deploy
   ```

   The script uploads each file individually over WebDAV and then verifies a
   sample of images are live. Re-run `deploy` to retry if anything failed.

### GitHub Pages (included workflow)

1. Push this repo to GitHub.
2. In **Settings -> Pages**, set **Source** to **GitHub Actions**.
3. Every push to `main` builds and deploys via `.github/workflows/deploy.yml`.

If you deploy to a **project** page (`https://<user>.github.io/<repo>`), set the
matching `base` in `astro.config.mjs`, e.g. `base: "/izzy-portfolio"`. For a
custom domain or `https://<user>.github.io` user page, leave `base` unset and
update `site` to your domain.

### Netlify / Cloudflare Pages

Build command `npm run build`, publish directory `dist`. No other config needed.

## Notes

Images are downscaled to 2000px in the repo and further optimized at build time,
so pages stay sharp but load fast.
