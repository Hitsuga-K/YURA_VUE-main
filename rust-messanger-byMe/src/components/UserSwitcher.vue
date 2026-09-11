<script setup lang="ts">

import type {User} from "../types/user";
defineProps<{
    users: User[];
    currentUserId: number;
}>();

const emit = defineEmits<{
    select: [user: User];
}>();

function selectUser(user: User){
    emit("select", user);
}

</script>

<template>
<div class="user-switcher">
    <span class="user-switcher__label">Write:</span>
    <button v-for="user in users"
        :key="user.id"
        type="button"
        class="user-switcher__button"
        :class="{
            'user-switcher__button--active':
            user.id === currentUserId
        }"
        @click="selectUser(user)"
    >
        {{ user.name }}
    </button>
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

.user-switcher__button{
    padding: 4px 8px;
    border: 1px solid #343842;
    border-radius: 6px;
    color: #afb5c0;
    font: inherit;
    font-size: 12px;
}

.user-switcher__button--active{
    background-color: #343842;
    border-color: #386be0;
    color: #f2f3f5;
}
</style>