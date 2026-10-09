export interface Chat{
    id: number;
    title: string;
    subtitle: string;
}

export interface ChatSettingsUpdate{
    chatId: number;
    userId: number;
    wallpaperPath: string | null;
}

export interface ChatSettings{
    user_id: number;
    chat_id: number;
    wallpaper_path: string | null;
}