import { convertFileSrc } from "@tauri-apps/api/core";

export function getFileSrc(path: string) {
  // Если путь относительный (старая запись в БД attachment/...)
  if (path.startsWith("attachment/") || path.startsWith("attachment\\")) {
    // Браузер — запрос к Vite localhost; Tauri WebView — тоже работает (asset поймёт)
    return `/${path.replace(/\\/g, "/")}`;
  }

  // Абсолютный путь Windows "C:\..."
  const isAbsoluteWin = /^[A-Za-z]:[\\/]/.test(path);
  if (isAbsoluteWin) {
    try {
      // ✅ В окне Tauri: через asset:// протокол
      return convertFileSrc(path);
    } catch {
      // ✅ В браузере localhost:1420: парсим имя файла и запрашиваем через /attachment
      const normalized = path.replace(/\\/g, "/");
      const match = normalized.match(/\/attachment\/(.+)$/);
      return match ? `/attachment/${match[1]}` : path;
    }
  }

  return path;
}// Теперь asset://localhost//.../attachment/image.png
