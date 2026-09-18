-- SQLite workaround: пересоздаём таблицу с новым ограничением
CREATE TABLE IF NOT EXISTS messages_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    author TEXT NOT NULL,
    body TEXT NULL,                          -- ← теперь разрешён NULL
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    chat_id INTEGER NOT NULL DEFAULT 1,
    type TEXT NOT NULL DEFAULT 'text',
    attachment TEXT NULL
);

-- Копируем все старые данные
INSERT INTO messages_new (id, author, body, created_at, chat_id, type, attachment)
SELECT id, author, body, created_at, chat_id, type, attachment FROM messages;

-- Удаляем старую таблицу и переименовываем новую
DROP TABLE messages;
ALTER TABLE messages_new RENAME TO messages;