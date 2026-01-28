<template>
  <ToolLayout
    icon="🎯"
    title="决定转盘"
    description="添加选项，转动转盘帮你做决定，支持自定义选项列表"
  >
    <div class="decision-wheel">
      <div class="wheel-container">
        <!-- 转盘区域 -->
        <div class="wheel-section">
          <div class="wheel-wrapper">
            <!-- 指针 -->
            <div class="pointer"></div>
            <!-- 转盘 -->
            <div
              class="wheel"
              :style="{ transform: `rotate(${currentRotation}rad)` }"
              ref="wheelRef"
            >
              <svg
                :width="wheelSize"
                :height="wheelSize"
                viewBox="0 0 300 300"
                class="wheel-svg"
              >
                <g v-for="(item, index) in items" :key="index">
                  <path
                    :d="getSegmentPath(index)"
                    :fill="getColor(index)"
                    :stroke="'rgba(0,0,0,0.1)'"
                    stroke-width="2"
                  />
                  <text
                    :transform="getTextTransform(index)"
                    text-anchor="middle"
                    dominant-baseline="middle"
                    class="wheel-text"
                  >
                    {{ item }}
                  </text>
                </g>
              </svg>
              <!-- 中心按钮 -->
              <div class="center-button" @click="spin">
                <span>GO</span>
              </div>
            </div>
          </div>
          <!-- 结果显示 -->
          <div class="result-display">
            <div v-if="isSpinning" class="result-text spinning">
              好运流转中...
            </div>
            <div v-else-if="result" class="result-text result">
              结果是：<strong>{{ result }}</strong>
            </div>
            <div v-else class="result-text">准备好做决定了吗？</div>
          </div>
          <!-- 开始按钮 -->
          <button class="spin-button" @click="spin" :disabled="isSpinning || items.length < 2">
            <span>🎲</span>
            <span>开始转动</span>
          </button>
        </div>

        <!-- 选项列表区域 -->
        <div class="list-section">
          <div class="list-header">
            <h3>选项列表</h3>
            <div class="item-count">{{ items.length }} 个选项</div>
          </div>
          <div class="add-item-form">
            <input
              v-model="newItem"
              type="text"
              placeholder="添加新选项..."
              @keypress.enter="addItem"
              class="item-input"
            />
            <button class="add-button" @click="addItem" :disabled="!newItem.trim()">
              <span>➕</span>
            </button>
          </div>
          <div class="items-list">
            <div
              v-for="(item, index) in items"
              :key="index"
              class="item-row"
            >
              <span class="item-text">{{ item }}</span>
              <button
                class="delete-button"
                @click="removeItem(index)"
                :disabled="items.length <= 2"
                :title="items.length <= 2 ? '至少保留两个选项' : '删除'"
              >
                🗑️
              </button>
            </div>
            <div v-if="items.length === 0" class="empty-state">
              暂无选项，请添加至少两个选项
            </div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

// 状态
const items = ref(['吃火锅', '喝奶茶', '去运动', '看电影', '玩游戏', '睡大觉'])
const newItem = ref('')
const currentRotation = ref(0)
const isSpinning = ref(false)
const result = ref('')
const wheelRef = ref(null)

// 配置
const wheelSize = 300
const colors = [
  '#FFADAD',
  '#FFD6A5',
  '#FDFFB6',
  '#CAFFBF',
  '#9BF6FF',
  '#A0C4FF',
  '#BDB2FF',
  '#FFC6FF'
]

// 计算属性
const anglePerItem = computed(() => {
  return items.value.length > 0 ? (2 * Math.PI) / items.value.length : 0
})

// 方法
const getColor = (index) => {
  return colors[index % colors.length]
}

const getSegmentPath = (index) => {
  const centerX = 150
  const centerY = 150
  const radius = 150
  const startAngle = -Math.PI / 2 + index * anglePerItem.value
  const endAngle = startAngle + anglePerItem.value

  const x1 = centerX + radius * Math.cos(startAngle)
  const y1 = centerY + radius * Math.sin(startAngle)
  const x2 = centerX + radius * Math.cos(endAngle)
  const y2 = centerY + radius * Math.sin(endAngle)

  const largeArcFlag = anglePerItem.value > Math.PI ? 1 : 0

  return `M ${centerX} ${centerY} L ${x1} ${y1} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2} Z`
}

const getTextTransform = (index) => {
  const centerX = 150
  const centerY = 150
  const radius = 100 // 文字距离中心的距离
  const angle = -Math.PI / 2 + index * anglePerItem.value + anglePerItem.value / 2

  const x = centerX + radius * Math.cos(angle)
  const y = centerY + radius * Math.sin(angle)
  const rotation = (angle * 180) / Math.PI

  return `translate(${x}, ${y}) rotate(${rotation})`
}

const addItem = () => {
  const text = newItem.value.trim()
  if (text && !items.value.includes(text)) {
    items.value.push(text)
    newItem.value = ''
  }
}

const removeItem = (index) => {
  if (items.value.length > 2) {
    items.value.splice(index, 1)
    result.value = ''
  }
}

const spin = () => {
  if (isSpinning.value || items.value.length < 2) return

  isSpinning.value = true
  result.value = ''

  // 播放旋转音效（使用 Web Audio API）
  playSpinSound()

  // 随机旋转：5-10 圈 + 随机角度
  const fullRotations = 5 + Math.floor(Math.random() * 5)
  const randomAngle = Math.random() * 2 * Math.PI
  const endRotation = currentRotation.value + fullRotations * 2 * Math.PI + randomAngle

  // 使用 CSS 动画
  const duration = 4000 // 4秒
  const startRotation = currentRotation.value

  // 使用 requestAnimationFrame 实现平滑动画
  const startTime = performance.now()
  const animate = (currentTime) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / duration, 1)

    // 使用缓动函数
    const easeOutCubic = 1 - Math.pow(1 - progress, 3)
    currentRotation.value = startRotation + (endRotation - startRotation) * easeOutCubic

    if (progress < 1) {
      requestAnimationFrame(animate)
    } else {
      isSpinning.value = false
      calculateResult(endRotation)
      playResultSound()
    }
  }

  requestAnimationFrame(animate)
}

const calculateResult = (finalRotation) => {
  // 规范化旋转角度到 0-2π
  const normalizedRotation = finalRotation % (2 * Math.PI)
  if (normalizedRotation < 0) {
    normalizedRotation + 2 * Math.PI
  }

  // 指针固定在顶部 (-π/2)
  // 计算哪个扇区现在在指针位置
  const targetAngle = (-Math.PI / 2 - normalizedRotation) % (2 * Math.PI)
  const adjustedAngle = targetAngle < 0 ? targetAngle + 2 * Math.PI : targetAngle

  // 计算相对角度（从 -π/2 开始）
  let relativeAngle = adjustedAngle + Math.PI / 2
  relativeAngle = relativeAngle % (2 * Math.PI)
  if (relativeAngle < 0) relativeAngle += 2 * Math.PI

  // 计算索引
  const index = Math.floor(relativeAngle / anglePerItem.value)

  // 防止越界
  const finalIndex = Math.min(Math.max(0, index), items.value.length - 1)
  result.value = items.value[finalIndex]
}

const playSpinSound = () => {
  try {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()

    oscillator.connect(gainNode)
    gainNode.connect(audioContext.destination)

    oscillator.frequency.value = 200
    oscillator.type = 'sawtooth'

    gainNode.gain.setValueAtTime(0.2, audioContext.currentTime)
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3)

    oscillator.start(audioContext.currentTime)
    oscillator.stop(audioContext.currentTime + 0.3)
  } catch (e) {
    // 静默失败
  }
}

const playResultSound = () => {
  try {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()

    oscillator.connect(gainNode)
    gainNode.connect(audioContext.destination)

    oscillator.frequency.value = 600
    oscillator.type = 'sine'

    gainNode.gain.setValueAtTime(0.3, audioContext.currentTime)
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5)

    oscillator.start(audioContext.currentTime)
    oscillator.stop(audioContext.currentTime + 0.5)
  } catch (e) {
    // 静默失败
  }
}

onMounted(() => {
  // 初始化
})
</script>

<style scoped>
.decision-wheel {
  padding: 40px 20px;
  min-height: 600px;
}

.wheel-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  max-width: 1200px;
  margin: 0 auto;
}

/* 转盘区域 */
.wheel-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.wheel-wrapper {
  position: relative;
  width: 300px;
  height: 300px;
  margin-top: 20px;
}

.pointer {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 0;
  height: 0;
  border-left: 15px solid transparent;
  border-right: 15px solid transparent;
  border-top: 40px solid #ff5252;
  z-index: 10;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.wheel {
  position: relative;
  width: 300px;
  height: 300px;
  transition: transform 0.1s linear;
  border-radius: 50%;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.wheel-svg {
  width: 100%;
  height: 100%;
  border-radius: 50%;
}

.wheel-text {
  font-size: 14px;
  font-weight: 600;
  fill: #333;
  pointer-events: none;
}

.center-button {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 60px;
  height: 60px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  z-index: 5;
  transition: all 0.3s ease;
  font-weight: bold;
  color: var(--color-primary, #667eea);
  font-size: 18px;
}

.center-button:hover {
  transform: translate(-50%, -50%) scale(1.1);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.result-display {
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.result-text {
  font-size: 20px;
  font-weight: 500;
  color: var(--color-text, #333);
  text-align: center;
}

.result-text.spinning {
  animation: pulse 1s ease-in-out infinite;
}

.result-text.result {
  color: var(--color-primary, #667eea);
}

.result-text.result strong {
  font-size: 24px;
  color: var(--color-primary, #667eea);
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

.spin-button {
  padding: 12px 32px;
  background: var(--color-primary, #667eea);
  color: white;
  border: none;
  border-radius: 25px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.spin-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.spin-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 选项列表区域 */
.list-section {
  background: var(--color-surface-variant, rgba(255, 255, 255, 0.1));
  border-radius: 16px;
  padding: 20px;
  backdrop-filter: blur(10px);
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-height: 600px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.list-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
  color: var(--color-text, #333);
}

.item-count {
  font-size: 14px;
  color: var(--color-text-secondary, #666);
}

.add-item-form {
  display: flex;
  gap: 8px;
}

.item-input {
  flex: 1;
  padding: 10px 16px;
  border: 2px solid var(--color-border, rgba(0, 0, 0, 0.1));
  border-radius: 8px;
  font-size: 14px;
  background: var(--color-surface, white);
  color: var(--color-text, #333);
  transition: border-color 0.3s ease;
}

.item-input:focus {
  outline: none;
  border-color: var(--color-primary, #667eea);
}

.add-button {
  width: 44px;
  height: 44px;
  border: none;
  background: var(--color-primary, #667eea);
  color: white;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  transition: all 0.3s ease;
}

.add-button:hover:not(:disabled) {
  background: var(--color-primary-dark, #5568d3);
  transform: scale(1.05);
}

.add-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.items-list {
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 400px;
}

.item-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  background: var(--color-surface, white);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.item-row:hover {
  background: var(--color-surface-hover, rgba(0, 0, 0, 0.02));
}

.item-text {
  flex: 1;
  font-size: 14px;
  color: var(--color-text, #333);
}

.delete-button {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.delete-button:hover:not(:disabled) {
  background: rgba(255, 0, 0, 0.1);
  transform: scale(1.1);
}

.delete-button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: var(--color-text-secondary, #999);
  font-size: 14px;
}

/* 响应式 */
@media (max-width: 968px) {
  .wheel-container {
    grid-template-columns: 1fr;
  }

  .wheel-wrapper {
    width: 250px;
    height: 250px;
  }

  .wheel {
    width: 250px;
    height: 250px;
  }

  .pointer {
    border-left-width: 12px;
    border-right-width: 12px;
    border-top-width: 32px;
  }

  .center-button {
    width: 50px;
    height: 50px;
    font-size: 16px;
  }
}

/* 暗色主题适配 */
@media (prefers-color-scheme: dark) {
  .list-section {
    background: rgba(255, 255, 255, 0.05);
  }

  .item-input {
    background: rgba(255, 255, 255, 0.05);
  }

  .item-row {
    background: rgba(255, 255, 255, 0.05);
  }
}
</style>