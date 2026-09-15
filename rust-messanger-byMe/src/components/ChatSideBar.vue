<script setup lang="ts">
import type { Chat } from '../types/chats'
defineProps<{
  chats: Chat[];

  activeChatId: number;
}>();


const emit = defineEmits<{
  select: [chat: Chat];
}>();


function selectChat(chat: Chat) {
  emit('select', chat);
}


</script>

<template>
<aside class="sidebar">
    <div class="sidebar__header">
        Чаты
    </div>
    <div class="sidebar__list">
        <button
        v-for="chat in chats"
        :key="chat.id"
        type="button"
        class="chat-button"
        :class="{'chat--button--active': chat.id === activeChatId}"
        @click="selectChat(chat)"
        >
      <strong class="chat-button__title">
        {{ chat.title }}
      </strong>
      <span class="chat-button__subtitle">
        {{ chat.subtitle }}
      </span>
      </button>
    </div>
</aside>
</template>

<style scoped>
.sitebar{
  width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;

  min-height: 0;

  border-right: 1px solid #292c34;

  background: #17191f;
}
.sitebar__header{
  flex-shrink: 0;
  border-bottom: 1px solid #292c34;
  padding: 18px;
  font-weight: 600;
}

.sidebar__list{
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.chat-button{
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
  padding: 8px;
  border: none;
  border-radius: 10px;
  background: transparent;
  cursor: pointer;
  font: inherit;
  text-align: left;
}

.chat-button:hover{
  background: #20232a;
}
.chat-button--active{
  background: #24628a;
}
.chat-button__title{
  font-size: 16px;
}
.chat-button__subtitle{
  font-size: 12px;
  color: #8f96a3;
}

</style>
