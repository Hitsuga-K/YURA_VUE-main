<script setup lang="ts">
import {computed, ref} from "vue";
import { open } from "@tauri-apps/plugin-dialog";
import { invoke } from "@tauri-apps/api/core";
import { getFileUrl } from "../types/file.ts";

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

const displayName = ref(props.user.display_name);
const userStatus = ref(props.user.status);
const avatarPath = ref<string | null>(props.user.avatar_path);

const avatarPreview = computed(() => {
    if (avatarPath.value) {
        return getFileUrl(avatarPath.value);
    }
    return null;
});

const initials = computed(() => {
    const name = displayName.value.trim() || props.user.username;
    const parts = name.split(/\s+/).filter(Boolean);
    if (parts.length === 0) return "?";
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
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

function submitProfile() {
    const cleanDisplayName = displayName.value.trim();

    if (!cleanDisplayName) {
        return;
    }

    emit(
        "save",
        {
            displayName: cleanDisplayName,
            status: userStatus.value.trim(),
            avatarPath: avatarPath.value,
        },
    );
}

</script>

<template>
    <div class="profile_backdrop">
        <section class="profile-card">
            <header class="profile-card__header">
                <h2>
                    Profile
                </h2>
                <button
                   type="button"
                   class="profile-card__close"
                   @click="emit('close')"
                >
                X
                </button>
            </header>
            <form
                id="profile-form-id"
                class="profile-form"
                @submit.prevent="submitProfile"
            >
                <div class="profile-avatar-row">
                    <button
                        type="button"
                        class="profile-avatar"
                        @click="selectAvatar"
                        title="Выбрать аватар"
                    >
                        <img
                            v-if="avatarPreview"
                            :src="avatarPreview"
                            alt="Avatar"
                        />
                        <span v-else class="profile-avatar__initials">
                            {{ initials }}
                        </span>
                    </button>
                    <div class="profile-avatar-hint">
                        Нажмите на кружок, чтобы установить аватар
                    </div>
                </div>

                <label
                    for="profile-display-name"
                    class="profile-field"
                >
                    <span>
                        Displayed Name
                    </span>
                    <input
                        id="profile-display-name"
                        v-model="displayName"
                        type="text"
                        maxlength="40"
                    >
                </label>

                <label
                    for="profile-status"
                    class="profile-field"
                >
                    <span>
                        Status
                    </span>

                    <textarea
                        id="profile-status"
                        v-model="userStatus"
                        maxlength="120"
                        rows="3"
                    ></textarea>
                </label>

                <div
                    class="profile-username"
                >
                    <span>
                        Username
                    </span>

                    <strong>
                        @{{ user.username }}
                    </strong>

                </div>

                <footer
                    class="profile-actions"
                >
                    <button
                        type="button"
                        class="profile-button profile-button--secondary"
                        @click="emit('close')"
                    >
                        Cancel
                    </button>

                    <button
                        type="submit"
                        class="profile-button profile-button--primary"
                        @click="submitProfile"
                    >
                        Save
                    </button>
                </footer>

            </form>
        </section>
    </div>
</template>

<style scoped>
.profile_backdrop{
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
}

.profile-card{
    width: 420px;
    max-width: calc(100% - 32px);
    background: #17191f;
    border: 1px solid #292c34;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

.profile-card__header{
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border-bottom: 1px solid #292c34;
    background: #15171c;
}

.profile-card__header h2{
    margin: 0;
    font-size: 16px;
    font-weight: 600;
}

.profile-card__close{
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    border: 1px solid transparent;
    border-radius: 6px;
    background: transparent;
    color: #8f96a3;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    transition: background-color 0.15s ease, color 0.15s ease, border-color 0.15s ease;
}

.profile-card__close:hover{
    background: #20232a;
    border-color: #343842;
    color: #f2f3f5;
}

.profile-card__close:active{
    background: #252830;
}

.profile-avatar-row{
    display: flex;
    align-items: center;
    gap: 16px;
}

.profile-avatar{
    width: 80px;
    height: 80px;
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

.profile-avatar:hover{
    border-color: #386be0;
    background: #252830;
}

.profile-avatar img{
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}

.profile-avatar__initials{
    font-size: 28px;
    font-weight: 700;
    color: #afb5c0;
    user-select: none;
}

.profile-avatar-hint{
    font-size: 12px;
    color: #858c98;
    line-height: 1.4;
}

.profile-form{
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.profile-field{
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.profile-field > span{
    font-size: 13px;
    font-weight: 500;
    color: #afb5c0;
}

.profile-field input,
.profile-field textarea{
    width: 100%;
    box-sizing: border-box;
    padding: 10px 12px;
    border: 1px solid #343842;
    border-radius: 8px;
    background: #20232a;
    color: #f2f3f5;
    font: inherit;
    font-size: 14px;
    line-height: 1.4;
    resize: vertical;
    transition: border-color 0.15s ease, background-color 0.15s ease;
}

.profile-field input:hover,
.profile-field textarea:hover{
    border-color: #3f4450;
}

.profile-field input:focus,
.profile-field textarea:focus{
    outline: none;
    border-color: #386be0;
    background: #1e2128;
}

.profile-username{
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding: 12px;
    border: 1px solid #292c34;
    border-radius: 8px;
    background: #15171c;
}

.profile-username > span{
    font-size: 12px;
    color: #858c98;
}

.profile-username strong{
    font-size: 14px;
    font-weight: 600;
    color: #f2f3f5;
}

.profile-actions{
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 10px;
    padding: 14px 20px;
    margin: 4px -20px -20px;
    border-top: 1px solid #292c34;
    background: #15171c;
}

.profile-button{
    padding: 9px 18px;
    border: 1px solid transparent;
    border-radius: 8px;
    cursor: pointer;
    font: inherit;
    font-size: 14px;
    font-weight: 500;
    transition: background-color 0.15s ease, border-color 0.15s ease, color 0.15s ease;
}

.profile-button--secondary{
    background: transparent;
    border-color: #343842;
    color: #afb5c0;
}

.profile-button--secondary:hover{
    background: #20232a;
    border-color: #3f4450;
    color: #f2f3f5;
}

.profile-button--secondary:active{
    background: #252830;
}

.profile-button--primary{
    background: #386be0;
    border-color: #386be0;
    color: #ffffff;
}

.profile-button--primary:hover{
    background: #2f5cc4;
    border-color: #2f5cc4;
}

.profile-button--primary:active{
    background: #2950ad;
}

.profile-button:focus-visible{
    outline: 2px solid #6f94ee;
    outline-offset: 2px;
}
</style>