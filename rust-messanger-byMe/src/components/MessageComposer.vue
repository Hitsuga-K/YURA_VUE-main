<script setup lang="ts">

import { ref } from "vue";
import EmojiPicker from "./EmojiPicker.vue";
import { open } from "@tauri-apps/plugin-dialog";

const emit = defineEmits<{
    send: [body: string, attachments?: string[] | null];
}>();

const draft = ref("");
const inputRef = ref<HTMLInputElement | null>(null);
const attachments = ref<string[]>([]);

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

async function openFilePicker() {
    const selected = await open({
        multiple: false,
        filters: [
            {
                name: "Images",
                extensions: ["png", "jpg", "jpeg", "webp"]
            }
        ]
    });

    if (selected) {
        attachments.value.push(selected);
    }
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

</script>

<template>

    <form class="composer" @submit.prevent="submitMessage">

        <div v-if="attachments.length" class="attachments">
            <div
                v-for="(file, index) in attachments"
                :key="index"
                class="attachments__item"
            >
                <span class="attachments__name">{{ file.split(/[\\/]/).pop() }}</span>
                <button
                    type="button"
                    class="attachments__remove"
                    @click="removeAttachment(index)"
                    title="Remove"
                >×</button>
            </div>
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
                placeholder="Write something finally"
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

.composer > button[type="submit"]{
  padding: 0 18px;
  border: none;
  border-radius: 7px;
  cursor: pointer;
  color: white;
  background: #c77b18;
  font: inherit;
  font-weight: 600;
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
  gap: 8px;
}

.attachments__item{
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  background: #20232a;
  border: 1px solid #343842;
  border-radius: 7px;
  font-size: 13px;
  color: #d1d4da;
}

.attachments__name{
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.attachments__remove{
  padding: 0 6px;
  border: none;
  border-radius: 4px;
  background: #3a3f4a;
  color: #f2f3f5;
  cursor: pointer;
  font-size: 16px;
  line-height: 1;
  transition: background .12s ease;
}

.attachments__remove:hover{
  background: #ea5b5b;
}

</style>
