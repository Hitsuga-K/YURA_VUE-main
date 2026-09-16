// Импорт типов, необходимых для migrations
use tauri_plugin_sql::{Migration, MigrationKind};

// Аннотация небходимая Tauri для мобильных платформ
// На Win она не мешает
#[cfg_attr(mobile, tauri::mobile_entry_point)]

#[tauri::command]
fn save_attachment(source: String) -> Result<String, String> {
    let app_dir = std::env::current_dir() // Проверка где сейчас  лежит приложение
        .map_err(|e| e.to_string())?; // map_err функция возможной ошибкой например нет доступа
    let attachment_dir = app_dir.join("attachment"); // join буквально создат к существующему пути до папки новую папку "attachment"
    
    // fs = filesistem - для работы с файлами
    std::fs::create_dir_all(&attachment_dir)
        .map_err(|e| e.to_string())?;

let path = std::path::Path::new(&source);

    let extension = match path.extension() {
        Some(ext) => ext.to_string_lossy().to_string(),
         None => "bin".to_string(),
    };

    let timestamp = chrono::Utc::now().timestamp();
    let file_name = format!("image_{}.{}", timestamp, extension);
    
    let destination = attachment_dir.join(&file_name);
    
    // Копируем файл из source в destination
    std::fs::copy(source, &destination)
        .map_err(|e| e.to_string())?;
    
    Ok(
        format!(
            "attachment/{}",
            file_name
        )
    )
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
