<template>
  <ToolLayout
    icon="⏱️"
    title="专注时钟"
    description="番茄工作法计时器，支持专注、短休息、长休息三种模式，帮助提高工作效率"
  >
    <div class="pomodoro-timer">
      <!-- 模式选择器 -->
      <div class="mode-selector">
        <button
          v-for="mode in modes"
          :key="mode.key"
          :class="['mode-btn', { active: currentMode === mode.key }]"
          @click="setMode(mode.key)"
        >
          {{ mode.label }}
        </button>
      </div>

      <!-- 计时器显示 -->
      <div class="timer-display">
        <div class="timer-circle">
          <svg class="progress-ring" width="280" height="280">
            <circle
              class="progress-ring-circle-bg"
              stroke="currentColor"
              fill="transparent"
              :stroke-width="12"
              :r="128"
              cx="140"
              cy="140"
            />
            <circle
              class="progress-ring-circle"
              stroke="currentColor"
              fill="transparent"
              :stroke-width="12"
              :r="128"
              cx="140"
              cy="140"
              :stroke-dasharray="circumference"
              :stroke-dashoffset="progressOffset"
              stroke-linecap="round"
            />
          </svg>
          <div class="timer-content">
            <div class="time-display" :class="{ running: isRunning }">
              {{ timeString }}
            </div>
            <div class="timer-status">
              {{ isRunning ? '进行中...' : '已暂停' }}
            </div>
          </div>
        </div>
      </div>

      <!-- 控制按钮 -->
      <div class="timer-controls">
        <button class="control-btn reset-btn" @click="resetTimer" title="重置">
          <span>🔄</span>
        </button>
        <button
          class="control-btn play-pause-btn"
          :class="{ running: isRunning }"
          @click="toggleTimer"
          :title="isRunning ? '暂停' : '开始'"
        >
          <span>{{ isRunning ? '⏸️' : '▶️' }}</span>
        </button>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

// 模式配置
const modes = [
  { key: 'work', label: '专注', duration: 25 * 60 }, // 25分钟
  { key: 'short_break', label: '短休息', duration: 5 * 60 }, // 5分钟
  { key: 'long_break', label: '长休息', duration: 15 * 60 } // 15分钟
]

// 状态
const currentMode = ref('work')
const timeLeft = ref(25 * 60) // 秒
const totalTime = ref(25 * 60)
const isRunning = ref(false)

// 定时器
let timer = null

// 计算属性
const timeString = computed(() => {
  const minutes = Math.floor(timeLeft.value / 60)
    .toString()
    .padStart(2, '0')
  const seconds = (timeLeft.value % 60).toString().padStart(2, '0')
  return `${minutes}:${seconds}`
})

const progress = computed(() => {
  return totalTime.value > 0 ? timeLeft.value / totalTime.value : 0
})

const circumference = computed(() => {
  return 2 * Math.PI * 128 // 半径128
})

const progressOffset = computed(() => {
  return circumference.value * (1 - progress.value)
})

// 方法
const setMode = (mode) => {
  if (isRunning.value) {
    pauseTimer()
  }
  currentMode.value = mode
  const modeConfig = modes.find((m) => m.key === mode)
  if (modeConfig) {
    timeLeft.value = modeConfig.duration
    totalTime.value = modeConfig.duration
  }
}

const toggleTimer = () => {
  if (isRunning.value) {
    pauseTimer()
  } else {
    startTimer()
  }
}

const startTimer = () => {
  if (timer) return
  isRunning.value = true
  timer = setInterval(() => {
    if (timeLeft.value > 0) {
      timeLeft.value--
    } else {
      pauseTimer()
      playNotificationSound()
      // 可以在这里添加通知或自动切换到下一个模式
    }
  }, 1000)
}

const pauseTimer = () => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
  isRunning.value = false
}

const resetTimer = () => {
  pauseTimer()
  const modeConfig = modes.find((m) => m.key === currentMode.value)
  if (modeConfig) {
    timeLeft.value = modeConfig.duration
    totalTime.value = modeConfig.duration
  }
}

const playNotificationSound = () => {
  // 使用 Web Audio API 播放提示音
  try {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()

    oscillator.connect(gainNode)
    gainNode.connect(audioContext.destination)

    oscillator.frequency.value = 800
    oscillator.type = 'sine'

    gainNode.gain.setValueAtTime(0.3, audioContext.currentTime)
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5)

    oscillator.start(audioContext.currentTime)
    oscillator.stop(audioContext.currentTime + 0.5)
  } catch (e) {
    // 如果浏览器不支持，静默失败
    console.log('Audio not supported')
  }
}

// 生命周期
onMounted(() => {
  // 初始化
})

onUnmounted(() => {
  pauseTimer()
})
</script>

<style scoped>
.pomodoro-timer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
  padding: 40px 20px;
  min-height: 600px;
}

/* 模式选择器 */
.mode-selector {
  display: flex;
  gap: 8px;
  padding: 4px;
  background: var(--color-surface-variant, rgba(255, 255, 255, 0.1));
  border-radius: 30px;
  backdrop-filter: blur(10px);
}

.mode-btn {
  padding: 10px 20px;
  border: none;
  background: transparent;
  color: var(--color-text, #333);
  border-radius: 25px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.mode-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.mode-btn.active {
  background: var(--color-primary, #667eea);
  color: white;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 计时器显示 */
.timer-display {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.timer-circle {
  position: relative;
  width: 280px;
  height: 280px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.progress-ring {
  position: absolute;
  top: 0;
  left: 0;
  transform: rotate(-90deg);
  color: var(--color-primary, #667eea);
}

.progress-ring-circle-bg {
  color: var(--color-primary, #667eea);
  opacity: 0.1;
}

.progress-ring-circle {
  transition: stroke-dashoffset 0.5s linear;
  color: var(--color-primary, #667eea);
}

.timer-content {
  position: relative;
  z-index: 1;
  text-align: center;
}

.time-display {
  font-size: 64px;
  font-weight: bold;
  font-variant-numeric: tabular-nums;
  color: var(--color-text, #333);
  line-height: 1;
  margin-bottom: 8px;
  transition: transform 0.3s ease;
}

.time-display.running {
  animation: pulse 1s ease-in-out infinite;
}

@keyframes pulse {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.timer-status {
  font-size: 16px;
  color: var(--color-text-secondary, #666);
}

/* 控制按钮 */
.timer-controls {
  display: flex;
  align-items: center;
  gap: 32px;
}

.control-btn {
  width: 56px;
  height: 56px;
  border: none;
  border-radius: 50%;
  background: var(--color-surface-variant, rgba(255, 255, 255, 0.1));
  color: var(--color-text, #333);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
  border: 2px solid rgba(0, 0, 0, 0.1);
}

.control-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.play-pause-btn {
  width: 80px;
  height: 80px;
  font-size: 40px;
  background: var(--color-primary, #667eea);
  color: white;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
  border: none;
}

.play-pause-btn:hover {
  box-shadow: 0 6px 30px rgba(102, 126, 234, 0.4);
}

.play-pause-btn.running {
  background: var(--color-primary-dark, #5568d3);
}

.reset-btn:hover {
  background: var(--color-secondary, #f093fb);
  color: white;
}

/* 响应式 */
@media (max-width: 768px) {
  .pomodoro-timer {
    gap: 32px;
    padding: 32px 16px;
  }

  .timer-circle {
    width: 240px;
    height: 240px;
  }

  .progress-ring {
    width: 240px;
    height: 240px;
  }

  .progress-ring circle {
    r: 108;
    cx: 120;
    cy: 120;
  }

  .time-display {
    font-size: 48px;
  }

  .control-btn {
    width: 48px;
    height: 48px;
    font-size: 24px;
  }

  .play-pause-btn {
    width: 64px;
    height: 64px;
    font-size: 32px;
  }
}

/* 暗色主题适配 */
@media (prefers-color-scheme: dark) {
  .mode-selector {
    background: rgba(255, 255, 255, 0.05);
  }

  .control-btn {
    background: rgba(255, 255, 255, 0.05);
    border-color: rgba(255, 255, 255, 0.1);
  }
}
</style>