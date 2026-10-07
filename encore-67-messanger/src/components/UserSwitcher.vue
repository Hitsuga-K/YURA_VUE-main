<script setup lang="ts">
import { computed } from "vue";
import { getFileUrl } from "../types/file.ts";
import type { User } from "../types/user.ts";

defineProps<{
  users: User[];

  currentUserId: number;
}>();

const emit = defineEmits<{
  select: [user: User];
  createChat: [peer: User];
}>();

function selectUser(user: User){
  emit("select", user);
}

function onCreateChat(user: User) {
  emit("createChat", user);
}

function getUserAvatarUrl(user: User) {
  if (user.avatar_path) {
    return getFileUrl(user.avatar_path);
  }
  return null;
}

function getUserInitials(user: User) {
  const name = user.display_name?.trim() || user.username;
  const parts = name.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 1).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
</script>

<template>
  <div class="user-switcher">
    <span class="user-switcher__label">
      Пишет:
    </span>
    <div
      v-for="user in users"
      :key="user.id"
      class="user-switcher__item"
    >
      <button
        type="button"
        class="user-switcher__button"

        :class="{
          'user-switcher__button--active':
          user.id === currentUserId
        }"

        @click="selectUser(user)"
      >
        <div class="user-switcher__avatar">
          <img
            v-if="getUserAvatarUrl(user)"
            :src="getUserAvatarUrl(user)"
            :alt="user.display_name"
          />
          <span v-else class="user-switcher__initials">
            {{ getUserInitials(user) }}
          </span>
        </div>
        <span class="user-switcher__name">
          {{ user.display_name }}
        </span>
      </button>
      <button
        v-if="user.id !== currentUserId"
        type="button"
        class="user-switcher__create"
        :title="`Создать чат с ${user.display_name}`"
        @click="onCreateChat(user)"
      >
        +
      </button>
    </div>
  </div>
</template>


<style scoped>
.user-switcher{
  display: flex;
  align-items: center;
  gap: 6px;
}

.user-switcher__label{
  color: #8f96a3;
  font-size: 12px;
}

.user-switcher__item{
  display: flex;
  align-items: center;
  gap: 4px;
}

.user-switcher__button{
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px 4px 4px;
  border: 1px solid #343842;
  border-radius: 999px;
  cursor: pointer;
  background: #20232a;
  color: #afb5c0;
  font: inherit;
  font-size: 12px;
  transition: border-color 0.15s ease, background-color 0.15s ease, color 0.15s ease;
}

.user-switcher__button:hover{
  border-color: #3f4450;
  background: #252830;
  color: #f2f3f5;
}

.user-switcher__button--active{
  background: #386be0;
  border-color: #386be0;
  color: white;
}

.user-switcher__button--active:hover{
  background: #2f5cc4;
  border-color: #2f5cc4;
  color: white;
}

.user-switcher__avatar{
  width: 24px;
  height: 24px;
  border-radius: 50%;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: #292c34;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-switcher__button--active .user-switcher__avatar{
  border-color: rgba(255, 255, 255, 0.25);
  background: rgba(255, 255, 255, 0.15);
}

.user-switcher__avatar img{
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.user-switcher__initials{
  font-size: 10px;
  font-weight: 700;
  color: #8f96a3;
  user-select: none;
}

.user-switcher__button--active .user-switcher__initials{
  color: #e0e4ec;
}

.user-switcher__create{
  width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: 1px solid #343842;
  border-radius: 50%;
  background: #20232a;
  color: #afb5c0;
  cursor: pointer;
  font: inherit;
  font-size: 16px;
  font-weight: 700;
  line-height: 1;
  transition: border-color 0.15s ease, background-color 0.15s ease, color 0.15s ease;
}

.user-switcher__create:hover{
  background: #1f3a7d;
  border-color: #386be0;
  color: #ffffff;
}

.user-switcher__create:active{
  background: #1a326b;
}
</style>