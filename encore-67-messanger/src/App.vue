<script setup lang="ts">

import type { User } from "./types/user";

import ProfilerEditor from "./components/ProfilerEditor.vue";

import ImageViewer from "./components/ImageViewer.vue";

import { ProfileUpdate } from "./types/user";

const isProfileOpen = ref(false);

const openImageSrc = ref<string | null>(null);

function openProfile(){
  isProfileOpen.value = true;
}

function closeProfile(){
  isProfileOpen.value = false;
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
        status = $2

      WHERE id = $3
    `,
    [
      profile.displayName,
      profile.status,
      currentUser.value?.id,
    ],
  );

  currentUser.value.display_name = profile.displayName;
  currentUser.value.status = profile.status;

  if(activeChat.value){
    await loadMessages(
      activeChat.value.id,
    )
  }
};

// Импорт 2 функций из vue
// onMounted - запускает код после появления компонента
// ref -  создает быстрые перемещения
import { onMounted, ref } from "vue";

import Database from "@tauri-apps/plugin-sql";

import AppHeader from "./components/AppHeader.vue";

import MessageList from "./components/MessageList.vue";

import MessageComposer from "./components/MessageComposer.vue";

import ChatSidebar from "./components/ChatSidebar.vue";

import type { Chat } from "./types/chats";

import type { Message } from "./types/message.ts";

const users = ref<User[]>([]);

const messageText = ref("");

const editingMessageId = ref<number | null>(null);

const currentUser = ref<User | null>(null);

async function selectUser(user: User) {
  currentUser.value = user;

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
// Статус подключения к бд
const status = ref("Подключение...")

// Здесь будет подключение к бд (честно), но пока тут null
let db: Database | null = null;


async function loadChats(){
  if (!db) return;

  chats.value = await db.select<Chat[]>(
    "SELECT id, title, subtitle FROM chats ORDER BY id ASC",
  );

  if (chats.value.length > 0){
    await selectChat(chats.value[0]);
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
    />
    <div 
        v-if="currentUser"
        class="workspace">
      <ChatSidebar
          :chats="chats"
          :active-chat-id="activeChatId"
          :unread-counts="unreadCounts"
          @select="selectChat"
      />
      <section class="chat">
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
  /*
      Запретит всему app прокручиваться
      Разрешим прокрутку только для MessageList
  */
  overflow: hidden;
}

.chat{
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden; /* Потому что chat целиком не должен прокручиваться, только MessageList внутри него */
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