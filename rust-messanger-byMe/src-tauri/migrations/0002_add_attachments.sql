-- Добавляем колонку для вложенных файлов (JSON массив путей)
ALTER TABLE messages ADD COLUMN attachments TEXT NULL;
