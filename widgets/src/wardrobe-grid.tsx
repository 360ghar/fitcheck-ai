import { useEffect } from "react";
import { createRoot } from "react-dom/client";
import { extractItems, firstImageUrl, toolOutput, useTheme, widgetApi } from "./lib/openai";
import "./theme.css";

interface Item {
  id?: string;
  name?: string;
  category?: string;
  brand?: string;
  colors?: unknown;
  image_url?: string | null;
  images?: { image_url?: string | null; thumbnail_url?: string | null }[];
  wear_count?: number;
  is_favorite?: boolean;
}

function normalizerColor(value: unknown): string {
  if (typeof value === "string") return value;
  if (value && typeof value === "object") {
    const name = (value as Record<string, unknown>).name;
    if (typeof name === "string") return name;
  }
  return "";
}

function App() {
  const theme = useTheme();
  const items = extractItems<Item>(toolOutput());

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
  }, [theme]);

  return (
    <div>
      <h2 className="heading">
        Wardrobe{items.length ? ` · ${items.length} item${items.length === 1 ? "" : "s"}` : ""}
      </h2>
      {items.length === 0 ? (
        <p className="empty">No wardrobe items found for this view.</p>
      ) : (
        <div className="grid">
          {items.map((item, index) => (
            <figure className="card" key={item.id ?? index} style={{ margin: 0 }}>
              {firstImageUrl(item) ? (
                <img className="thumb" src={firstImageUrl(item) ?? undefined} alt={item.name ?? "item"} loading="lazy" />
              ) : (
                <div className="thumb" aria-hidden="true" />
              )}
              <figcaption className="card-body">
                <p className="title">{item.name ?? "Untitled item"}</p>
                <p className="meta">
                  {[item.brand, item.category].filter(Boolean).join(" · ") ||
                    normalizerColor(item.colors?.[0])}
                </p>
                {item.is_favorite ? <span className="badge">Favorite</span> : null}
                {typeof item.wear_count === "number" && item.wear_count > 0 ? (
                  <span className="badge">Worn {item.wear_count}×</span>
                ) : null}
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
