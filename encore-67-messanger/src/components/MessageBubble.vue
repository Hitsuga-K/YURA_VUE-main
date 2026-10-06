<script setup lang="ts">

import { getFileUrl } from "../types/file.ts";

import type { Message } from "../types/message.ts";

defineProps<{
  message: Message;
  isOwn: boolean;
}>();


const emit = defineEmits<{
  openImage: [src: string];
  edit: [message: Message];
  delete: [message: Message];
}>();

function openImage(src: string) {
  emit("openImage", src);
}
</script>

<template>
  <article
    class="message"
    :class="{
      'message--own': isOwn,
      'message--other': !isOwn,
    }"
  >
    <!-- Текст сообщения -->
    <p v-if="message.type === 'text'">
      {{ message.body }}
    </p>

    <!-- Изображение -->
    <img
      v-if="message.type === 'image' && message.attachment"
      class="message-image"
      :src="getFileUrl(message.attachment)"
      alt="Изображение"
      @click="openImage(getFileUrl(message.attachment))"
    />

    <!-- Нижняя информация -->
    <footer>
      <span class="message-author">
        {{ message.author_name }}
      </span>

      <span class="message-separator">
        |
      </span>

      <span class="message-date">
        {{ message.created_at }}
      </span>

      <!-- Кнопки только для своих сообщений -->
      <template v-if="isOwn">
        <button
          type="button"
          class="message-action message-action--edit"
          title="Редактировать сообщение"
          aria-label="Редактировать сообщение"
          @click="emit('edit', message)"
        >
          ✎
        </button>

        <button
          type="button"
          class="message-action message-action--delete"
          title="Удалить сообщение"
          aria-label="Удалить сообщение"
          @click="emit('delete', message)"
        >
          🗑
        </button>
      </template>
    </footer>
  </article>
</template>

<style scoped>
.message {
  max-width: 70%;
  margin: 0;
  padding: 10px 12px;
  border-radius: 10px;
}

.message--own {
  align-self: flex-end;
  background: #386be0;
}

.message--other {
  align-self: flex-start;
  background: #252830;
}

/* Текст сообщения */
.message p {
  margin: 0;
  line-height: 1.45;
  overflow-wrap: anywhere;
}

/* Нижняя часть сообщения */
.message footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 5px;
  margin-top: 6px;

  color: #b5bbc7;
  font-size: 10px;
}

.message-author {
  white-space: nowrap;
}

.message-separator {
  opacity: 0.6;
}

.message-date {
  white-space: nowrap;
}

/* Кнопки редактирования и удаления */
.message-action {
  width: 26px;
  height: 26px;

  display: flex;
  align-items: center;
  justify-content: center;

  padding: 0;

  border: 1px solid transparent;
  border-radius: 7px;

  background: transparent;
  color: #aeb5c2;

  cursor: pointer;

  font-size: 14px;
  line-height: 1;

  transition:
    background-color 0.15s ease,
    color 0.15s ease,
    border-color 0.15s ease,
    transform 0.15s ease;
}

.message-action:hover {
  transform: translateY(-1px);
}

.message-action:active {
  transform: scale(0.94);
}

/* Редактирование */
.message-action--edit:hover {
  background: rgba(56, 107, 224, 0.18);
  border-color: rgba(56, 107, 224, 0.4);
  color: #78a0ff;
}

/* Удаление */
.message-action--delete:hover {
  background: rgba(240, 23, 41, 0.15);
  border-color: rgba(240, 23, 41, 0.35);
  color: #ff5c6c;
}

/* Фокус с клавиатуры */
.message-action:focus-visible {
  outline: 2px solid #6f94ee;
  outline-offset: 2px;
}

/* Изображение */
.message-image {
  display: block;

  max-width: 300px;
  max-height: 300px;

  border-radius: 12px;

  object-fit: cover;

  cursor: pointer;

  transition: transform 0.15s ease;
}

.message-image:hover {
  transform: scale(1.02);
}
</style>