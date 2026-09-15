<script setup lang="ts">

import {onMounted, ref} from "vue";

import type { Message } from "./types/message.ts";
import type { User } from "./types/user.ts";
import AppHeader from "./components/AppHeader.vue";
import MessageList from "./components/MessageList.vue";
import MessageComposer from "./components/MessageComposer.vue";
import UserSwitcher from "./components/UserSwitcher.vue";
import ChatSideBar from "./components/ChatSideBar.vue";
import type { Chat } from "./types/chats.ts";


const USERS: User[] = [
  { id: 1, name: "Юра" },
  { id: 2, name: "Фурри" },
];

const messages = ref<Message[]>([]);
const chats = ref<Chat[]>([]);
const activeChat = ref<Chat | null>(null);
const activeChatId = ref(1);

const currentUser = ref<User>(USERS[0]);

const status = ref("Connection...")

type DatabaseInstance = {
  select: <T>(query: string, bindValues?: unknown[]) => Promise<T>;
  execute: (query: string, bindValues?: unknown[]) => Promise<unknown>;
};

let db: DatabaseInstance | null = null;
let useBrowserStorage = false;

const STORAGE_KEY = "rust-messenger-messages";

function loadBrowserMessages() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored) {
    try {
      messages.value = JSON.parse(stored) as Message[];
    } catch {
      messages.value = [];
    }
  }
}

function saveBrowserMessages() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(messages.value));
}

async function LoadChats() {
  if (!db) return;

  chats.value = await db.select<Chat[]>(
    "SELECT id, title, subtitle FROM chats ORDER BY id ASC",
  );

  if (chats.value.length > 0) {
    await selectChat(chats.value[0]);
  }
  
}
async function selectChat(chat: Chat) {
  activeChat.value = chat;
  activeChatId.value = chat.id;
  await loadMessages(chat.id);
  
}

async function loadMessages(chatId: number){
  if (useBrowserStorage) {
    loadBrowserMessages();
    return;
  }
  if (!db) return;

  const rows = await db.select<Array<{ id: number; author: string; body: string; created_at: string; attachments: string | null }>>(
      "SELECT id, author, body, created_at, attachments FROM messages WHERE chat_id = $1 ORDER BY id ASC",
      [chatId]
  );

  messages.value = rows.map(row => ({
    id: row.id,
    author: row.author,
    body: row.body,
    created_at: row.created_at,
    attachments: row.attachments ? (JSON.parse(row.attachments) as string[]) : null,
  }));
}

async function sendMessage(body: string, attachments?: string[] | null){
  const author = currentUser.value.name;

  if (useBrowserStorage) {
    const maxId = messages.value.length > 0
      ? Math.max(...messages.value.map(m => m.id))
      : 0;
    const newMessage: Message = {
      id: maxId + 1,
      author,
      body,
      created_at: new Date().toISOString(),
      attachments: attachments ?? null,
    };
    messages.value = [...messages.value, newMessage];
    saveBrowserMessages();
    return;
  }
  if (!db) return;

  if (!activeChat.value) return;

  await db.execute(
    `INSERT INTO messages (chat_id, author, body) VALUES ($1, $2, $3)`,
    [activeChatId.value, currentUser.value.name, body],
  );

  await loadMessages(activeChat.value.id);
}

function selectUser(user: User) {
  currentUser.value = user;
}

function isTauriAvailable(): boolean {
  return typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;
}

onMounted(async()=>{
  if (!isTauriAvailable()) {
    useBrowserStorage = true;
    loadBrowserMessages();
    status.value = "Демо-режим (сохранение в браузере)";
    return;
  }

  try{
    const DatabaseModule = await import("@tauri-apps/plugin-sql");
    const Database = DatabaseModule.default ?? DatabaseModule;
    db = await Database.load("sqlite:messanger.db");

    await loadMessages();

    status.value = "История сохраняется локально";
  }catch (error){
    console.error(error);
    useBrowserStorage = true;
    loadBrowserMessages();
    status.value = "Демо-режим: Tauri недоступен (сохранение в браузере)";
  }
});

</script>

<template>
  <main class="app">
    <AppHeader :status="status"/>
    <div class="workspace">
      <ChatSideBar
        :chats="chats"
        :active-chat-id="activeChatId"
        @select="selectChat"
      />
    <section class="chat">
      <template v-if="activeChat.value">
        <chatInfo
          :title='activeChat.value.title'
          :subtitle='activeChat.value.subtitle'
        />
      <MessageList :messages="messages" :current-user-name="currentUser.name"/>
      <MessageComposer @send="sendMessage"/>        
        </template>


    </section>
      
      </div>

  </main>
</template>

<style scoped>
/* Все элементы будут */
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
  display: flex;
  flex-direction: column;
  height: 100vh; /* - */
  overflow: hidden; /* запретит всему app прокручиваться, разрешим прокрутку ток для */
}

.chat{
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden; /* чат целиком не должен прокручиваться, ток meslist внутри */
}

.chat-info{
  padding: 20px 24px;
  border-bottom: 1px solid #252830;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
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