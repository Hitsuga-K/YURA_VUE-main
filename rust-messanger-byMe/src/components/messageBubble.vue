<script setup lang="ts">

import type { Message } from "../types/message.ts";
import { computed } from "vue";
import { convertFileSrc } from "@tauri-apps/api/core";

const props = defineProps < {
    message: Message;
    currentUserName: string;
} > ();

const isOwn = computed(() => props.message.author === props.currentUserName);

const IMAGE_EXT = ["png", "jpg", "jpeg", "webp", "gif", "bmp"];
const VIDEO_EXT = ["mp4", "webm", "mov", "avi", "mkv"];

function isTauri(): boolean {
    return typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;
}

function toAssetUrl(file: string): string {
    if (isTauri()) {
        try {
            return convertFileSrc(file);
        } catch {
            return file;
        }
    }
    return file;
}

function getExt(file: string): string {
    return file.split(".").pop()?.toLowerCase() ?? "";
}

function isImage(file: string): boolean {
    return IMAGE_EXT.includes(getExt(file));
}

function isVideo(file: string): boolean {
    return VIDEO_EXT.includes(getExt(file));
}

function getFileName(file: string): string {
    return file.split(/[\\/]/).pop() ?? file;
}

</script>

<template>
    <article class="message" :class="{ 'message--own': isOwn, 'message--other': !isOwn }">

        <div v-if="message.attachments && message.attachments.length" class="message__attachments">
            <template v-for="(file, idx) in message.attachments" :key="idx">
                <img
                    v-if="isImage(file)"
                    :src="toAssetUrl(file)"
                    :alt="getFileName(file)"
                    class="message__media"
                />
                <video
                    v-else-if="isVideo(file)"
                    :src="toAssetUrl(file)"
                    controls
                    class="message__media"
                ></video>
                <a
                    v-else
                    :href="toAssetUrl(file)"
                    class="message__file"
                >
                    📄 {{ getFileName(file) }}
                </a>
            </template>
        </div>

        <p v-if="message.body">
            {{ message.body }}
        </p>
        <footer>
            <span>
                {{ message.author }}
            </span>
            <span>
                {{ message.created_at }}
            </span>
        </footer>
    </article>
</template>

<style scoped>

.message{
  max-width: 70%;
  margin: 0;
  padding: 10px 12px;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.message--own{
  align-self: flex-end;
  background: #c77b18;
}

.message--other{
  align-self: flex-start;
  background: #2b313d;
}

.message p{
  margin: 0;
  line-height: 1.45;
  overflow-wrap: anywhere;
}

.message__attachments{
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.message__media{
  max-width: 100%;
  max-height: 320px;
  border-radius: 8px;
  object-fit: contain;
  background: rgba(0, 0, 0, 0.2);
}

.message__file{
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 6px;
  color: inherit;
  text-decoration: none;
  font-size: 13px;
  transition: background .12s ease;
}

.message__file:hover{
  background: rgba(0, 0, 0, 0.3);
}

.message--own footer{
  display: flex;
  justify-content: flex-end;
  gap: 5px;
  margin-top: 2px;
  color: #ccd8f7;
  font-size: 10px;
}

.message--other footer{
  display: flex;
  justify-content: flex-start;
  gap: 5px;
  margin-top: 2px;
  color: #a6adb9;
  font-size: 10px;
}

</style>
