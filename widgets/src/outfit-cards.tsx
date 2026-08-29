import { useEffect } from "react";
import { createRoot } from "react-dom/client";
import { extractList, toolOutput, useTheme, widgetApi } from "./lib/openai";
import "./theme.css";

interface Outfit {
  id?: string;
  name?: string;
  description?: string;
  tags?: unknown;
  occasion?: string;
  image_url?: string | null;
  items?: { name?: string }[];
}

function firstTag(value: unknown): string {
  if (Array.isArray(value)) return typeof value[0] === "string" ? value[0] : "";
  if (typeof value === "string") return value;
  return "";
}

function App() {
  const theme = useTheme();
  const outfits = extractList<Outfit>(toolOutput());

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
  }, [theme]);

  return (
    <div>
      <h2 className="heading">
        Outfits{outfits.length ? ` · ${outfits.length}` : ""}
      </h2>
      {outfits.length === 0 ? (
        <p className="empty">No outfits found for this view.</p>
      ) : (
        <div className="grid">
          {outfits.map((outfit, index) => (
            <figure className="card" key={outfit.id ?? index} style={{ margin: 0 }}>
              {outfit.image_url ? (
                <img className="thumb" src={outfit.image_url} alt={outfit.name ?? "outfit"} loading="lazy" />
              ) : (
                <div className="thumb" aria-hidden="true" />
              )}
              <figcaption className="card-body">
                <p className="title">{outfit.name ?? "Untitled outfit"}</p>
                <p className="meta">
                  {outfit.occasion ||
                    firstTag(outfit.tags) ||
                    (outfit.items?.length ? `${outfit.items.length} pieces` : "")}
                </p>
              </figcaption>
            </figure>
          ))}
        </div>
      )}
      {widgetApi().callTool ? null : (
        <p className="empty" style={{ fontSize: 11 }}>
          (Preview mode — outside ChatGPT there is no tool data.)
        </p>
      )}
    </div>
  );
}

createRoot(document.getElementById("root")!).render(<App />);
