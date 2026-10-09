<script setup lang="ts">

import { onMounted, ref, computed } from "vue";

import type { User } from "./types/user";
import { ProfileUpdate } from "./types/user";

import Database from "@tauri-apps/plugin-sql";

import AppHeader from "./components/AppHeader.vue";
import MessageList from "./components/MessageList.vue";
import MessageComposer from "./components/MessageComposer.vue";
import ChatSidebar from "./components/ChatSidebar.vue";
import ChatSettings from "./components/ChatSettings.vue";
import ProfilerEditor from "./components/ProfilerEditor.vue";
import CreateUser from "./components/CreateUser.vue";
import type { NewUserData } from "./components/CreateUser.vue";
import ImageViewer from "./components/ImageViewer.vue";

import type { Chat, ChatSettingsUpdate } from "./types/chats";
import type { Message } from "./types/message.ts";
import { getFileUrl } from "./types/file.ts";

const isProfileOpen = ref(false);
const isCreateUserOpen = ref(false);

const openImageSrc = ref<string | null>(null);

function openProfile(){
  isProfileOpen.value = true;
}

function closeProfile(){
  isProfileOpen.value = false;
}

function openCreateUser(){
  isCreateUserOpen.value = true;
}

function closeCreateUser(){
  isCreateUserOpen.value = false;
}

async function createUser(data: NewUserData) {
  if (!db) return;

  const existing = await db.select<{ exists: number }[]>(
    `SELECT 1 AS exists FROM users WHERE username = $1 LIMIT 1`,
    [data.username],
  );

  if (existing.length > 0) {
    alert(`Username "${data.username}" уже занят`);
    return;
  }

  const result = await db.execute(
    `
      INSERT INTO users (username, display_name, status, avatar_path)
      VALUES ($1, $2, $3, $4)
    `,
    [
      data.username,
      data.displayName,
      data.status,
      data.avatarPath,
    ],
  );

  const newUserId =
    typeof result.lastInsertId === "number"
      ? result.lastInsertId
      : Number(result.lastInsertId);

  await db.execute(
    `
      INSERT INTO chat_users (chat_id, user_id)
      SELECT chats.id, $1
      FROM chats
      WHERE chats.id IN (1, 2, 3)
      ON CONFLICT DO NOTHING
    `,
    [newUserId],
  );

  closeCreateUser();

  await loadUsers();
  await loadChatWallpapers();

  const newUser = users.value.find(u => u.id === newUserId);
  if (newUser) {
    await selectUser(newUser);
  }
}

function openImage(src: string){
  openImageSrc.value = src;
}

function closeImage(){
  openImageSrc.value = null;
}

async function saveProfile(profile:ProfileUpdate,) {
  if(!db) return;

  if(!currentUser.value) return;

  await db.execute(
    `
      UPDATE users

      SET
        display_name = $1,
        status = $2,
        avatar_path = $3

      WHERE id = $4
    `,
    [
      profile.displayName,
      profile.status,
      profile.avatarPath,
      currentUser.value?.id,
    ],
  );

  currentUser.value.display_name = profile.displayName;
  currentUser.value.status = profile.status;
  currentUser.value.avatar_path = profile.avatarPath;

  users.value = users.value.map(u =>
    u.id === currentUser.value?.id ? { ...currentUser.value } : u
  );

  if(activeChat.value){
    await loadMessages(
      activeChat.value.id,
    )
  }
};

const users = ref<User[]>([]);

const messageText = ref("");

const editingMessageId = ref<number | null>(null);

const currentUser = ref<User | null>(null);

async function selectUser(user: User) {
  currentUser.value = user;

  await loadChats();
  await loadChatWallpapers();

  const savedChatId = userActiveChats.value[user.id];

  if (savedChatId !== undefined) {
    const chat = chats.value.find(
      chat => chat.id === savedChatId
    );

    if (chat) {
      await selectChat(chat);
      return;
    }
  }

  if (chats.value.length > 0) {
    await selectChat(chats.value[0]);
  }
}

// Создаем структуру одного сообщения

// Список сообщений, которые vue отображет в диалоге на экране
const messages = ref<Message[]>([]);

const chats = ref<Chat[]>([]);

const unreadCounts = ref<Record<number, number>>({});

const lastReadMessageId = ref<Record<number, number>>({});

const activeChat = ref<Chat | null>(null);


const activeChatId = ref(1);

const userActiveChats = ref<Record<number, number>>({});

const chatWallpapers = ref<Record<number, string | null>>({});

const isChatSettingsOpen = ref(false);

const settingsChat = ref<Chat | null>(null);

const currentChatWallpaper = computed<string | null>(() => {
  if (!activeChat.value) return null;
  const path = chatWallpapers.value[activeChat.value.id];
  if (!path) return null;
  return getFileUrl(path);
});

const chatStyle = computed<Record<string, string> | undefined>(() => {
  if (currentChatWallpaper.value) {
    return {
      backgroundImage: `url(${currentChatWallpaper.value})`,
      backgroundSize: "cover",
      backgroundPosition: "center center",
      backgroundRepeat: "no-repeat",
    };
  }
  return undefined;
});
// Статус подключения к бд
const status = ref("Подключение...")

// Здесь будет подключение к бд (честно), но пока тут null
let db: Database | null = null;


async function loadChats(){
  if (!db) return;
  if (!currentUser.value) return;

  chats.value = await db.select<Chat[]>(
    `
      SELECT
        chats.id,
        chats.title,
        chats.subtitle
      FROM chats
      INNER JOIN chat_users
        ON chat_users.chat_id = chats.id
      WHERE chat_users.user_id = $1
      ORDER BY chats.id ASC
    `,
    [currentUser.value.id],
  );

  if (chats.value.length > 0){
    await selectChat(chats.value[0]);
  }
}

async function createChatWith(peer: User) {
  if (!db) return;
  if (!currentUser.value) return;
  if (peer.id === currentUser.value.id) return;

  const existing = await db.select<{ chat_id: number }[]>(
    `
      SELECT cu1.chat_id
      FROM chat_users cu1
      INNER JOIN chat_users cu2
        ON cu2.chat_id = cu1.chat_id
      WHERE cu1.user_id = $1
        AND cu2.user_id = $2
        AND (
          SELECT COUNT(*)
          FROM chat_users cu3
          WHERE cu3.chat_id = cu1.chat_id
        ) = 2
      LIMIT 1
    `,
    [currentUser.value.id, peer.id],
  );

  if (existing.length > 0) {
    const chat = chats.value.find(c => c.id === existing[0].chat_id);
    if (chat) {
      await selectChat(chat);
      return;
    }
  }

  const title = `${currentUser.value.display_name} и ${peer.display_name}`;
  const subtitle = `Личный чат`;

  const result = await db.execute(
    `
      INSERT INTO chats (title, subtitle)
      VALUES ($1, $2)
    `,
    [title, subtitle],
  );

  const chatId =
    typeof result.lastInsertId === "number"
      ? result.lastInsertId
      : Number(result.lastInsertId);

  await db.execute(
    `
      INSERT INTO chat_users (chat_id, user_id)
      VALUES ($1, $2), ($1, $3)
    `,
    [chatId, currentUser.value.id, peer.id],
  );

  await loadChats();

  const newChat = chats.value.find(c => c.id === chatId);
  if (newChat) {
    await selectChat(newChat);
  }
}

async function selectChat(chat: Chat) {

  activeChat.value = chat;

  activeChatId.value = chat.id;

  if (currentUser.value) {
    userActiveChats.value[currentUser.value.id] = chat.id;
  }

  await loadMessages(chat.id);

  if (messages.value.length > 0) {
    const lastMessage =
      messages.value[messages.value.length - 1];

    lastReadMessageId.value[chat.id] = lastMessage.id;
  }

  unreadCounts.value[chat.id] = 0;
}

async function loadChatWallpapers() {
  if (!db) return;
  if (!currentUser.value) return;

  chatWallpapers.value = {};

  const rows = await db.select<{ chat_id: number; wallpaper_path: string | null }[]>(
    `
      SELECT chat_id, wallpaper_path
      FROM chat_settings
      WHERE user_id = $1
    `,
    [currentUser.value.id],
  );

  for (const row of rows) {
    chatWallpapers.value[row.chat_id] = row.wallpaper_path;
  }
}

async function saveChatSettings(settings: ChatSettingsUpdate) {
  if (!db) return;
  if (!currentUser.value) return;

  await db.execute(
    `
      INSERT INTO chat_settings (user_id, chat_id, wallpaper_path)
      VALUES ($1, $2, $3)
      ON CONFLICT(user_id, chat_id)
      DO UPDATE SET wallpaper_path = excluded.wallpaper_path
    `,
    [currentUser.value.id, settings.chatId, settings.wallpaperPath],
  );

  chatWallpapers.value[settings.chatId] = settings.wallpaperPath;

  closeChatSettings();
}

function openChatSettings(chat: Chat) {
  settingsChat.value = chat;
  isChatSettingsOpen.value = true;
}

function closeChatSettings() {
  isChatSettingsOpen.value = false;
  settingsChat.value = null;
}

async function updateUnreadCounts() {
  if (!db) return;
  if (!currentUser.value) return;

  for (const chat of chats.value) {
    if (chat.id === activeChat.value?.id) {
      unreadCounts.value[chat.id] = 0;
      continue;
    }

    const lastReadId = lastReadMessageId.value[chat.id] ?? 0;

    const result = await db.select<{ count: number }[]>(
      `
        SELECT COUNT(*) AS count
        FROM messages
        WHERE chat_id = $1
          AND id > $2
      `,
      [chat.id, lastReadId],
    );

    unreadCounts.value[chat.id] = result[0]?.count ?? 0;
  }
}

// Асинхронная функция загрузки сообщений из sql
async function loadMessages(chatId: number){
  // Если база еще не подключена, прерываем выполнение
  if (!db) return;

  // Читаем данные из таблицы messages
  messages.value = await db.select<Message[]>(
    `
      SELECT 
        messages.id, 
        messages.chat_id, 
        messages.author_id, 
        users.display_name AS author_name,
        users.avatar_path AS author_avatar,
        messages.type, 
        messages.body, 
        messages.attachment, 
        messages.created_at 
      FROM messages 
      INNER JOIN users
        -- Возвращает только строки для которых нашёлся соотв. User
        ON users.id = messages.author_id
      WHERE messages.chat_id = $1 
      ORDER BY messages.id ASC
    `,
      [chatId],
  );
}

async function loadUsers() {
  if(!db) return 

  users.value =
    await db.select<User[]>(
      `
        SELECT
          id,
          username,
          display_name,
          avatar_path,
          status,
          created_at
        FROM users
        ORDER BY id ASC
      `
    );
  if(users.value.length > 0 && currentUser.value === null){
    currentUser.value = users.value[0];
  }
}
function startEditing(message: Message) {
  if (message.author_id !== currentUser.value?.id) return;

  editingMessageId.value = message.id;
  messageText.value = message.body ?? "";
}

// Функция отправки нового сообщения
async function sendMessage(body: string) {
  if (!db) return;
  if (!activeChat.value) return;
  if (!currentUser.value) return;

  if (editingMessageId.value !== null) {
    await db.execute(
      `
        UPDATE messages
        SET body = $1
        WHERE id = $2
      `,
      [
        body,
        editingMessageId.value,
        currentUser.value.id,
        activeChat.value.id,
      ],
    );

    editingMessageId.value = null;

    await loadMessages(activeChat.value.id);

    return;
  }

  // Если это новое сообщение
  await db.execute(
    `
      INSERT INTO messages (
        chat_id,
        author_id,
        type,
        body,
        attachment
      )
      VALUES ($1, $2, $3, $4, $5)
    `,
    [
      activeChat.value.id,
      currentUser.value.id,
      "text",
      body,
      null,
    ],
  );

  await loadMessages(activeChat.value.id);
}

async function deleteMessage(message: Message) {
  if (!db) return;
  if (!activeChat.value) return;
  if (!currentUser.value) return;

  await db.execute(
    `
      DELETE FROM messages
      WHERE id = $1
    `,
    [
      message.id
    ],
  );

  await loadMessages(activeChat.value.id);
}

async function sendImage(path:string){
  if(!db)
    return;                 

  if (!activeChat.value)
    return;

  if (!currentUser.value) return;

  await db.execute(
      `
        INSERT INTO messages
        (
           chat_id,
           author_id,
           type,
           body,
           attachment
        )

        VALUES
        (
            $1,
            $2,
            $3,
            $4,
            $5
        )
      `,
      [
          activeChat.value.id,
          currentUser.value.id,
          "image",
          "null",
          path,
      ]
  );

  await loadMessages(
      activeChat.value.id
  )
}

// VUE выполнит код ниже, когда интерфейс программы уже загрузится
onMounted(async()=>{
  try{
    // Открываем бд
    db = await Database.load("sqlite:messenger.db");

    await loadUsers();
    // Загружаем из базы старые сообщения
    await loadChats();
    await loadChatWallpapers();
    await updateUnreadCounts();

    setInterval(() => {
      updateUnreadCounts();
    }, 1000);
    // Показываем успешеное состоние
    status.value = "История сохраняется локально";
  }catch (error){
    console.error(error);

    status.value = "Ошибка подключения к базе";
  }
});

</script>

<template>
  <main class="app">
    <AppHeader
        v-if="currentUser"
        :status="status"
        :users="users"
        :current-user="currentUser"
        @select="selectUser"
        @profile="openProfile"
        @create-chat="createChatWith"
        @open-create-user="openCreateUser"

    />
    <div 
        v-if="currentUser"
        class="workspace">
      <ChatSidebar
          :chats="chats"
          :active-chat-id="activeChatId"
          :unread-counts="unreadCounts"
          @select="selectChat"
          @open-settings="openChatSettings"
      />
      <section
        class="chat"
        :class="{ 'chat--with-wallpaper': !!currentChatWallpaper }"
        :style="chatStyle"
      >
        <template v-if="activeChat">
      <MessageList
          :key="activeChat.id"
          :messages="messages"
          :current-user-id="currentUser.id"
          @open-image="openImage"
          @edit="startEditing"
          @delete="deleteMessage"
      />
      <MessageComposer
          v-model="messageText"
          @send="sendMessage"
          @sendImage="sendImage"
      />
        </template>
      </section>
    </div>
    <ProfilerEditor
      v-if="isProfileOpen && currentUser"
      :key="currentUser.id"
      :user="currentUser"
      @save="saveProfile"
      @close="closeProfile"
    />
    <CreateUser
      v-if="isCreateUserOpen"
      @save="createUser"
      @close="closeCreateUser"
    />
    <ChatSettings
      v-if="isChatSettingsOpen && settingsChat"
      :key="settingsChat.id"
      :chat="settingsChat"
      :current-wallpaper-path="chatWallpapers[settingsChat.id] ?? null"
      @save="saveChatSettings"
      @close="closeChatSettings"
    />
    <ImageViewer
      v-if="openImageSrc"
      :src="openImageSrc"
      @close="closeImage"
    />
  </main>
</template>

<style scoped>
/* Все элементы будут использовать одну модель размеров */
:global(*){
  box-sizing: border-box;
}

:global(html){
  background: #111318;
  color-scheme: dark;
}

:global(body){
  margin: 0;

  font-family:
  Inter,
  system-ui,
  -apple-system,
  BlinkMacSystemFont,
  "Segoe UI",
  sans-serif;

  color: #f2f3f5;

  background: #111318;
}

.workspace{
  flex: 1;
  min-height: 0;
  display: flex;
  overflow: hidden;
}

.app{
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #111318;
}

.chat{
  position: relative;
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #111318;
}

.chat--with-wallpaper::before{
  content: "";
  position: absolute;
  inset: 0;
  background: rgba(17, 19, 24, 0.62);
  z-index: 0;
  pointer-events: none;
}

.chat > *{
  position: relative;
  z-index: 1;
}

.chat-info{
  padding: 20px 24px;
  border-bottom: 1px solid #252830;
}

.chat-info h2{
  margin: 0;
  font-size: 16px;
}

.chat-info p{
  margin: 5px 0 0;
  color: #858c98;
  font-size: 13px;
}
</style>