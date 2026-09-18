// Импорт типов, необходимых для migrations
use tauri_plugin_sql::{Migration, MigrationKind};

// Аннотация небходимая Tauri для мобильных платформ
// На Win она не мешает
#[cfg_attr(mobile, tauri::mobile_entry_point)]

#[tauri::command]
fn save_attachment(source: String) -> Result<String, String> {
    // Берём папку с Cargo.toml = src-tauri/. Надёжнее current_dir
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|_| std::env::current_dir().unwrap());

    // Поднимаемся ВВЕРХ на 1 уровень → rust-messanger-byMe/ (корень фронтенда)
    let project_root = manifest_dir
        .parent()
        .ok_or("Не определить корень проекта".to_string())?;

    // ✅ Папка attachment теперь ВНУТРИ КОРНЯ ПРОЕКТА, но СНАРУЖИ src-tauri/
    // → cargo watch её не видит → НЕТ РЕБИЛДОВ
    let attachment_dir = project_root.join("attachment");

    std::fs::create_dir_all(&attachment_dir)
        .map_err(|e| e.to_string())?;

    let path = std::path::Path::new(&source);
    let extension = path.extension()
        .map(|ext| ext.to_string_lossy().to_string())
        .unwrap_or_else(|| "bin".to_string());

    let timestamp = chrono::Utc::now().timestamp();
    let file_name = format!("image_{}.{}", timestamp, extension);
    let destination = attachment_dir.join(&file_name);

    std::fs::copy(source, &destination)
        .map_err(|e| e.to_string())?;

    // ✅ ВОЗВРАЩАЕМ АБСОЛЮТНЫЙ ПУТЬ, а не "attachment/..."
    // convertFileSrc требует именно абсолютный путь для asset://
    Ok(destination.to_string_lossy().to_string())
}



//// Главная функция для запуска приложения
pub fn run() {
    // Создание списка миграций
    let migrations = vec![
        // Описание первой миграции
        Migration {
            version: 1,

            description: "create_message_table",

            // Берем SQL запрос из нашего файла
            sql: include_str!("../migrations/0001_initial.sql"),

            // up означает, что база сдвинется вперед
            kind: MigrationKind::Up,
        },
        Migration {
            version: 2,
            description: "create_chats",
            sql: include_str!("../migrations/0002_chats.sql"),
            kind: MigrationKind::Up,
        },
        Migration {
            version: 3,
            description: "message_attachments",
            sql: include_str!("../migrations/003_message_attachments.sql"),
            kind: MigrationKind::Up,
        },
        Migration {
            version: 4,
            description: "allow_null_body",
            sql: include_str!("../migrations/004_allow_null_body.sql"),
            kind: MigrationKind::Up,
        },
    ];

    // Создаем сбощик приложения Tauri
    tauri::Builder::default()
        // Подключаем sql плагин
        .plugin(
            // Сборщик плагинов
            tauri_plugin_sql::Builder::default()
                // Связываем migrations с базой sql
                .add_migrations("sqlite:messenger.db", migrations)
                // Собираем плагины
                .build(),
        )
        // Создаем plugin opener
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_opener::init())
        // Запускаем приложение
                .invoke_handler(
            tauri::generate_handler![save_attachment]
        )      
        .run(tauri::generate_context!())
        // Если запуск завершился с ошибкой, то сообщем об этом
        .expect("Ошиюка при сборке приложения");
}
