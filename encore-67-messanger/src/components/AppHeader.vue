<script setup lang="ts">
import { computed } from "vue";
import UserSwitcher from "./UserSwitcher.vue";
import { getFileUrl } from "../types/file.ts";

import type { User } from "../types/user";

const props = defineProps<{
  status: string;
  users: User[];
  currentUser: User;
}>();

const emit = defineEmits<{
  select: [user: User];
  profile: [];
  createChat: [peer: User];
}>();

function selectUser(user: User){
  emit("select", user);
}

function onCreateChat(peer: User) {
  emit("createChat", peer);
}

const currentUserAvatar = computed(() => {
  if (props.currentUser.avatar_path) {
    return getFileUrl(props.currentUser.avatar_path);
  }
  return null;
});

const currentUserInitials = computed(() => {
  const name = props.currentUser.display_name?.trim() || props.currentUser.username;
  const parts = name.split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 1).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
});
</script>

<template>
  <header class="header">
    <div>
      <h1>Encore 67 messenger</h1>

      <p>{{status}}</p>
    </div>

    <div class="header__actions">
      <UserSwitcher
          :users="users"
          :current-user-id="currentUser.id"
          @select="selectUser"
          @create-chat="onCreateChat"
      />
      <button
        type="button"
        class="profile-open-button"
        @click="emit('profile')"
      >
        <div class="profile-open-button__avatar">
          <img
            v-if="currentUserAvatar"
            :src="currentUserAvatar"
            :alt="currentUser.display_name"
          />
          <span v-else class="profile-open-button__initials">
            {{ currentUserInitials }}
          </span>
        </div>
        <span class="profile-open-button__text">Профиль</span>
      </button>
    </div>
    <span class="badge">
        Локально
      </span>
  </header>
</template>

<style scoped>
/*
  CSS этого блока будет относиться только к текущему vue компоненту
  Например .header не повлияет на любой другой .header в коде вне этого компонента
*/

.header{
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 24px;
  border-bottom: 1px solid #292c34;
  background: #17191f;
  /* Управляет тем, может ли flex уменьшать элемент*/
  flex-shrink: 0;
}

.header__actions{
  display: flex;
  align-items: center;
  gap: 12px;
}

.header h1 {
  margin: 0;
  font-size: 18px;
}

.header p{
  margin: 4px 0 0;
  color: #8f96a3;
}

.badge{
  padding: 6px 10px;
  border: 1px solid #343842;
  border-radius: 6px;
  color: #afb5c0;
  background: #20232a;
  font-size: 12px;
}

.profile-open-button{
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 12px 4px 4px;
  border: 1px solid #343842;
  border-radius: 999px;
  background: #20232a;
  color: #afb5c0;
  cursor: pointer;
  font: inherit;
  font-size: 13px;
  font-weight: 500;
  transition: border-color 0.15s ease, background-color 0.15s ease, color 0.15s ease;
}

.profile-open-button:hover{
  background: #252830;
  border-color: #3f4450;
  color: #f2f3f5;
}

.profile-open-button:active{
  background: #292c34;
}

.profile-open-button__avatar{
  width: 28px;
  height: 28px;
  border-radius: 50%;
  overflow: hidden;
  border: 1px solid #343842;
  background: #292c34;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.profile-open-button__avatar img{
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.profile-open-button__initials{
  font-size: 11px;
  font-weight: 700;
  color: #8f96a3;
  user-select: none;
}
</style>