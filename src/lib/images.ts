import type { ImageMetadata } from "astro";
import manifest from "../data/manifest.json";

type Img = { src: ImageMetadata; alt: string; file: string };

const projectFiles = import.meta.glob<{ default: ImageMetadata }>(
  "../assets/projects/**/*.{jpg,jpeg,png,JPG,JPEG,PNG}",
  { eager: true },
);
const aboutFiles = import.meta.glob<{ default: ImageMetadata }>(
  "../assets/about/*.{jpg,jpeg,png,JPG,JPEG,PNG}",
  { eager: true },
);
const homeFiles = import.meta.glob<{ default: ImageMetadata }>(
  "../assets/home/*.{jpg,jpeg,png,JPG,JPEG,PNG}",
  { eager: true },
);

const projectManifest = manifest.projects as Record<
  string,
  { file: string; alt: string }[]
>;
const aboutManifest = manifest.about as { file: string; alt: string }[];

function cleanAlt(alt: string, fallback: string): string {
  if (!alt) return fallback;
  const stripped = alt
    .replace(/\.(jpe?g|png|heic|gif)$/i, "")
    .replace(/_edited$/i, "");
  const words = stripped.replace(/[_-]+/g, " ").trim();
  return words || fallback;
}

/** Ordered gallery images for a project slug. */
export function projectImages(slug: string): Img[] {
  const entries = Object.entries(projectFiles)
    .filter(([path]) => path.includes(`/projects/${slug}/`))
    .sort(([a], [b]) => a.localeCompare(b));
  const altFor = (file: string) =>
    projectManifest[slug]?.find((m) => m.file === file)?.alt ?? "";
  return entries.map(([path, mod]) => {
    const file = path.split("/").pop()!;
    return {
      src: mod.default,
      file,
      alt: cleanAlt(altFor(file), "Interior render"),
    };
  });
}

export function projectCover(slug: string, preferredFile?: string): Img | undefined {
  const imgs = projectImages(slug);
  if (preferredFile) {
    return imgs.find((img) => img.file === preferredFile) ?? imgs[0];
  }
  return imgs[0];
}

export function aboutImages(): Img[] {
  const entries = Object.entries(aboutFiles).sort(([a], [b]) =>
    a.localeCompare(b),
  );
  return entries.map(([path, mod]) => {
    const file = path.split("/").pop()!;
    const alt = aboutManifest?.find((m) => m.file === file)?.alt ?? "";
    return { src: mod.default, file, alt: cleanAlt(alt, "Izzy Pinzer") };
  });
}

export function homeHero(): ImageMetadata {
  const entry = Object.values(homeFiles)[0];
  return entry.default;
}
