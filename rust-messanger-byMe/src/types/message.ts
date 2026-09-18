// Ключевое слово export
// Разрешает другим файлам испортить его
export interface Message{
    id: number;
    author: string;
    type: "text" | "image";
    body: string;
    attachment: string | null;
    created_at: string;
}