<script setup lang="ts">
import {ref} from "vue";

import type{
  ProfileUpdate,
  User,
} from "../types/user";

const props = defineProps<{
  user: User;
}>();

const emit = defineEmits<{
  save: [
    profile: ProfileUpdate
  ];
  close: [];
}>();

const displayName = ref (props.user.display_name,);
const userStatus = ref (props.user.status,);

function  sumbitProfile(){
  const cleanDisplayName = 
    displayName.value.trim();

  if (!cleanDisplayName){
    return;
  }

  emit("save", {
    displayName: cleanDisplayName,
    status: userStatus.value.trim(),
  });
}

</script>

<template>
<div class="profile_backdrop">
  <section class="profile_card">
    <header class="profile_card__header">
      <h2>
        Профиль
      </h2>
      <button
      type="button"
      class="profile-card__clase"
      @click="emit('close')">
      </button>
    </header>
    <form class="profile-form"
    @submit.prevent="sumbitProfile">
    <label for="profile-display-name"
    class="profile-filed">
    <span>
        Отображение имя
    </span>
    <input id="profile-display-name"
    v-model="displayName"
    type="text"
    maxlength="40">
  </label>
  <label for="profile-status"
  class="profile-field">
  <span>
    status
  </span>
  <textarea id="profile-status"
  v-model="userStatus"
  maxlength="120"
  rows="3">
  </textarea>
  </label>
  <div class="profile-username">
    <span>
      UserName
    </span>
    <strong>
      @{{ user.user_name}}
    </strong>
  </div>
  <footer class="profile-action">
    <button type="button"
    class="profile-button profile-button--secondary"
    @click="emit('close')">
    Отмена
    </button>

    <button type="submit"
    class="prodfile-button profile button--primary"
    >
    Save
    </button>
  </footer>
  </form>
  </section>
</div>
</template>

<style>
</style>