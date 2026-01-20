<template>
  <ToolLayout
    icon="🚧"
    title="工具迁移中"
    description="该工具正在迁移到 Vue 架构，敬请期待..."
  >
    <div style="text-align: center; padding: 60px 20px;">
      <p style="color: var(--color-text-secondary); margin-bottom: 20px;">
        该工具页面正在迁移中，请稍后再试。
      </p>
      <router-link to="/" class="btn">返回首页</router-link>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
</script>

<style scoped>
.btn {
  display: inline-block;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: 12px 24px;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  transition: transform .2s;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px var(--color-shadow-primary);
}
</style>
