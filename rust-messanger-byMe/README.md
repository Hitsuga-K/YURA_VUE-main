# 🦀 Rust-Messenger (byMe)

Локальный десктопный мессенджер, построенный на **Tauri 2**, **Vue 3**, **TypeScript** и **SQLite**. Все сообщения сохраняются локально на устройстве.

---

## 🛠 Стек технологий

| Слой | Технология |
|---|---|
| 🖥 Десктоп-обёртка | [Tauri 2](https://tauri.app/) |
| 🦀 Бэкенд (нативный) | Rust 2021 Edition |
| 💾 База данных | SQLite через `tauri-plugin-sql` |
| 🎨 Фронтенд | Vue 3 (Composition API / `<script setup>`) |
| ⚡ Сборщик фронтенда | Vite 6 |
| 🔷 Типизация | TypeScript 5.6 |

---

## 📋 Предварительные требования

Перед запуском убедитесь, что на компьютере установлены:

### 1. Node.js и npm
- **Версия:** Node.js ≥ 18 (рекомендуется LTS)
- Скачать: [nodejs.org](https://nodejs.org/)
- Проверка:
  ```bash
  node --version
  npm --version
  ```

### 2. Rust и Cargo
- Установка через `rustup`: [rustup.rs](https://rustup.rs/)
- Проверка:
  ```bash
  rustc --version
  cargo --version
  ```

### 3. Зависимости для сборки Tauri (Windows)
На Windows достаточно установить **Visual Studio Build Tools 2022** с компонентом «Разработка классических приложений на C++». Это стандартная настройка Tauri.

Детальная инструкция для всех ОС: [Tauri Prerequisites](https://v2.tauri.app/start/prerequisites/)

---

## 🚀 Быстрый старт (3 шага)

Склонируйте репозиторий и выполните в корне проекта:

### Шаг 1 — Установить npm-зависимости фронтенда
```bash
npm install
```

### Шаг 2 — Запустить приложение в режиме разработки
```bash
npm run tauri dev
```

Под капотом эта команда:
1. Запускает `vite` dev server на `http://localhost:1420`
2. Компилирует Rust-код бэкенда
3. Открывает окно приложения Tauri

⏱ **Первый запуск долгий** — Rust компилирует все зависимости с нуля. Последующие запуски будут гораздо быстрее за счёт кеша Cargo.

### Шаг 3 — Готово!
В интерфейсе появится окно чата. Введите текст в поле внизу и нажмите **Send** — сообщения сохраняются в локальной SQLite-базе.

---

## 🏗 Сборка релизной версии

Чтобы получить готовый `.exe` (Windows), `.dmg` (macOS) или `.deb` (Linux):

```bash
npm run tauri build
```

Собранные установщики и бинарники будут лежать в:
```
src-tauri/target/release/bundle/
```

---

## 📁 Структура проекта

```
rust-messanger-byMe/
├── src/                          # Код фронтенда (Vue + TS)
│   ├── App.vue                   # Главный компонент: чат, ввод сообщений, работа с БД
│   └── main.ts                   # Точка входа Vue-приложения
│
├── src-tauri/                    # Код бэкенда (Rust + Tauri)
│   ├── src/
│   │   ├── main.rs               # Бин: просто вызывает run() из lib.rs
│   │   └── lib.rs                # Инициализация Tauri, подключение SQL-плагина и миграций
│   ├── migrations/
│   │   └── 0001_initial.sql      # Схема БД: таблица `messages`
│   ├── capabilities/
│   │   └── default.json          # Разрешения (permissions) для фронтенда
│   ├── Cargo.toml                # Зависимости Rust
│   └── tauri.conf.json           # Конфиг Tauri (название, окно, сборка)
│
├── package.json                  # Зависимости и скрипты npm
├── vite.config.ts                # Конфигурация Vite
├── tsconfig.json                 # Конфигурация TypeScript
└── .gitignore                    # Игнор-лист для Git
```

---

## 💾 Работа с базой данных

- **Тип:** SQLite (файл локально на диске)
- **Путь к файлу** (Windows):
  ```
  %APPDATA%\com.copm11.rust-messanger-byme\messanger.db
  ```
- **Таблица:** `messages`
  | Поле | Тип | Описание |
  |---|---|---|
  | `id` | INTEGER PK AI | Уникальный номер |
  | `author` | TEXT NOT NULL | Автор сообщения |
  | `body` | TEXT NOT NULL | Текст сообщения |
  | `created_at` | TEXT DEFAULT CURRENT_TIMESTAMP | Время создания |

### ⚠️ Если появилась ошибка «migration 1 was previously applied but has been modified»

Это значит, что вы отредактировали файл `src-tauri/migrations/0001_initial.sql` **после** того, как база уже была создана. Tauri сравнивает хеши SQL и блокирует запуск для защиты данных.

**Как исправить:**
1. Закройте приложение
2. Удалите файл БД (путь указан выше)
3. Запустите приложение заново — миграция применится заново

---

## 📜 Доступные npm-скрипты

| Команда | Действие |
|---|---|
| `npm run dev` | Запустить только Vite dev server (без Tauri-окна) |
| `npm run build` | Собрать фронтенд в папку `dist/` (Vue TS check + Vite build) |
| `npm run preview` | Локально посмотреть собранный фронтенд |
| `npm run tauri dev` | **Основной способ разработки** — запустить Tauri с HMR |
| `npm run tauri build` | Собрать релизный инсталлятор приложения |

---

## 💡 Рекомендуемые расширения для IDE

### JetBrains (RustRover / WebStorm)
- Tauri (из маркетплейса)
- Vue.js
- Rust (встроен в RustRover)

### VS Code
Список рекомендуемых расширений уже сохранён в `.vscode/extensions.json`:
- [Vue - Official](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
- [Tauri](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode)
- [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)

---

## 🔍 Отладка

### DevTools в окне Tauri
В режиме разработки нажмите `F12` или правой кнопкой → «Inspect», чтобы открыть DevTools WebView.

### Консоль бэкенда (Rust)
Логи из Rust выводятся в терминал, из которого вы запустили `npm run tauri dev`.

---
