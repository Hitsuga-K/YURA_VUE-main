<script setup lang="ts">

//defineProps - спец конструкция bue которая сообщает:
//>этот компонент ожидает получения данных от родительского компонента
defineProps<{
  status: string;
}>();
</script>

<template>
  <header class="header">
    <div>
      <h1>Rust-Messenger(byMe)</h1>

      <p>{{ status }}</p>
    </div>

    <span class="badge">
      Local
    </span>
  </header>
</template>

<style scoped>
/* scoped - CSS этого блока будет относится только к текущему vue компоненту */
/*/ Например .header не будет применяться к другим header в других vue компонентах /*/

.header {
  display: flex; /* - */
  flex-shrink: 0; /* Управляет может ли flex уменьшать элемент */
  align-items: center;
  justify-content: space-between;
  padding: 18px 24px;
  border-bottom: 1px solid #292c34;
  background: #17191f;
}

.header h1 {
  margin: 0;
  font-size: 18px;
}

.header p {
  margin: 4px 0 0;
  color: #8f96a3;
}

.badge {
  padding: 6px 10px;
  border: 1px solid #343842;
  border-radius: 6px; /* - */
  color: #afb5c0;
  background: #20232a;
  font-size: 12px;
}
</style>