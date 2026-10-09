CREATE TABLE IF NOT EXISTS chat_settings (
    user_id INTEGER NOT NULL
        REFERENCES users(id)
        ON DELETE CASCADE,

    chat_id INTEGER NOT NULL
        REFERENCES chats(id)
        ON DELETE CASCADE,

    wallpaper_path TEXT,

    PRIMARY KEY (user_id, chat_id)
);
