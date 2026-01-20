<template>
  <ToolLayout
    icon="⏰"
    title="时间戳转换工具"
    description="支持秒级和毫秒级时间戳与日期时间互转，自动识别时间戳类型。"
  >
    <div class="form-section">
      <h2>时间戳转日期</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="timestampInput">时间戳</label>
          <input
            v-model="timestampInput"
            type="text"
            id="timestampInput"
            placeholder="输入时间戳（秒或毫秒）"
          />
        </div>
        <div class="form-group">
          <label for="timestampType">时间戳类型</label>
          <select v-model="timestampType" id="timestampType">
            <option value="auto">自动识别</option>
            <option value="second">秒（10位）</option>
            <option value="millisecond">毫秒（13位）</option>
          </select>
        </div>
      </div>
      <AppButton variant="primary" icon="📅" @click="convertTimestamp">转换为日期</AppButton>
      <div class="result-grid" v-if="timestampResult.length > 0">
        <div class="result-card" v-for="(result, index) in timestampResult" :key="index">
          <div class="result-card-title">{{ result.label }}</div>
          <div class="result-card-value">{{ result.value }}</div>
        </div>
      </div>
    </div>

    <div class="form-section">
      <h2>日期转时间戳</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="dateInput">日期时间</label>
          <input
            v-model="dateInput"
            type="datetime-local"
            id="dateInput"
          />
        </div>
        <div class="form-group">
          <label for="outputType">输出类型</label>
          <select v-model="outputType" id="outputType">
            <option value="second">秒（10位）</option>
            <option value="millisecond">毫秒（13位）</option>
          </select>
        </div>
      </div>
      <ButtonGroup>
        <AppButton variant="primary" icon="⏱️" @click="convertDate">转换为时间戳</AppButton>
        <AppButton variant="secondary" icon="🕐" @click="getCurrentTimestamp">获取当前时间戳</AppButton>
      </ButtonGroup>
      <div class="result-grid" v-if="dateResult.length > 0">
        <div class="result-card" v-for="(result, index) in dateResult" :key="index">
          <div class="result-card-title">{{ result.label }}</div>
          <div class="result-card-value">{{ result.value }}</div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

const timestampInput = ref('')
const timestampType = ref('auto')
const dateInput = ref('')
const outputType = ref('millisecond')
const timestampResult = ref([])
const dateResult = ref([])

function convertTimestamp() {
  const input = timestampInput.value.trim()
  if (!input) {
    alert('请输入时间戳')
    return
  }

  let timestamp = parseInt(input)
  if (isNaN(timestamp)) {
    alert('时间戳格式错误')
    return
  }

  // 自动识别时间戳类型
  if (timestampType.value === 'auto') {
    const length = input.length
    if (length <= 10) {
      timestampType.value = 'second'
    } else {
      timestampType.value = 'millisecond'
    }
  }

  // 转换为毫秒
  if (timestampType.value === 'second') {
    timestamp = timestamp * 1000
  }

  const date = new Date(timestamp)
  if (isNaN(date.getTime())) {
    alert('时间戳无效')
    return
  }

  timestampResult.value = [
    {
      label: '本地时间',
      value: date.toLocaleString('zh-CN')
    },
    {
      label: 'UTC 时间',
      value: date.toUTCString()
    },
    {
      label: 'ISO 8601',
      value: date.toISOString()
    },
    {
      label: '时间戳（秒）',
      value: Math.floor(timestamp / 1000).toString()
    },
    {
      label: '时间戳（毫秒）',
      value: timestamp.toString()
    }
  ]
}

function convertDate() {
  if (!dateInput.value) {
    alert('请选择日期时间')
    return
  }

  const date = new Date(dateInput.value)
  if (isNaN(date.getTime())) {
    alert('日期格式错误')
    return
  }

  const timestamp = date.getTime()
  const timestampSecond = Math.floor(timestamp / 1000)

  dateResult.value = [
    {
      label: outputType.value === 'second' ? '时间戳（秒）' : '时间戳（毫秒）',
      value: outputType.value === 'second' ? timestampSecond.toString() : timestamp.toString()
    },
    {
      label: '本地时间',
      value: date.toLocaleString('zh-CN')
    },
    {
      label: 'UTC 时间',
      value: date.toUTCString()
    }
  ]
}

function getCurrentTimestamp() {
  const now = new Date()
  dateInput.value = now.toISOString().slice(0, 16)
  convertDate()
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
  margin-bottom: var(--spacing-lg);
  border-bottom: 2px solid var(--color-primary);
  padding-bottom: var(--spacing-sm);
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
}

.form-group {
  margin-bottom: 18px;
}

.form-group label {
  display: block;
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 8px;
  font-size: 14px;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 12px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: 14px;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: 14px 35px;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: 600;
  cursor: pointer;
  transition: transform .2s;
  width: 100%;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px var(--color-shadow-primary);
}

.btn-secondary {
  background: linear-gradient(135deg, var(--color-text-secondary) 0%, var(--color-text-light) 100%);
  margin-top: 10px;
}

.result-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 15px;
  margin-top: 20px;
}

.result-card {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 15px;
}

.result-card-title {
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 8px;
  font-size: 14px;
}

.result-card-value {
  font-family: 'Courier New', monospace;
  font-size: 13px;
  color: var(--color-text);
  word-break: break-all;
}
</style>
