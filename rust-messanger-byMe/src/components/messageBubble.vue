<script setup lang="ts">

import type { Message } from "../types/message.ts";
import { computed, ref, onBeforeUnmount } from "vue";
import { convertFileSrc } from "@tauri-apps/api/core";
import { openPath } from "@tauri-apps/plugin-opener";

const props = defineProps < {
    message: Message;
    currentUserName: string;
} > ();

const isOwn = computed(() => props.message.author === props.currentUserName);

const IMAGE_EXT = ["png", "jpg", "jpeg", "webp", "gif", "bmp"];
const VIDEO_EXT = ["mp4", "webm", "mov", "avi", "mkv"];

const lightboxSrc = ref<string | null>(null);
const lightboxName = ref<string>("");

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

function openImageLightbox(file: string) {
    lightboxSrc.value = toAssetUrl(file);
    lightboxName.value = getFileName(file);
    document.addEventListener("keydown", onKeyDown);
    document.body.style.overflow = "hidden";
}

function closeLightbox() {
    lightboxSrc.value = null;
    lightboxName.value = "";
    document.removeEventListener("keydown", onKeyDown);
    document.body.style.overflow = "";
}

function onKeyDown(e: KeyboardEvent) {
    if (e.key === "Escape") {
        closeLightbox();
    }
}

async function openFileExternally(file: string) {
    try {
        if (isTauri()) {
            await openPath(file);
        } else {
            window.open(toAssetUrl(file), "_blank");
        }
    } catch {
        window.open(toAssetUrl(file), "_blank");
    }
}

onBeforeUnmount(() => {
    document.removeEventListener("keydown", onKeyDown);
    document.body.style.overflow = "";
});

</script>

<template>
    <article class="message" :class="{ 'message--own': isOwn, 'message--other': !isOwn }">

        <div v-if="message.attachments && message.attachments.length" class="message__attachments">
            <template v-for="(file, idx) in message.attachments" :key="idx">
                <div v-if="isImage(file)" class="message__media-wrap">
                    <img
                        :src="toAssetUrl(file)"
                        :alt="getFileName(file)"
                        class="message__media message__media--img"
                        @click="openImageLightbox(file)"
                        :title="'Click to enlarge • ' + getFileName(file)"
                    />
                    <button
                        type="button"
                        class="message__media-open"
                        @click="openFileExternally(file)"
                        title="Open externally"
                    >🔗</button>
                </div>
                <div v-else-if="isVideo(file)" class="message__media-wrap">
                    <video
                        :src="toAssetUrl(file)"
                        controls
                        class="message__media message__media--video"
                    ></video>
                    <button
                        type="button"
                        class="message__media-open"
                        @click="openFileExternally(file)"
                        title="Open externally"
                    >🔗</button>
                </div>
                <a
                    v-else
                    :href="toAssetUrl(file)"
                    class="message__file"
                    @click.prevent="openFileExternally(file)"
                >
                    📄 {{ getFileName(file) }}
                </a>
            </template>
        </div>

        <p v-if="message.body" class="message__body">
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

    <Teleport to="body">
        <div
            v-if="lightboxSrc"
            class="lightbox"
            @click.self="closeLightbox"
        >
            <button
                type="button"
                class="lightbox__close"
                @click="closeLightbox"
                title="Close (Esc)"
            >×</button>
            <img
                :src="lightboxSrc"
                :alt="lightboxName"
                class="lightbox__img"
            />
            <div class="lightbox__caption">{{ lightboxName }}</div>
        </div>
    </Teleport>
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

.message__body{
  margin: 0;
  line-height: 1.45;
  overflow-wrap: anywhere;
}

.message__attachments{
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.message__media-wrap{
  position: relative;
  display: inline-block;
  border-radius: 8px;
  overflow: hidden;
  background: rgba(0, 0, 0, 0.2);
}

.message__media{
  max-width: 100%;
  max-height: 320px;
  border-radius: 8px;
  object-fit: contain;
  display: block;
}

.message__media--img{
  cursor: zoom-in;
  transition: opacity .15s ease;
}

.message__media--img:hover{
  opacity: 0.92;
}

.message__media--video{
  cursor: pointer;
}

.message__media-open{
  position: absolute;
  top: 8px;
  right: 8px;
  width: 30px;
  height: 30px;
  border: none;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.65);
  color: #fff;
  font-size: 14px;
  cursor: pointer;
  opacity: 0;
  transition: opacity .15s ease, background .12s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.message__media-wrap:hover .message__media-open{
  opacity: 1;
}

.message__media-open:hover{
  background: rgba(0, 0, 0, 0.85);
}

.message__file{
  padding: 10px 14px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 8px;
  color: inherit;
  text-decoration: none;
  font-size: 13px;
  transition: background .12s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
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

.lightbox{
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.92);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  flex-direction: column;
  gap: 16px;
  cursor: zoom-out;
}

.lightbox__close{
  position: fixed;
  top: 20px;
  right: 24px;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  font-size: 28px;
  cursor: pointer;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background .12s ease;
  z-index: 10000;
}

.lightbox__close:hover{
  background: rgba(255, 255, 255, 0.22);
}

.lightbox__img{
  max-width: 100%;
  max-height: calc(100vh - 120px);
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.5);
}

.lightbox__caption{
  color: #bbb;
  font-size: 13px;
  max-width: 80vw;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

</style>
