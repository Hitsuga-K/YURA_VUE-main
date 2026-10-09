<script setup lang="ts">
import { computed, ref } from "vue";
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
  openCreateUser: [];
  openSecret: [];
}>();

const isDropdownOpen = ref(false);

function selectUser(user: User){
  isDropdownOpen.value = false;
  emit("select", user);
}

function openProfile() {
  isDropdownOpen.value = false;
  emit("profile");
}

function onCreateChat(peer: User) {
  isDropdownOpen.value = false;
  emit("createChat", peer);
}

function openCreateUser() {
  isDropdownOpen.value = false;
  emit("openCreateUser");
}

function toggleDropdown() {
  isDropdownOpen.value = !isDropdownOpen.value;
}

function closeDropdown() {
  isDropdownOpen.value = false;
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

const currentUserAvatar = computed(() => getUserAvatarUrl(props.currentUser));
const currentUserInitials = computed(() => getUserInitials(props.currentUser));
</script>

<template>
  <header
    class="header"
    @click.self="closeDropdown"
  >
    <div>
      <h1>Encore 67 messenger</h1>

      <p>{{status}}</p>
    </div>

    <div class="header__actions">
      <div class="user-switcher-wrap">
        <button
          type="button"
          class="user-switcher-trigger"
          :class="{ 'user-switcher-trigger--open': isDropdownOpen }"
          @click.stop="toggleDropdown"
          @keydown.escape="closeDropdown"
          title="Переключить пользователя"
        >
          <div class="user-switcher-trigger__avatar">
            <img
              v-if="currentUserAvatar"
              :src="currentUserAvatar"
              :alt="currentUser.display_name"
            />
            <span v-else class="user-switcher-trigger__initials">
              {{ currentUserInitials }}
            </span>
          </div>
          <div class="user-switcher-trigger__info">
            <strong class="user-switcher-trigger__name">
              {{ currentUser.display_name }}
            </strong>
            <span class="user-switcher-trigger__username">
              @{{ currentUser.username }}
            </span>
          </div>
          <span class="user-switcher-trigger__arrow"></span>
        </button>

        <div
          v-if="isDropdownOpen"
          class="user-switcher-dropdown"
          @click.stop
        >
          <div class="usd__header">
            Выбрать пользователя
          </div>
          <div class="usd__list">
            <button
              v-for="user in users"
              :key="user.id"
              type="button"
              class="usd__item"
              :class="{ 'usd__item--current': user.id === currentUser.id }"
              @click="selectUser(user)"
            >
              <div class="usd__avatar">
                <img
                  v-if="getUserAvatarUrl(user)"
                  :src="getUserAvatarUrl(user)"
                  :alt="user.display_name"
                />
                <span v-else class="usd__initials">
                  {{ getUserInitials(user) }}
                </span>
              </div>
              <div class="usd__info">
                <strong class="usd__name">
                  {{ user.display_name }}
                </strong>
                <span class="usd__username">
                  @{{ user.username }}
                </span>
              </div>
              <span
                v-if="user.id === currentUser.id"
                class="usd__current-mark"
              >
                ●
              </span>
            </button>
          </div>

          <div class="usd__divider"></div>

          <div class="usd__quick-row">
            <span class="usd__quick-label">
              Создать чат с
            </span>
            <button
              v-for="user in users.filter(u => u.id !== currentUser.id)"
              :key="`chat-${user.id}`"
              type="button"
              class="usd__quick"
              :title="`Создать чат с ${user.display_name}`"
              @click="onCreateChat(user)"
            >
              <div class="usd__quick-avatar">
                <img
                  v-if="getUserAvatarUrl(user)"
                  :src="getUserAvatarUrl(user)"
                  :alt="user.display_name"
                />
                <span v-else class="usd__quick-initials">
                  {{ getUserInitials(user) }}
                </span>
              </div>
              <span class="usd__quick-plus">+</span>
            </button>
          </div>

          <div class="usd__divider"></div>

          <button
            type="button"
            class="usd__action"
            @click="openProfile"
          >
            <span class="usd__action-icon usd__action-icon--profile"></span>
            Редактировать профиль
          </button>

          <button
            type="button"
            class="usd__action usd__action--primary"
            @click="openCreateUser"
          >
            <span class="usd__action-icon usd__action-icon--plus"></span>
            Создать пользователя
          </button>
        </div>
      </div>
    </div>
    <span
      class="badge"
      role="button"
      tabindex="0"
      title="Статус хранилища"
      @click="emit('openSecret')"
      @keydown.enter="emit('openSecret')"
    >
        Локально
      </span>
  </header>
</template>

<style scoped>
.header{
  position: relative;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 24px;
  border-bottom: 1px solid var(--header-border, #292c34);
  background: var(--header-bg, #17191f);
  color: var(--header-title, #f2f3f5);
  flex-shrink: 0;
  z-index: 20;
}

.header__actions{
  display: flex;
  align-items: center;
  gap: 12px;
}

.header h1 {
  margin: 0;
  font-size: 18px;
  color: var(--header-title, #f2f3f5);
  background-image: var(--rainbow-title, none);
  background-size: 300% 100%;
  -webkit-background-clip: text;
  background-clip: text;
}

.header p{
  margin: 4px 0 0;
  color: var(--header-subtitle, #8f96a3);
}

.badge{
  padding: 6px 10px;
  border: 1px solid var(--badge-border, #343842);
  border-radius: 6px;
  color: var(--badge-fg, #afb5c0);
  background: var(--badge-bg, #20232a);
  background-size: 100% 100%, 300% 100%;
  background-clip: padding-box, border-box;
  background-origin: border-box;
  font-size: 12px;
  cursor: default;
  user-select: none;
  transition: border-color 0.12s ease, background-color 0.12s ease, color 0.12s ease;
}

.badge:hover{
  background: var(--badge-bg-hover, #252830);
  border-color: var(--badge-border-hover, #3f4450);
  color: var(--badge-fg-hover, #f2f3f5);
}

.user-switcher-wrap{
  position: relative;
}

.user-switcher-trigger{
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 4px 10px 4px 4px;
  border: 1px solid var(--us-trigger-border, #343842);
  border-radius: 10px;
  background: var(--us-trigger-bg, #20232a);
  color: var(--app-fg, #f2f3f5);
  cursor: pointer;
  font: inherit;
  min-width: 200px;
  text-align: left;
  background-size: 200% 100%;
  transition: border-color 0.14s ease, background-color 0.14s ease;
}

.user-switcher-trigger:hover{
  background: var(--surface-hover, #252830);
  border-color: var(--badge-border-hover, #3f4450);
}

.user-switcher-trigger--open{
  background: var(--us-trigger-bg-open, #252830);
  border-color: var(--us-trigger-border-open, #386be0);
}

.user-switcher-trigger__avatar{
  width: 32px;
  height: 32px;
  border-radius: 50%;
  overflow: hidden;
  border: 1px solid var(--badge-border, #343842);
  background: var(--border-2, #292c34);
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-switcher-trigger__avatar img{
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.user-switcher-trigger__initials{
  font-size: 12px;
  font-weight: 700;
  color: var(--msg-avatar-initials, #8f96a3);
  user-select: none;
}

.user-switcher-trigger__info{
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  line-height: 1.15;
}

.user-switcher-trigger__name{
  font-size: 13px;
  font-weight: 600;
  color: var(--app-fg, #f2f3f5);
}

.user-switcher-trigger__username{
  font-size: 11px;
  color: var(--muted, #858c98);
  margin-top: 1px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-switcher-trigger__arrow{
  width: 0;
  height: 0;
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 5px solid var(--muted, #858c98);
  margin: 0 2px 0 4px;
  flex-shrink: 0;
  transition: transform 0.14s ease, border-color 0.14s ease;
}

.user-switcher-trigger--open .user-switcher-trigger__arrow{
  transform: rotate(180deg);
  border-top-color: var(--app-fg, #f2f3f5);
}

.user-switcher-dropdown{
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  width: 320px;
  max-width: calc(100vw - 48px);
  border: 1px solid var(--us-dropdown-border, #343842);
  border-radius: 10px;
  background: var(--us-dropdown-bg, #17191f);
  background-size: 400% 400%;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.5);
  padding: 6px 0;
  color: var(--card-fg, #f2f3f5);
  z-index: 30;
}

.usd__header{
  padding: 10px 14px 8px;
  font-size: 11px;
  font-weight: 600;
  color: var(--muted, #6a717d);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.usd__list{
  padding: 4px 6px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  max-height: 280px;
  overflow-y: auto;
}

.usd__item{
  width: 100%;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 10px;
  border: none;
  border-radius: 7px;
  background: var(--chat-btn-bg, transparent);
  color: var(--card-fg, #f2f3f5);
  cursor: pointer;
  font: inherit;
  text-align: left;
  background-size: 100% 100%;
  transition: background-color 0.12s ease;
}

.usd__item:hover{
  background: var(--us-item-hover, #20232a);
}

.usd__item--current{
  background: var(--us-item-current, #223156);
}

.usd__item--current:hover{
  background: var(--us-item-current-hover, #24386a);
}

.usd__avatar{
  width: 30px;
  height: 30px;
  border-radius: 50%;
  overflow: hidden;
  border: 1px solid var(--badge-border, #343842);
  background: var(--border-2, #292c34);
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.usd__avatar img{
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.usd__initials{
  font-size: 12px;
  font-weight: 700;
  color: var(--msg-avatar-initials, #8f96a3);
  user-select: none;
}

.usd__item--current .usd__initials{
  color: var(--app-fg, #d6def0);
}

.usd__info{
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.usd__name{
  font-size: 13px;
  font-weight: 600;
  color: inherit;
}

.usd__username{
  font-size: 11px;
  color: var(--muted, #858c98);
  margin-top: 1px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.usd__current-mark{
  color: var(--primary, #386be0);
  font-size: 10px;
  margin-right: 4px;
}

.usd__divider{
  height: 1px;
  background: var(--border-2, #292c34);
  margin: 6px 8px;
}

.usd__quick-row{
  padding: 6px 14px 10px;
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.usd__quick-label{
  font-size: 11px;
  color: var(--muted, #6a717d);
  margin-right: 2px;
  width: 100%;
}

.usd__quick{
  position: relative;
  width: 30px;
  height: 30px;
  padding: 0;
  border: 1px solid var(--badge-border, #343842);
  border-radius: 50%;
  background: var(--surface, #20232a);
  cursor: pointer;
  font: inherit;
  transition: border-color 0.12s ease, background-color 0.12s ease;
}

.usd__quick:hover{
  background: var(--primary-hover, #1f3a7d);
  border-color: var(--primary, #386be0);
}

.usd__quick-avatar{
  width: 100%;
  height: 100%;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--border-2, #292c34);
}

.usd__quick-avatar img{
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.usd__quick-initials{
  font-size: 10px;
  font-weight: 700;
  color: var(--msg-avatar-initials, #8f96a3);
  user-select: none;
}

.usd__quick-plus{
  position: absolute;
  bottom: -4px;
  right: -4px;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: var(--primary, #386be0);
  color: var(--composer-btn-fg, #ffffff);
  font-size: 11px;
  font-weight: 700;
  line-height: 14px;
  text-align: center;
  border: 2px solid var(--panel-bg, #17191f);
  box-sizing: content-box;
}

.usd__action{
  width: calc(100% - 12px);
  margin: 2px 6px;
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 9px 12px;
  border: none;
  border-radius: 7px;
  background: transparent;
  color: var(--card-fg, #f2f3f5);
  cursor: pointer;
  font: inherit;
  font-size: 13px;
  text-align: left;
  transition: background-color 0.12s ease;
}

.usd__action:hover{
  background: var(--us-item-hover, #20232a);
}

.usd__action--primary{
  color: var(--us-action-primary, #386be0);
  font-weight: 500;
}

.usd__action--primary:hover{
  background: var(--us-action-primary-hover, #223156);
  color: var(--composer-btn-fg, #ffffff);
}

.usd__action-icon{
  width: 16px;
  height: 16px;
  flex-shrink: 0;
  border-radius: 3px;
  background: var(--surface, #2e323c);
  position: relative;
}

.usd__action-icon--profile::after{
  content: "";
  position: absolute;
  top: 3px;
  left: 50%;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--muted, #858c98);
  transform: translateX(-50%);
}

.usd__action-icon--profile::before{
  content: "";
  position: absolute;
  bottom: 2px;
  left: 50%;
  width: 11px;
  height: 5px;
  border-top-left-radius: 6px;
  border-top-right-radius: 6px;
  background: var(--muted, #858c98);
  transform: translateX(-50%);
}

.usd__action-icon--plus::before,
.usd__action-icon--plus::after{
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  background: var(--us-action-primary, #386be0);
  transform-origin: center;
}

.usd__action-icon--plus::before{
  width: 9px;
  height: 2px;
  transform: translate(-50%, -50%);
}

.usd__action-icon--plus::after{
  width: 2px;
  height: 9px;
  transform: translate(-50%, -50%);
}

.usd__action--primary:hover .usd__action-icon{
  background: var(--us-action-primary-hover, #1b2849);
}

.usd__action--primary:hover .usd__action-icon--plus::before,
.usd__action--primary:hover .usd__action-icon--plus::after{
  background: var(--composer-btn-fg, #ffffff);
}
</style>
