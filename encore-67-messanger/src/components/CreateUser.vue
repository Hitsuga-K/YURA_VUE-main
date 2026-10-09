<script setup lang="ts">
import { computed, ref } from "vue";
import { open } from "@tauri-apps/plugin-dialog";
import { invoke } from "@tauri-apps/api/core";
import { getFileUrl } from "../types/file.ts";

export interface NewUserData {
    username: string;
    displayName: string;
    status: string;
    avatarPath: string | null;
}

const emit = defineEmits<{
    save: [user: NewUserData];
    close: [];
}>();

const username = ref("");
const displayName = ref("");
const status = ref("В сети");
const avatarPath = ref<string | null>(null);

const avatarPreview = computed(() => {
    if (avatarPath.value) {
        return getFileUrl(avatarPath.value);
    }
    return null;
});

const initials = computed(() => {
    const name = displayName.value.trim() || username.value.trim() || "?";
    const parts = name.split(/\s+/).filter(Boolean);
    if (parts.length === 0) return "?";
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
});

const usernameValid = computed(() => {
    const v = username.value.trim();
    if (v.length < 3) return false;
    return /^[a-zA-Z0-9_]+$/.test(v);
});

const canSave = computed(() => {
    return usernameValid.value && displayName.value.trim().length > 0;
});

async function selectAvatar() {
    const file = await open({
        multiple: false,
        filters: [
            {
                name: "Image",
                extensions: ["png", "jpg", "jpeg", "webp", "gif"]
            }
        ]
    });

    if (!file || typeof file !== "string") {
        return;
    }

    try {
        const savedPath = await invoke<string>(
            "save_attachment",
            { source: file }
        );
        avatarPath.value = savedPath;
    } catch (error) {
        console.error("Failed to save avatar:", error);
    }
}

function submit() {
    if (!canSave.value) return;

    emit("save", {
        username: username.value.trim().toLowerCase(),
        displayName: displayName.value.trim(),
        status: status.value.trim(),
        avatarPath: avatarPath.value,
    });
}
</script>

<template>
    <div class="create_user_backdrop">
        <section class="create_user-card">
            <header class="create_user-card__header">
                <h2>
                    Новый пользователь
                </h2>
                <button
                   type="button"
                   class="create_user-card__close"
                   @click="emit('close')"
                >
                X
                </button>
            </header>
            <form
                class="create_user-form"
                @submit.prevent="submit"
            >
                <div class="create_user-avatar-row">
                    <button
                        type="button"
                        class="create_user-avatar"
                        @click="selectAvatar"
                        title="Выбрать аватар"
                    >
                        <img
                            v-if="avatarPreview"
                            :src="avatarPreview"
                            alt="Avatar"
                        />
                        <span v-else class="create_user-avatar__initials">
                            {{ initials }}
                        </span>
                    </button>
                    <div class="create_user-avatar-hint">
                        Нажмите на кружок, чтобы установить аватар
                    </div>
                </div>

                <label
                    for="cu-username"
                    class="create_user-field"
                >
                    <span>
                        Username <em>(только латиница, цифры, _)</em>
                    </span>
                    <input
                        id="cu-username"
                        v-model="username"
                        type="text"
                        maxlength="24"
                        placeholder="например ivan_33"
                    >
                    <small
                        v-if="username.trim().length > 0 && !usernameValid"
                        class="create_user-field__error"
                    >
                        Минимум 3 символа, только a-z 0-9 и _
                    </small>
                </label>

                <label
                    for="cu-display-name"
                    class="create_user-field"
                >
                    <span>
                        Имя в чате
                    </span>
                    <input
                        id="cu-display-name"
                        v-model="displayName"
                        type="text"
                        maxlength="40"
                        placeholder="Иван Петров"
                    >
                </label>

                <label
                    for="cu-status"
                    class="create_user-field"
                >
                    <span>
                        Статус
                    </span>
                    <textarea
                        id="cu-status"
                        v-model="status"
                        maxlength="120"
                        rows="2"
                    ></textarea>
                </label>
            </form>
            <footer
                class="create_user-actions"
            >
                <button
                    type="button"
                    class="create_user-button create_user-button--secondary"
                    @click="emit('close')"
                >
                    Отмена
                </button>

                <button
                    type="button"
                    class="create_user-button create_user-button--primary"
                    :disabled="!canSave"
                    @click="submit"
                >
                    Создать
                </button>
            </footer>
        </section>
    </div>
</template>

<style scoped>
.create_user_backdrop{
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
}

.create_user-card{
    width: 460px;
    max-width: calc(100vw - 40px);
    border: 1px solid #292c34;
    background: #17191f;
    border-radius: 10px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.create_user-card__header{
    padding: 14px 20px;
    border-bottom: 1px solid #292c34;
    background: #15171c;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
}

.create_user-card__header h2{
    margin: 0;
    font-size: 15px;
    font-weight: 600;
}

.create_user-card__close{
    width: 32px;
    height: 32px;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid #292c34;
    border-radius: 6px;
    background: #1b1e25;
    color: #858c98;
    cursor: pointer;
    font: inherit;
    font-weight: 600;
    transition: background-color 0.12s ease, color 0.12s ease, border-color 0.12s ease;
    flex-shrink: 0;
}

.create_user-card__close:hover{
    background: #22262f;
    color: #f2f3f5;
    border-color: #343842;
}

.create_user-card__close:active{
    background: #292d37;
}

.create_user-avatar-row{
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 2px;
}

.create_user-avatar{
    width: 72px;
    height: 72px;
    border-radius: 50%;
    overflow: hidden;
    border: 1px solid #343842;
    background: #20232a;
    padding: 0;
    cursor: pointer;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: border-color 0.15s ease, background-color 0.15s ease;
}

.create_user-avatar:hover{
    border-color: #386be0;
    background: #252830;
}

.create_user-avatar img{
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}

.create_user-avatar__initials{
    font-size: 26px;
    font-weight: 700;
    color: #afb5c0;
    user-select: none;
}

.create_user-avatar-hint{
    font-size: 12px;
    color: #858c98;
    line-height: 1.4;
}

.create_user-form{
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.create_user-field{
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.create_user-field > span{
    font-size: 12px;
    font-weight: 500;
    color: #858c98;
}

.create_user-field > span em{
    font-style: normal;
    color: #6a717d;
    font-weight: 400;
}

.create_user-field input,
.create_user-field textarea{
    width: 100%;
    padding: 8px 10px;
    border: 1px solid #2e323c;
    border-radius: 7px;
    background: #13151a;
    color: #f2f3f5;
    font: inherit;
    font-size: 13px;
    outline: none;
    transition: border-color 0.12s ease, background-color 0.12s ease;
    resize: vertical;
}

.create_user-field input:focus,
.create_user-field textarea:focus{
    border-color: #386be0;
    background: #15171c;
}

.create_user-field input::placeholder,
.create_user-field textarea::placeholder{
    color: #4a505c;
}

.create_user-field__error{
    margin-top: 2px;
    font-size: 11px;
    color: #e05050;
}

.create_user-actions{
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 10px;
    padding: 14px 20px;
    border-top: 1px solid #292c34;
    background: #15171c;
}

.create_user-button{
    padding: 8px 16px;
    border-radius: 7px;
    border: 1px solid transparent;
    cursor: pointer;
    font: inherit;
    font-size: 13px;
    font-weight: 500;
    transition: background-color 0.12s ease, color 0.12s ease, border-color 0.12s ease, opacity 0.12s ease;
}

.create_user-button--primary{
    background: #386be0;
    border-color: #386be0;
    color: #ffffff;
}

.create_user-button--primary:hover{
    background: #2f5cc4;
    border-color: #2f5cc4;
}

.create_user-button--primary:active{
    background: #2951aa;
    border-color: #2951aa;
}

.create_user-button--primary:disabled{
    opacity: 0.4;
    cursor: not-allowed;
}

.create_user-button--secondary{
    background: transparent;
    border-color: #343842;
    color: #afb5c0;
}

.create_user-button--secondary:hover{
    background: #20232a;
    color: #f2f3f5;
    border-color: #3f4450;
}

.create_user-button--secondary:active{
    background: #252830;
}
</style>
