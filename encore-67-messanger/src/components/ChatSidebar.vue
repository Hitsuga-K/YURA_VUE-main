<script setup lang="ts">
import { ref } from "vue";
import type { Chat } from "../types/chats";

defineProps<{
  chats: Chat[];

  activeChatId: number;
  unreadCounts: Record<number, number>;
}>();

const emit = defineEmits<{
  select: [chat: Chat];
  openSettings: [chat: Chat];
}>();

const openMenuChatId = ref<number | null>(null);

function selectChat(chat: Chat){
  openMenuChatId.value = null;
  emit("select", chat);
}

function toggleMenu(chatId: number, event: MouseEvent) {
  event.stopPropagation();
  event.preventDefault();
  if (openMenuChatId.value === chatId) {
    openMenuChatId.value = null;
  } else {
    openMenuChatId.value = chatId;
  }
}

function openSettings(chat: Chat) {
  openMenuChatId.value = null;
  emit("openSettings", chat);
}

function closeMenu() {
  openMenuChatId.value = null;
}
</script>

<template>
<aside class="sidebar" @click="closeMenu">
  <div class="sidebar__header">
    Чаты
  </div>

  <div class="sidebar__list">
    <div
      v-for="chat in chats"
      :key="chat.id"
      class="chat-button-wrap"
    >
      <button
        type="button"
        class="chat-button"
        :class="{
          'chat-button--active':
            chat.id === activeChatId
        }"
        @click="selectChat(chat)"
      >
        <div class="chat-button__title-row">
          <strong class="chat-button__title">
            {{ chat.title }}
          </strong>

          <div class="chat-button__actions">
            <span
              v-if="unreadCounts[chat.id] > 0"
              class="unread-badge"
            >
              {{ unreadCounts[chat.id] }}
            </span>
            <button
              type="button"
              class="chat-button__menu"
              :title="`Настроить чат ${chat.title}`"
              @click="toggleMenu(chat.id, $event)"
            >
              <span class="chat-button__dots">
                <span></span>
                <span></span>
                <span></span>
              </span>
            </button>
          </div>
        </div>

        <span class="chat-button__subtitle">
          {{ chat.subtitle }}
        </span>
      </button>

      <div
        v-if="openMenuChatId === chat.id"
        class="chat-menu"
        @click.stop
      >
        <button
          type="button"
          class="chat-menu__item"
          @click="openSettings(chat)"
        >
          Настроить чат
        </button>
      </div>
    </div>
  </div>
</aside>
</template>

<style scoped>
.chat-button__title-row{
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.chat-button__actions{
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
}

.chat-button-wrap{
  position: relative;
}

.chat-button__menu{
  width: 22px;
  height: 22px;
  padding: 0;
  border: 1px solid transparent;
  border-radius: 4px;
  background: transparent;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--chat-btn-subtitle, #858c98);
  transition: background-color 0.12s ease, border-color 0.12s ease, color 0.12s ease;
}

.chat-button__menu:hover{
  background: var(--chat-menu-bg-hover, #2a2e38);
  border-color: var(--badge-border, #343842);
  color: var(--chat-btn-fg, #f2f3f5);
}

.chat-button__dots{
  display: flex;
  flex-direction: column;
  gap: 2px;
  align-items: center;
  justify-content: center;
}

.chat-button__dots span{
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: currentColor;
  display: block;
}

.chat-menu{
  position: absolute;
  top: 42px;
  right: 10px;
  z-index: 10;
  min-width: 150px;
  border: 1px solid var(--chat-menu-border, #343842);
  border-radius: 8px;
  background: var(--chat-menu-bg, #1f2229);
  background-size: 400% 400%;
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.45);
  padding: 4px;
  overflow: hidden;
  color: var(--chat-menu-item, #f2f3f5);
}

.chat-menu__item{
  width: 100%;
  padding: 8px 10px;
  border: none;
  border-radius: 5px;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font: inherit;
  font-size: 13px;
  text-align: left;
  transition: background-color 0.12s ease, color 0.12s ease;
}

.chat-menu__item:hover{
  background: var(--chat-menu-item-hover, #2a2e38);
}

.chat-menu__item:active{
  background: var(--surface-hover, #303440);
}

.unread-badge{
  min-width: 20px;
  height: 20px;

  display: flex;
  align-items: center;
  justify-content: center;

  padding: 0 6px;

  border-radius: 999px;

  background: var(--unread-bg, #f01729);
  color: var(--unread-fg, white);
  background-size: 200% 100%;

  font-size: 11px;
  font-weight: 600;
}

.sidebar{
  width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;

  min-height: 0;

  border-right: 1px solid var(--sidebar-border, #252830);

  background: var(--sidebar-bg, #15171c);
  background-size: 100% 400%;
}

.sidebar__header{
  flex-shrink: 0;
  padding: 18px;
  border-bottom: 1px solid var(--sidebar-border, #252830);
  font-weight: 600;
  color: var(--sidebar-header, #f2f3f5);
  background: var(--card-header-bg, transparent);
}

.sidebar__list{
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.chat-button{
  width: 100%;

  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
  padding: 12px;
  border: none;
  border-radius: 10px;
  background: var(--chat-btn-bg, transparent);
  color: var(--chat-btn-fg, #f2f3f5);
  cursor: pointer;
  font: inherit;
  text-align: left;
  background-size: 100% 100%;
}

.chat-button:hover{
  background: var(--chat-btn-bg-hover, #20232a);
}

.chat-button--active{
  background: var(--chat-btn-bg-active, #292c34);
}
.chat-button__title{
  font-size: 14px;
  font-weight: 600;
}
.chat-button__subtitle{
  color: var(--chat-btn-subtitle, #858c98);
  font-size: 12px;
}


</style>
