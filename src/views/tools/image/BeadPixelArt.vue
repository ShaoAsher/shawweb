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
      <div class="preview-trigger" @click="openFullscreenPreview">
        <div class="bead-grid thumb" :style="gridStyle">
          <div v-for="(row, i) in pixelData" :key="i" class="bead-row">
            <div
              v-for="(cell, j) in row"
              :key="j"
              class="bead-cell"
              :style="{ backgroundColor: cell }"
            />
          </div>
        </div>
        <span class="preview-tip">点击全屏预览 · 可缩放</span>
      </div>
      <p class="meta">共 {{ pixelData.length }} × {{ pixelData[0]?.length || 0 }} 格</p>
      <ButtonGroup style="margin-top: 12px;">
        <AppButton variant="primary" icon="🔍" @click="openFullscreenPreview">
          全屏预览
        </AppButton>
        <AppButton variant="primary" icon="⬇️" @click="downloadPng">
          导出 PNG
        </AppButton>
      </ButtonGroup>
    </div>

    <!-- 全屏预览弹窗：正方形居中、可缩放，适配 H5 -->
    <Teleport to="body">
      <Transition name="preview-fade">
        <div
          v-if="fullscreenPreview"
          class="preview-fullscreen"
          @click.self="closeFullscreenPreview"
        >
          <div class="preview-fullscreen-square" ref="previewSquareRef">
            <div
              class="preview-fullscreen-inner"
              :style="fullscreenGridWrapStyle"
              @touchstart="onPreviewTouchStart"
              @touchmove.prevent="onPreviewTouchMove"
              @touchend="onPreviewTouchEnd"
              @wheel.prevent="onPreviewWheel"
            >
              <div
                class="bead-grid fullscreen-grid"
                :style="fullscreenGridStyle"
              >
                <div v-for="(row, i) in pixelData" :key="i" class="bead-row">
                  <div
                    v-for="(cell, j) in row"
                    :key="j"
                    class="bead-cell"
                    :style="{ backgroundColor: cell }"
                  />
                </div>
              </div>
            </div>
            <div class="preview-zoom-controls">
              <button type="button" class="zoom-btn" @click="zoomOut" aria-label="缩小">−</button>
              <span class="zoom-value">{{ Math.round(zoomLevel * 100) }}%</span>
              <button type="button" class="zoom-btn" @click="zoomIn" aria-label="放大">+</button>
            </div>
          </div>
          <button
            type="button"
            class="preview-close"
            aria-label="关闭"
            @click="closeFullscreenPreview"
          >
            ×
          </button>
        </div>
      </Transition>
    </Teleport>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
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

const fullscreenPreview = ref(false)
const previewSquareRef = ref(null)
const zoomLevel = ref(1)
const scaleToFit = ref(1)
const MODAL_CELL_PX = 8
const MIN_ZOOM = 0.25
const MAX_ZOOM = 4
const touchStartDist = ref(0)
const touchStartZoom = ref(1)

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

const cols = computed(() => pixelData.value?.[0]?.length || 0)
const rows = computed(() => pixelData.value?.length || 0)

const fullscreenGridStyle = computed(() => ({
  '--cell-size': `${MODAL_CELL_PX}px`,
  '--cols': cols.value,
  '--rows': rows.value
}))

const fullscreenGridWrapStyle = computed(() => {
  const scale = scaleToFit.value * zoomLevel.value
  return {
    transform: `scale(${scale})`,
    width: `${cols.value * MODAL_CELL_PX}px`,
    height: `${rows.value * MODAL_CELL_PX}px`
  }
})

function openFullscreenPreview() {
  if (!pixelData.value?.length) return
  fullscreenPreview.value = true
  zoomLevel.value = 1
  nextTick(() => {
    const el = previewSquareRef.value
    if (!el) return
    const size = Math.min(el.clientWidth, el.clientHeight)
    const gridW = cols.value * MODAL_CELL_PX
    const gridH = rows.value * MODAL_CELL_PX
    scaleToFit.value = Math.min(1, size / gridW, size / gridH)
  })
}

function closeFullscreenPreview() {
  fullscreenPreview.value = false
}

function zoomIn() {
  zoomLevel.value = Math.min(MAX_ZOOM, zoomLevel.value + 0.25)
}

function zoomOut() {
  zoomLevel.value = Math.max(MIN_ZOOM, zoomLevel.value - 0.25)
}

function getTouchDistance(e) {
  if (e.touches.length < 2) return 0
  const a = e.touches[0]
  const b = e.touches[1]
  return Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY)
}

function onPreviewTouchStart(e) {
  if (e.touches.length === 2) {
    touchStartDist.value = getTouchDistance(e)
    touchStartZoom.value = zoomLevel.value
  }
}

function onPreviewTouchMove(e) {
  if (e.touches.length === 2 && touchStartDist.value > 0) {
    const d = getTouchDistance(e)
    const ratio = d / touchStartDist.value
    zoomLevel.value = Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, touchStartZoom.value * ratio))
  }
}

function onPreviewTouchEnd() {
  touchStartDist.value = 0
}

function onPreviewWheel(e) {
  if (e.deltaY < 0) zoomIn()
  else zoomOut()
}

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

.preview-trigger {
  padding: 12px;
  background: var(--color-surface);
  border-radius: var(--radius-sm);
  border: 2px solid var(--color-border);
  cursor: pointer;
  display: inline-block;
  max-width: 100%;
}

.preview-trigger .bead-grid.thumb {
  --cell-size: 6px;
  max-width: 100%;
  max-height: 180px;
  overflow: hidden;
  display: block;
}

.preview-tip {
  display: block;
  margin-top: 8px;
  font-size: 12px;
  color: var(--color-text-secondary);
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

/* 全屏预览弹窗：适配 H5，正方形居中 */
.preview-fullscreen {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0, 0, 0, 0.92);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left);
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
}

.preview-fullscreen-square {
  width: 90vmin;
  height: 90vmin;
  max-width: 90vmin;
  max-height: 90vmin;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: auto;
  -webkit-overflow-scrolling: touch;
  position: relative;
}

.preview-fullscreen-inner {
  flex-shrink: 0;
  transform-origin: center center;
  touch-action: none;
}

.preview-fullscreen-inner .fullscreen-grid {
  display: grid;
  grid-template-columns: repeat(var(--cols), var(--cell-size));
  grid-template-rows: repeat(var(--rows), var(--cell-size));
  gap: 0;
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.1);
}

.preview-fullscreen-inner .bead-cell {
  width: var(--cell-size);
  height: var(--cell-size);
  box-sizing: border-box;
  border: 1px solid rgba(0, 0, 0, 0.12);
}

.preview-zoom-controls {
  position: fixed;
  bottom: calc(env(safe-area-inset-bottom) + 16px);
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 24px;
  z-index: 10000;
}

.zoom-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.2);
  color: #fff;
  font-size: 24px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  -webkit-tap-highlight-color: transparent;
}

.zoom-btn:active {
  background: rgba(255, 255, 255, 0.35);
}

.zoom-value {
  min-width: 52px;
  text-align: center;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
}

.preview-close {
  position: fixed;
  top: calc(env(safe-area-inset-top) + 12px);
  right: calc(env(safe-area-inset-right) + 12px);
  width: 44px;
  height: 44px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.15);
  color: #fff;
  font-size: 28px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  -webkit-tap-highlight-color: transparent;
}

.preview-close:active {
  background: rgba(255, 255, 255, 0.3);
}

.preview-fade-enter-active,
.preview-fade-leave-active {
  transition: opacity 0.2s ease;
}

.preview-fade-enter-from,
.preview-fade-leave-to {
  opacity: 0;
}
</style>
