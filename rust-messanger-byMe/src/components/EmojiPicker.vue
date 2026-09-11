<script setup lang="ts">

import { ref } from "vue";

const emit = defineEmits<{
    pick: [emoji: string];
}>();

const EMOJIS: string[] = [
    "😀", "😂", "🥰", "😎", "🤔", 
];

const open = ref(false);

function toggle() {
    open.value = !open.value;
}

function pick(emoji: string) {
    emit("pick", emoji);
}

</script>

<template>
    <div class="emoji-picker">
        <button type="button" class="emoji-picker__toggle" @click="toggle" title="Emoji">
            E
        </button>

        <div v-if="open" class="emoji-picker__panel">
            <button
                v-for="emoji in EMOJIS"
                :key="emoji"
                type="button"
                class="emoji-picker__item"
                @click="pick(emoji)"
            >
                {{ emoji }}
            </button>
        </div>
    </div>
</template>

<style scoped>

.emoji-picker{
    position: relative;
}

.emoji-picker__toggle{
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

.emoji-picker__toggle:hover{
    border-color: #4f7fea;
    background: #262a32;
}

.emoji-picker__panel{
    position: absolute;
    right: 0;
    bottom: calc(100% + 8px);
    width: 280px;
    padding: 10px;
    display: grid;
    grid-template-columns: repeat(8, 1fr);
    gap: 4px;
    background: #17191f;
    border: 1px solid #2b2f38;
    border-radius: 10px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, .35);
    z-index: 10;
}

.emoji-picker__item{
    padding: 4px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    background: transparent;
    font-size: 20px;
    line-height: 1;
    transition: background .12s ease, transform .08s ease;
}

.emoji-picker__item:hover{
    background: #2a2e38;
    transform: scale(1.15);
}

</style>
