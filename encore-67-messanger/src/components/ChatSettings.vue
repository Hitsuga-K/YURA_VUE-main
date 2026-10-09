<script setup lang="ts">
import { computed, ref } from "vue";
import { open } from "@tauri-apps/plugin-dialog";
import { invoke } from "@tauri-apps/api/core";
import { getFileUrl } from "../types/file.ts";

import type {
    Chat,
    ChatSettingsUpdate,
} from "../types/chats";

const props = defineProps<{
    chat: Chat;
    currentWallpaperPath: string | null;
}>();

const emit = defineEmits<{
    save: [
        settings: ChatSettingsUpdate
    ];
    close: [];
}>();

const wallpaperPath = ref<string | null>(props.currentWallpaperPath);

const wallpaperPreview = computed(() => {
    if (wallpaperPath.value) {
        return getFileUrl(wallpaperPath.value);
    }
    return null;
});

async function selectWallpaper() {
    const file = await open({
        multiple: false,
        filters: [
            {
                name: "Image",
                extensions: ["png", "jpg", "jpeg", "webp"]
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
        wallpaperPath.value = savedPath;
    } catch (error) {
        console.error("Failed to save wallpaper:", error);
    }
}

function removeWallpaper() {
    wallpaperPath.value = null;
}

function submitSettings() {
    emit(
        "save",
        {
            chatId: props.chat.id,
            userId: -1,
            wallpaperPath: wallpaperPath.value,
        },
    );
}
</script>

<template>
    <div class="chat_settings_backdrop">
        <section class="chat_settings-card">
            <header class="chat_settings-card__header">
                <h2>
                    Настройка чата: {{ chat.title }}
                </h2>
                <button
                   type="button"
                   class="chat_settings-card__close"
                   @click="emit('close')"
                >
                X
                </button>
            </header>

            <div class="chat_settings-body">
                <div class="chat_settings-label">
                    Обои для чата
                </div>
                <div class="chat_settings-wallpaper-row">
                    <div class="chat_settings-preview">
                        <img
                            v-if="wallpaperPreview"
                            :src="wallpaperPreview"
                            alt="Wallpaper"
                        />
                        <div v-else class="chat_settings-preview--empty">
                            <span>Нет обоев</span>
                        </div>
                    </div>

                    <div class="chat_settings-buttons">
                        <button
                            type="button"
                            class="profile-button profile-button--secondary"
                            @click="selectWallpaper"
                        >
                            Выбрать изображение
                        </button>

                        <button
                            type="button"
                            class="profile-button profile-button--secondary"
                            :disabled="!wallpaperPath"
                            @click="removeWallpaper"
                        >
                            Удалить обои
                        </button>
                    </div>
                </div>

                <div class="chat_settings-hint">
                    Обои видны только вам, другие пользователи их не увидят.
                </div>
            </div>

            <footer class="chat_settings-actions">
                <button
                    type="button"
                    class="profile-button profile-button--secondary"
                    @click="emit('close')"
                >
                    Отмена
                </button>

                <button
                    type="button"
                    class="profile-button profile-button--primary"
                    @click="submitSettings"
                >
                    Сохранить
                </button>
            </footer>
        </section>
    </div>
</template>

<style scoped>
.chat_settings_backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
}

.chat_settings-card {
    width: 520px;
    max-width: calc(100vw - 40px);
    border: 1px solid #292c34;
    background: #17191f;
    border-radius: 10px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.chat_settings-card__header {
    padding: 14px 20px;
    border-bottom: 1px solid #292c34;
    background: #15171c;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
}

.chat_settings-card__header h2 {
    margin: 0;
    font-size: 15px;
    font-weight: 600;
}

.chat_settings-card__close {
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

.chat_settings-card__close:hover {
    background: #22262f;
    color: #f2f3f5;
    border-color: #343842;
}

.chat_settings-card__close:active {
    background: #292d37;
}

.chat_settings-body {
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.chat_settings-label {
    font-size: 12px;
    font-weight: 500;
    color: #858c98;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}

.chat_settings-wallpaper-row {
    display: flex;
    align-items: flex-start;
    gap: 16px;
}

.chat_settings-preview {
    width: 160px;
    height: 110px;
    border: 1px solid #292c34;
    border-radius: 8px;
    overflow: hidden;
    background: #1f2229;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
}

.chat_settings-preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}

.chat_settings-preview--empty {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: repeating-linear-gradient(
        45deg,
        #1f2229,
        #1f2229 8px,
        #252830 8px,
        #252830 16px
    );
}

.chat_settings-preview--empty span {
    padding: 4px 10px;
    background: rgba(15, 17, 22, 0.65);
    border: 1px solid #2e323c;
    border-radius: 5px;
    color: #858c98;
    font-size: 11px;
}

.chat_settings-buttons {
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: flex-start;
    padding-top: 2px;
}

.chat_settings-hint {
    padding: 10px 12px;
    border: 1px solid #292c34;
    border-radius: 7px;
    background: #15171c;
    color: #858c98;
    font-size: 12px;
    line-height: 1.45;
}

.chat_settings-actions {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 10px;
    padding: 14px 20px;
    border-top: 1px solid #292c34;
    background: #15171c;
}

.profile-button {
    padding: 8px 16px;
    border-radius: 7px;
    border: 1px solid transparent;
    cursor: pointer;
    font: inherit;
    font-size: 13px;
    font-weight: 500;
    transition: background-color 0.12s ease, color 0.12s ease, border-color 0.12s ease, opacity 0.12s ease;
}

.profile-button--primary {
    background: #386be0;
    border-color: #386be0;
    color: #ffffff;
}

.profile-button--primary:hover {
    background: #2f5cc4;
    border-color: #2f5cc4;
}

.profile-button--primary:active {
    background: #2951aa;
    border-color: #2951aa;
}

.profile-button--secondary {
    background: transparent;
    border-color: #343842;
    color: #afb5c0;
}

.profile-button--secondary:hover {
    background: #20232a;
    color: #f2f3f5;
    border-color: #3f4450;
}

.profile-button--secondary:active {
    background: #252830;
}

.profile-button--secondary:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}
</style>
