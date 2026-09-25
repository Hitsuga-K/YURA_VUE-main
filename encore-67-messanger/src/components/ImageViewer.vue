<script setup lang="ts">
defineProps<{
  src: string;
  alt?: string;
}>();

const emit = defineEmits<{
  close: [];
}>();
</script>

<template>
  <div class="viewer-backdrop">
    <button
        type="button"
        class="viewer-close"
        @click="emit('close')"
    >
      ✕
    </button>

    <img
        class="viewer-image"
        :src="src"
        :alt="alt ?? 'image'"
    />
  </div>
</template>

<style scoped>
.viewer-backdrop{
  position: fixed;
  inset: 0;
  z-index: 1000;

  display: flex;
  align-items: center;
  justify-content: center;

  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(4px);
}

.viewer-image{
  max-width: 95vw;
  max-height: 95vh;
  object-fit: contain;
  border-radius: 8px;
}

.viewer-close{
  position: absolute;
  top: 16px;
  right: 16px;

  width: 40px;
  height: 40px;

  border: 1px solid #343842;
  border-radius: 8px;
  background: #20232a;
  color: #f2f3f5;
  font-size: 16px;
  cursor: pointer;
}

.viewer-close:hover{
  background: #292c34;
}
</style>