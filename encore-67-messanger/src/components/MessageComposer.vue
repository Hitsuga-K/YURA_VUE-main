<script setup lang="ts">
import {ref} from "vue";

import { open } from "@tauri-apps/plugin-dialog";

import { invoke } from "@tauri-apps/api/core";

// defineEmits - сообщает vue, какие из событий, данный
// компонент имеет право рассылать
const emit = defineEmits<{
  send: [body:string];
  sendImage: [path:string];
}>();


const draft = defineModel<string>({ default: "" });

function submitMessage(){
  // Взять введенный пользователем текст и убрать проблемы по краям
  const body = draft.value.trim();

  if(!body) return;

  emit("send", body);

  // После отправки очищаем поле ввода
  draft.value = "";
}

async function selectImage(){
  const file = await open({
    multiple: false,

    filters:[
      {
        name:"Image",
        extensions:[
            "png",
            "jpg",
            "jpeg",
            "webp",
            "gif"
        ]
      }
    ]
  });

  console.log(file)

  if(!file){
    return;
  }

  const savedPath =
      await invoke<string>(
          "save_attachment",
          {
            source:file
          }
      );

  // console.log(savedPath)

  emit(
      "sendImage",
      savedPath
  )

}
</script>

<template>
  <form
      class="composer"
      @submit.prevent="submitMessage"
  >
    <button
      type="button"
      class="image-button"
      @click="selectImage"
    >
      📎
    </button>
    <input
        v-model="draft"
        type="text"
        placeholder="Ну пиши уже че нить"
        autocomplete="off"
    />
    <button type="submit">Отправить</button>
  </form>
</template>

<style scoped>

.image-button{
  width: 42px;
  height: 42px;
  border: 1px solid var(--image-btn-border, #343842);
  border-radius: 8px;
  background: var(--image-btn-bg, #20232a);
  background-size: 100% 100%;
  cursor: pointer;
  font-size: 18px;
  transition: background 0.12s ease;
}

.image-button:hover{
  background: var(--image-btn-bg-hover, #292c34);
}
.composer{
  display: flex;
  gap: 10px;
  padding: 15px 20px;
  border-top: 1px solid var(--composer-border, #252830);
  background: var(--composer-bg, #17191f);
  background-size: 300% 100%;
  flex-shrink: 0;
}

.composer input{
  flex: 1;
  min-width: 0;
  padding: 11px 13px;
  border: 1px solid var(--composer-input-border, #343842);
  border-radius: 7px;
  outline: none;
  color: var(--composer-input-fg, #f2f3f5);
  background: var(--composer-input-bg, #20232a);
  font: inherit;
}
.composer input::placeholder{
  color: var(--composer-input-ph, #858c98);
}
.composer input:focus{
  border-color: var(--composer-input-border-focus, #4f7fea);
}

.composer button{
  padding: 0 18px;
  border: none;
  border-radius: 7px;
  cursor: pointer;
  color: var(--composer-btn-fg, white);
  background: var(--composer-btn-bg, #386be0);
  background-size: 300% 100%;
  font: inherit;
  font-weight: 600;
}

</style>