<template>
  <ToolLayout
    icon="🧩"
    title="拼豆像素图工具"
    description="上传图片，生成拼豆/像素风格图，可限制色板、调节像素数量并导出 PNG。"
  >
    <div class="form-section">
      <h2>选择图片</h2>
      <ImageUploader
        v-model="uploadFile"
        icon="🖼️"
        text="点击或拖拽图片到此处"
        hint="支持 JPG、PNG、WEBP、GIF"
        preview-title="已选图片"
        @change="onImageChange"
        @delete="onImageDelete"
      />
    </div>

    <div v-if="sourceImage" class="form-section">
      <h2>生成设置</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="beadsW">横向像素数（拼豆格数）</label>
          <input
            id="beadsW"
            v-model.number="beadsW"
            type="number"
            min="8"
            max="120"
            placeholder="如 40"
          />
          <span class="hint">越大细节越多，图越大</span>
        </div>
        <div class="form-group">
          <label for="beadSize">每格显示尺寸（像素）</label>
          <input
            id="beadSize"
            v-model.number="beadSize"
            type="number"
            min="4"
            max="32"
            placeholder="如 12"
          />
          <span class="hint">仅影响预览与导出尺寸</span>
        </div>
        <div class="form-group">
          <label class="checkbox-label">
            <input v-model="usePalette" type="checkbox" />
            使用拼豆色板（限制颜色数量）
          </label>
        </div>
      </div>
      <ButtonGroup>
        <AppButton
          variant="primary"
          icon="🧩"
          :disabled="generating"
          @click="generate"
        >
          {{ generating ? '生成中...' : '生成拼豆图' }}
        </AppButton>
      </ButtonGroup>
    </div>

    <div v-if="pixelData" class="form-section">
      <h2>拼豆图预览</h2>
      <div class="preview-wrap">
        <div
          class="bead-grid"
          :style="gridStyle"
        >
          <div
            v-for="(row, i) in pixelData"
            :key="i"
            class="bead-row"
          >
            <div
              v-for="(cell, j) in row"
              :key="j"
              class="bead-cell"
              :style="{ backgroundColor: cell }"
            />
          </div>
        </div>
      </div>
      <p class="meta">共 {{ pixelData.length }} × {{ pixelData[0]?.length || 0 }} 格</p>
      <ButtonGroup style="margin-top: 12px;">
        <AppButton variant="primary" icon="⬇️" @click="downloadPng">
          导出 PNG
        </AppButton>
      </ButtonGroup>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import ImageUploader from '@/components/ImageUploader.vue'
import AppButton from '@/components/AppButton.vue'
import ButtonGroup from '@/components/ButtonGroup.vue'

const uploadFile = ref(null)
const sourceImage = ref(null)
const beadsW = ref(40)
const beadSize = ref(12)
const usePalette = ref(true)
const generating = ref(false)
const pixelData = ref(null)

/** 常见拼豆色板（HEX） */
const BEAD_PALETTE = [
  '#FFFFFF', '#000000', '#C41E3A', '#0047AB', '#228B22', '#FFD700', '#FF8C00',
  '#FF69B4', '#8B4513', '#87CEEB', '#9370DB', '#808080', '#FF0000', '#00CED1',
  '#FFC0CB', '#32CD32', '#D2691E', '#4B0082', '#F0E68C', '#2F4F4F', '#DC143C',
  '#00FA9A', '#FF1493', '#1E90FF', '#FFD700', '#ADFF2F', '#FF6347', '#40E0D0'
]

const gridStyle = computed(() => ({
  '--cell-size': `${beadSize.value}px`,
  '--cols': pixelData.value?.[0]?.length || 0,
  '--rows': pixelData.value?.length || 0
}))

function hexToRgb(hex) {
  const n = parseInt(hex.slice(1), 16)
  return { r: (n >> 16) & 0xff, g: (n >> 8) & 0xff, b: n & 0xff }
}

function rgbToHex(r, g, b) {
  return '#' + [r, g, b].map(x => {
    const h = Math.round(x).toString(16)
    return h.length === 1 ? '0' + h : h
  }).join('').toUpperCase()
}

/** 在色板中找最接近的颜色 */
function nearestPaletteColor(r, g, b) {
  let best = BEAD_PALETTE[0]
  let bestD = 1e9
  for (const hex of BEAD_PALETTE) {
    const { r: pr, g: pg, b: pb } = hexToRgb(hex)
    const d = (r - pr) ** 2 + (g - pg) ** 2 + (b - pb) ** 2
    if (d < bestD) {
      bestD = d
      best = hex
    }
  }
  return best
}

function onImageChange(file) {
  if (!file) return
  const reader = new FileReader()
  reader.onload = (e) => {
    const img = new Image()
    img.onload = () => {
      sourceImage.value = img
      pixelData.value = null
    }
    img.onerror = () => {
      sourceImage.value = null
    }
    img.src = e.target.result
  }
  reader.readAsDataURL(file)
}

function onImageDelete() {
  uploadFile.value = null
  sourceImage.value = null
  pixelData.value = null
}

function generate() {
  if (!sourceImage.value) return
  generating.value = true
  pixelData.value = null

  requestAnimationFrame(() => {
    try {
      const img = sourceImage.value
      const iw = img.naturalWidth || img.width
      const ih = img.naturalHeight || img.height
      const aspect = ih / iw
      const cols = Math.max(8, Math.min(120, beadsW.value))
      const rows = Math.max(8, Math.round(cols * aspect))

      const canvas = document.createElement('canvas')
      canvas.width = cols
      canvas.height = rows
      const ctx = canvas.getContext('2d')
      ctx.imageSmoothingEnabled = false
      ctx.drawImage(img, 0, 0, cols, rows)

      const data = ctx.getImageData(0, 0, cols, rows)
      const grid = []

      for (let y = 0; y < rows; y++) {
        const row = []
        for (let x = 0; x < cols; x++) {
          const i = (y * cols + x) * 4
          const r = data.data[i]
          const g = data.data[i + 1]
          const b = data.data[i + 2]
          const a = data.data[i + 3]
          let hex
          if (usePalette.value) {
            hex = nearestPaletteColor(r, g, b)
          } else {
            hex = rgbToHex(r, g, b)
          }
          if (a < 128) hex = '#FFFFFF'
          row.push(hex)
        }
        grid.push(row)
      }

      pixelData.value = grid
    } catch (err) {
      console.error(err)
    }
    generating.value = false
  })
}

function downloadPng() {
  if (!pixelData.value || pixelData.value.length === 0) return
  const rows = pixelData.value.length
  const cols = pixelData.value[0].length
  const size = beadSize.value
  const canvas = document.createElement('canvas')
  canvas.width = cols * size
  canvas.height = rows * size
  const ctx = canvas.getContext('2d')
  ctx.imageSmoothingEnabled = false

  for (let y = 0; y < rows; y++) {
    for (let x = 0; x < cols; x++) {
      ctx.fillStyle = pixelData.value[y][x]
      ctx.fillRect(x * size, y * size, size, size)
        }
  }

  const link = document.createElement('a')
  link.download = `bead-pixel-${cols}x${rows}.png`
  link.href = canvas.toDataURL('image/png')
  link.click()
}
</script>

<style scoped>
.form-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.form-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
  border-bottom: 2px solid var(--color-primary);
  padding-bottom: var(--spacing-sm);
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.form-group label {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  font-size: var(--font-size-small);
}

.form-group input[type="number"] {
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  background: var(--color-surface);
  color: var(--color-text);
  max-width: 120px;
}

.form-group input:focus {
  outline: none;
  border-color: var(--color-primary);
}

.checkbox-label {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.checkbox-label input {
  width: auto;
}

.hint {
  font-size: 12px;
  color: var(--color-text-secondary);
}

.preview-wrap {
  overflow: auto;
  max-width: 100%;
  padding: 12px;
  background: var(--color-surface);
  border-radius: var(--radius-sm);
  border: 2px solid var(--color-border);
}

.bead-grid {
  display: inline-grid;
  grid-template-columns: repeat(var(--cols), var(--cell-size));
  grid-template-rows: repeat(var(--rows), var(--cell-size));
  gap: 0;
  width: fit-content;
}

.bead-row {
  display: contents;
}

.bead-cell {
  width: var(--cell-size);
  height: var(--cell-size);
  box-sizing: border-box;
  border: 1px solid rgba(0, 0, 0, 0.08);
}

.meta {
  margin-top: 10px;
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}
</style>
