<script setup lang="ts">

import { ref } from "vue";
import EmojiPicker from "./EmojiPicker.vue";
import { open } from "@tauri-apps/plugin-dialog";
import { convertFileSrc } from "@tauri-apps/api/core";

const emit = defineEmits<{
    send: [body: string, attachments?: string[] | null];
}>();

const draft = ref("");
const inputRef = ref<HTMLInputElement | null>(null);
const attachments = ref<string[]>([]);
const isDragOver = ref(false);

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

function insertAtCursor(text: string) {
    const el = inputRef.value;
    if (!el) {
        draft.value += text;
        return;
    }

    const start = el.selectionStart ?? draft.value.length;
    const end = el.selectionEnd ?? draft.value.length;

    draft.value =
        draft.value.slice(0, start) +
        text +
        draft.value.slice(end);

    requestAnimationFrame(() => {
        const newPos = start + text.length;
        el.focus();
        el.setSelectionRange(newPos, newPos);
    });
}

function onPickEmoji(emoji: string) {
    insertAtCursor(emoji);
}

function addFiles(paths: string | string[] | null) {
    if (!paths) return;
    const arr = Array.isArray(paths) ? paths : [paths];
    for (const p of arr) {
        if (!attachments.value.includes(p)) {
            attachments.value.push(p);
        }
    }
}

async function openFilePicker() {
    const selected = await open({
        multiple: true,
        filters: [
            {
                name: "Images & Videos",
                extensions: ["png", "jpg", "jpeg", "webp", "gif", "bmp", "mp4", "webm", "mov"]
            }
        ]
    });

    addFiles(selected);
}

function removeAttachment(index: number) {
    attachments.value.splice(index, 1);
}

function submitMessage() {
    const body = draft.value.trim();
    const hasFiles = attachments.value.length > 0;

    if (!body && !hasFiles) return;

    emit("send", body, attachments.value.length > 0 ? [...attachments.value] : null);

    draft.value = "";
    attachments.value = [];
}

function onDragOver(e: DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    isDragOver.value = true;
}

function onDragLeave(e: DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    isDragOver.value = false;
}

function onDrop(e: DragEvent) {
    e.preventDefault();
    e.stopPropagation();
    isDragOver.value = false;

    const files = e.dataTransfer?.files;
    if (!files || files.length === 0) return;

    const paths: string[] = [];
    for (let i = 0; i < files.length; i++) {
        const f = files[i];
        const ext = f.name.split(".").pop()?.toLowerCase() ?? "";
        if (IMAGE_EXT.includes(ext) || VIDEO_EXT.includes(ext)) {
            const path = (f as File & { path?: string }).path;
            if (path) {
                paths.push(path);
            }
        }
    }
    if (paths.length) {
        addFiles(paths);
    }
}

</script>

<template>

    <form
        class="composer"
        :class="{ 'composer--dragover': isDragOver }"
        @submit.prevent="submitMessage"
        @dragover="onDragOver"
        @dragenter="onDragOver"
        @dragleave="onDragLeave"
        @drop="onDrop"
    >

        <div v-if="attachments.length" class="attachments">
            <div
                v-for="(file, index) in attachments"
                :key="index"
                class="attachments__item"
                :class="{ 'attachments__item--image': isImage(file), 'attachments__item--video': isVideo(file) }"
            >
                <div v-if="isImage(file)" class="attachments__preview">
                    <img :src="toAssetUrl(file)" :alt="getFileName(file)" class="attachments__img" />
                </div>
                <div v-else-if="isVideo(file)" class="attachments__preview attachments__preview--video">
                    <span class="attachments__videoicon">🎬</span>
                </div>
                <div v-else class="attachments__preview attachments__preview--file">
                    <span>📄</span>
                </div>
                <div class="attachments__info">
                    <span class="attachments__name">{{ getFileName(file) }}</span>
                </div>
                <button
                    type="button"
                    class="attachments__remove"
                    @click="removeAttachment(index)"
                    title="Remove"
                >×</button>
            </div>
        </div>

        <div v-if="isDragOver" class="drop-hint">
            📁 Отпустите, чтобы прикрепить файлы
        </div>

        <div class="composer__row">
            <button
                type="button"
                class="composer__attach"
                @click="openFilePicker"
                title="Attach image or video"
            >
                📎
            </button>

            <input
                ref="inputRef"
                v-model="draft"
                type="text"
                placeholder="Write something or drag files here..."
                autocomplete="off"
            />
            <EmojiPicker @pick="onPickEmoji" />
            <button type="submit">Send</button>
        </div>
    </form>

</template>

<style scoped>

.composer{
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 15px 20px;
  border-top: 1px solid #252830;
  background: #17191f;
  flex-shrink: 0;
  transition: background .15s ease, border-color .15s ease;
}

.composer--dragover{
  background: #1e2430;
  border-top-color: #4f7fea;
}

.drop-hint{
  padding: 14px;
  text-align: center;
  border: 2px dashed #4f7fea;
  border-radius: 8px;
  color: #8ab4ff;
  font-weight: 500;
  background: rgba(79, 127, 234, 0.08);
}

.composer__row{
  display: flex;
  gap: 10px;
  width: 100%;
}

.composer input{
  flex: 1;
  min-width: 0;
  padding: 11px 13px;
  border: 1px solid #343842;
  border-radius: 7px;
  outline: none;
  color: #f2f3f5;
  background: #20232a;
  font: inherit;
}

.composer input:focus{
  border-color: #4f7fea;
}

.composer button[type="submit"]{
  padding: 0 18px;
  border: none;
  border-radius: 7px;
  cursor: pointer;
  color: white;
  background: #c77b18;
  font: inherit;
  font-weight: 600;
  transition: background .12s ease;
}

.composer button[type="submit"]:hover{
  background: #d98a1f;
}

.composer__attach{
  padding: 0 14px;
  border: 1px solid #343842;
  border-radius: 7px;
  cursor: pointer;
  color: #f2f3f5;
  background: #20232a;
  font: inherit;
  font-size: 18px;
  line-height: 1;
  transition: border-color .15s ease, background .15s ease;
}

.composer__attach:hover{
  border-color: #4f7fea;
  background: #262a32;
}

.attachments{
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.attachments__item{
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px;
  background: #20232a;
  border: 1px solid #343842;
  border-radius: 8px;
  font-size: 13px;
  color: #d1d4da;
  max-width: 260px;
  position: relative;
}

.attachments__item--image,
.attachments__item--video{
  flex-direction: column;
  align-items: stretch;
  padding: 6px;
  max-width: 200px;
}

.attachments__preview{
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #17191f;
  border-radius: 6px;
  flex-shrink: 0;
  font-size: 18px;
}

.attachments__preview--video{
  background: linear-gradient(135deg, #2b313d, #3a4252);
}

.attachments__item--image .attachments__preview,
.attachments__item--video .attachments__preview{
  width: 100%;
  height: 120px;
  border-radius: 6px;
  overflow: hidden;
  background: #111318;
}

.attachments__img{
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.attachments__videoicon{
  font-size: 42px;
}

.attachments__info{
  flex: 1;
  min-width: 0;
}

.attachments__item--image .attachments__info,
.attachments__item--video .attachments__info{
  padding: 6px 4px 0;
}

.attachments__name{
  max-width: 180px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: block;
}

.attachments__item--image .attachments__name,
.attachments__item--video .attachments__name{
  max-width: 180px;
  font-size: 12px;
}

.attachments__remove{
  padding: 2px 8px;
  border: none;
  border-radius: 4px;
  background: #3a3f4a;
  color: #f2f3f5;
  cursor: pointer;
  font-size: 16px;
  line-height: 1.2;
  transition: background .12s ease;
  flex-shrink: 0;
}

.attachments__item--image .attachments__remove,
.attachments__item--video .attachments__remove{
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.7);
  border-radius: 50%;
  width: 24px;
  height: 24px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
}

.attachments__remove:hover{
  background: #ea5b5b;
}

.attachments__item--image .attachments__remove:hover,
.attachments__item--video .attachments__remove:hover{
  background: #ea5b5b;
}

</style>
