-- Типы чатов: group (обычный) / channel (канал)
ALTER TABLE chats
ADD COLUMN type TEXT NOT NULL DEFAULT 'group'
CHECK (type IN ('group', 'channel'));

-- Владелец канала (для channel — создатель, для group может быть NULL)
ALTER TABLE chats
ADD COLUMN owner_id INTEGER
REFERENCES users(id)
ON DELETE SET NULL;

-- Роли участников: owner / admin / member
ALTER TABLE chat_users
ADD COLUMN role TEXT NOT NULL DEFAULT 'member'
CHECK (role IN ('owner', 'admin', 'member'));

-- Для существующих общих чатов (1,2,3) и личных — оставляем role='member'
-- А для всех существующих chat_users устанавливаем базовую роль (уже DEFAULT 'member')

-- Комментарии к постам: ссылка на родительское сообщение
ALTER TABLE messages
ADD COLUMN reply_to INTEGER
REFERENCES messages(id)
ON DELETE CASCADE;

-- Тип сообщения:
--   message — обычное сообщение в групповом чате
--   post    — пост владельца/админа канала
--   comment — комментарий подписчика к посту (reply_to обязателен)
ALTER TABLE messages
ADD COLUMN kind TEXT NOT NULL DEFAULT 'message'
CHECK (kind IN ('message', 'post', 'comment'));

-- Индекс для быстрой выборки комментариев к посту
CREATE INDEX IF NOT EXISTS idx_messages_reply_to
    ON messages(reply_to);
