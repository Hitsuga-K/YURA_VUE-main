CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  avatar_path TEXT,
  status TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO users (
  id, username, display_name, status
)
VALUES (
  1,
  'KillYura',
  'Юра',
  'В сети'
);
INSERT OR IGNORE INTO users (
  id, username, display_name, status
)
VALUES (
  2,
  'DanielSigma',
  'Даниэль',
  'В сети'
);

INSERT OR IGNORE INTO users (
  id, username, display_name, status
)
VALUES (
  3,
  'MishaHi',
  'Миша',
  'В сети'
);

INSERT OR IGNORE INTO users(
  username,
  display_name
)
SELECT 
-- Технически user name legacy_1 legacy_2 ...
-- CAST превращает число в текст
  'legacy_' || CAST(old_authors.first_message_id AS TEXT)

  old_authors.author
FROM(
  -- MIN(id) берём самый маленький айди сообщения для этого пользователя
  SELECT 
    MIN(id) AS first_message_id,
    author
    
  FROM messages
  -- Создаёт одну группу для каждого имени автора
  GROUP BY author
) AS old_authors

WHERE NOT EXISTS(
  SELECT 1
  FROM users
  WHERE users.display_name = old_authors.author
)



CREATE TABLE messages_new(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chat_id INTEGER NOT NULL,
    PREFERENCES chats(id) 
    ON DELETE CASCADE, -- Связанные с ним соообщения также буду удалены

  author_id INTEGER NOT NULL  
    REFERENCES users(id) -- ССылка на users.id
    ON DELETE RESTRICT, --  Ytkmpz elfkbnm gjkmpjdfntkz tckb yf ytuj ccskftncz cjj,otybt
  
  type TEXT NOT NULL DEFAULT 'text'

  body TEXT,

  attachment TEXT,

  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,


  -- Проверяет и разрешает только типы из данного списка
  CHECK(
    type IN(
      'text',
      'image'
    )
  )
);

INSERT INTO messages_new(
  id, 
  chat_id,
  author_id, 
  type, 
  body, 
  attachment, 
  created_at
) 
  SELECT 
    messages.id,
    messages.chat_id,
  (
    SELECT users.id
    FROM users

    WHERE 
      users.display_name = messages.author

    ORDER BY users.id ASC
    LIMIT 1
  ),
  messages.type,
  messages.body,
  messages.attachment,
  messages.created_at
FROM messages;

DROP TABLE messages;

ALTER TABLE messages_new
RENAME TO messages;


-- Индексы нужны для более быстрого поиска по сообщению или автору
CREATE INDEX IF NOT EXISTS
idx_messages_chat_id
ON messages(chat_id);

CREATE INDEX IF NOT EXISTS
idx_messages_author_id
ON messages(author_id);