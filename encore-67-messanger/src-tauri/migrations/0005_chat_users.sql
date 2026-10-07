CREATE TABLE IF NOT EXISTS chat_users (
    chat_id INTEGER NOT NULL
        REFERENCES chats(id)
        ON DELETE CASCADE,

    user_id INTEGER NOT NULL
        REFERENCES users(id)
        ON DELETE CASCADE,

    PRIMARY KEY (chat_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_users_user_id
    ON chat_users(user_id);

INSERT OR IGNORE INTO chat_users (chat_id, user_id)
SELECT chats.id, users.id
FROM chats
CROSS JOIN users;
