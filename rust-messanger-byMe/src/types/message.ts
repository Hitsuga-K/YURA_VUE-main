// Ключевое слово export
// Разрещает другим файлам экспортить его

export interface Message{
    id: number;
    author: string;
    body: string;
    created_at: string;
    attachments?: string[] | null;
}