<template>
  <ToolLayout
    icon="🔤"
    title="多种字符串生成器"
    description="生成标准银行卡号、UDID、包名、UUID、MAC地址、IP地址、邮箱等常用字符串"
  >
    <!-- 银行卡号生成器 -->
    <div class="generator-section">
      <h2>标准银行卡卡号生成器</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label>选择银行</label>
          <select v-model="cardBank">
            <option value="random">随机银行</option>
            <option value="6217">中国工商银行 (6217)</option>
            <option value="6228">中国工商银行 (6228)</option>
            <option value="6222">中国工商银行 (6222)</option>
            <option value="6212">中国农业银行 (6212)</option>
            <option value="6227">中国建设银行 (6227)</option>
            <option value="6225">中国建设银行 (6225)</option>
            <option value="6221">中国银行 (6221)</option>
            <option value="6225">交通银行 (6225)</option>
            <option value="6221">招商银行 (6221)</option>
            <option value="6225">招商银行 (6225)</option>
            <option value="6228">招商银行 (6228)</option>
            <option value="6221">浦发银行 (6221)</option>
            <option value="6225">浦发银行 (6225)</option>
            <option value="6221">民生银行 (6221)</option>
            <option value="6225">民生银行 (6225)</option>
            <option value="6221">中信银行 (6221)</option>
            <option value="6225">中信银行 (6225)</option>
            <option value="6221">光大银行 (6221)</option>
            <option value="6225">光大银行 (6225)</option>
            <option value="6221">华夏银行 (6221)</option>
            <option value="6225">华夏银行 (6225)</option>
            <option value="6221">平安银行 (6221)</option>
            <option value="6225">平安银行 (6225)</option>
          </select>
        </div>
        <div class="form-group">
          <label>生成数量</label>
          <input v-model.number="cardCount" type="number" min="1" max="100" placeholder="输入生成数量" />
        </div>
      </div>
      <div class="form-group">
        <label>自定义前缀（可选，如：6217, 6228，留空则使用选择的银行）</label>
        <input v-model="cardPrefix" type="text" placeholder="留空则使用选择的银行" maxlength="6" />
      </div>
      <ButtonGroup>
        <AppButton variant="primary" icon="💳" @click="generateCardNumbers">生成银行卡号</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clearResult('card')">清空</AppButton>
      </ButtonGroup>
      <div v-if="cardResults.length > 0" class="result-section">
        <h3>生成结果</h3>
        <div class="result-box">
          <div v-for="(result, index) in cardResults" :key="index" class="result-item">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span>{{ index + 1 }}. {{ formatCardNumber(result) }}</span>
              <button class="copy-btn" @click="copyToClipboard(result)">复制</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- UDID 生成器 -->
    <div class="generator-section">
      <h2>UDID 生成器</h2>
      <div class="form-group">
        <label>生成数量</label>
        <input v-model.number="udidCount" type="number" min="1" max="100" placeholder="输入生成数量" />
      </div>
      <ButtonGroup>
        <AppButton variant="primary" icon="📱" @click="generateUDIDs">生成 UDID</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clearResult('udid')">清空</AppButton>
      </ButtonGroup>
      <div v-if="udidResults.length > 0" class="result-section">
        <h3>生成结果</h3>
        <div class="result-box">
          <div v-for="(result, index) in udidResults" :key="index" class="result-item">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span>{{ index + 1 }}. {{ result }}</span>
              <button class="copy-btn" @click="copyToClipboard(result)">复制</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 包名生成器 -->
    <div class="generator-section">
      <h2>包名生成器</h2>
      <div class="form-group">
        <label>生成数量</label>
        <input v-model.number="packageCount" type="number" min="1" max="100" placeholder="输入生成数量" />
      </div>
      <div class="controls-grid">
        <div class="form-group">
          <label>包名层级（2-4，包含 com）</label>
          <input v-model.number="packageLevel" type="number" min="2" max="4" />
          <small style="color: var(--color-text-secondary); font-size: var(--font-size-small);">
            包名以 com. 开头，此数值为总层级数
          </small>
        </div>
        <div class="form-group">
          <label>每段长度（3-10）</label>
          <input v-model.number="packageLength" type="number" min="3" max="10" />
        </div>
      </div>
      <ButtonGroup>
        <AppButton variant="primary" icon="📦" @click="generatePackages">生成包名</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clearResult('package')">清空</AppButton>
      </ButtonGroup>
      <div v-if="packageResults.length > 0" class="result-section">
        <h3>生成结果</h3>
        <div class="result-box">
          <div v-for="(result, index) in packageResults" :key="index" class="result-item">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span>{{ index + 1 }}. {{ result }}</span>
              <button class="copy-btn" @click="copyToClipboard(result)">复制</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 其他生成器 -->
    <div class="generator-section">
      <h2>其他常用生成器</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label>生成器类型</label>
          <select v-model="otherType">
            <option value="uuid">UUID</option>
            <option value="randomString">随机字符串</option>
            <option value="randomNumber">随机数字</option>
            <option value="macAddress">MAC 地址</option>
            <option value="ipAddress">IP 地址</option>
            <option value="email">邮箱地址</option>
          </select>
        </div>
        <div class="form-group">
          <label>生成数量</label>
          <input v-model.number="otherCount" type="number" min="1" max="100" />
        </div>
      </div>
      <div v-if="otherType === 'randomString'" class="form-group">
        <label>字符串长度</label>
        <input v-model.number="randomStringLength" type="number" min="1" max="100" />
      </div>
      <div v-if="otherType === 'randomNumber'" class="form-group">
        <label>数字范围（格式：最小值-最大值，如：1000-9999）</label>
        <input v-model="randomNumberRange" type="text" placeholder="1000-9999" />
      </div>
      <ButtonGroup>
        <AppButton variant="primary" icon="✨" @click="generateOther">生成</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clearResult('other')">清空</AppButton>
      </ButtonGroup>
      <div v-if="otherResults.length > 0" class="result-section">
        <h3>生成结果</h3>
        <div class="result-box">
          <div v-for="(result, index) in otherResults" :key="index" class="result-item">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span>{{ index + 1 }}. {{ result }}</span>
              <button class="copy-btn" @click="copyToClipboard(result)">复制</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { ref } from 'vue'

const cardBank = ref('random')
const cardCount = ref(1)
const cardPrefix = ref('')
const cardResults = ref([])

const udidCount = ref(1)
const udidResults = ref([])

const packageCount = ref(1)
const packageLevel = ref(3)
const packageLength = ref(6)
const packageResults = ref([])

const otherType = ref('uuid')
const otherCount = ref(1)
const randomStringLength = ref(16)
const randomNumberRange = ref('1000-9999')
const otherResults = ref([])

const bankPrefixes = {
  '6217': ['6217'],
  '6228': ['6228'],
  '6222': ['6222'],
  '6212': ['6212'],
  '6227': ['6227'],
  '6225': ['6225'],
  '6221': ['6221'],
  'random': []
}

function luhnChecksum(cardNumber) {
  let sum = 0
  let isEven = false
  for (let i = cardNumber.length - 1; i >= 0; i--) {
    let digit = parseInt(cardNumber[i])
    if (isEven) {
      digit *= 2
      if (digit > 9) digit -= 9
    }
    sum += digit
    isEven = !isEven
  }
  return (10 - (sum % 10)) % 10
}

function generateCardNumbers() {
  const results = []
  for (let i = 0; i < cardCount.value; i++) {
    let prefix
    if (cardPrefix.value) {
      prefix = cardPrefix.value
    } else if (cardBank.value !== 'random' && bankPrefixes[cardBank.value]) {
      const prefixes = bankPrefixes[cardBank.value]
      prefix = prefixes[Math.floor(Math.random() * prefixes.length)]
    } else {
      const commonPrefixes = ['6217', '6228', '6222', '6212', '6227', '6225', '6221', '6210', '6211', '6213']
      prefix = commonPrefixes[Math.floor(Math.random() * commonPrefixes.length)]
    }

    let cardNumber = prefix
    while (cardNumber.length < 15) {
      cardNumber += Math.floor(Math.random() * 10).toString()
    }
    cardNumber = cardNumber.substring(0, 15)

    const checksum = luhnChecksum(cardNumber)
    cardNumber += checksum
    results.push(cardNumber)
  }
  cardResults.value = results
}

function generateUDIDs() {
  const results = []
  const chars = '0123456789ABCDEF'
  for (let i = 0; i < udidCount.value; i++) {
    let udid = ''
    for (let j = 0; j < 32; j++) {
      udid += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    results.push(udid.toUpperCase())
  }
  udidResults.value = results
}

function generatePackages() {
  const results = []
  const chars = 'abcdefghijklmnopqrstuvwxyz'
  for (let i = 0; i < packageCount.value; i++) {
    let packageName = 'com'
    for (let j = 0; j < packageLevel.value - 1; j++) {
      packageName += '.'
      let segment = ''
      segment += chars.charAt(Math.floor(Math.random() * chars.length))
      for (let k = 1; k < packageLength.value; k++) {
        const charSet = chars + '0123456789'
        segment += charSet.charAt(Math.floor(Math.random() * charSet.length))
      }
      packageName += segment
    }
    results.push(packageName)
  }
  packageResults.value = results
}

function generateOther() {
  const results = []
  for (let i = 0; i < otherCount.value; i++) {
    switch (otherType.value) {
      case 'uuid':
        results.push(generateUUID())
        break
      case 'randomString':
        results.push(generateRandomString(randomStringLength.value))
        break
      case 'randomNumber':
        const range = randomNumberRange.value || '1000-9999'
        const [min, max] = range.split('-').map(n => parseInt(n.trim()))
        if (min && max) {
          results.push(Math.floor(Math.random() * (max - min + 1)) + min)
        } else {
          results.push(Math.floor(Math.random() * 10000))
        }
        break
      case 'macAddress':
        results.push(generateMACAddress())
        break
      case 'ipAddress':
        results.push(generateIPAddress())
        break
      case 'email':
        results.push(generateEmail())
        break
    }
  }
  otherResults.value = results
}

function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = Math.random() * 16 | 0
    const v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16).toUpperCase()
  })
}

function generateRandomString(length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  let result = ''
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

function generateMACAddress() {
  const hex = '0123456789ABCDEF'
  let mac = ''
  for (let i = 0; i < 6; i++) {
    if (i > 0) mac += ':'
    mac += hex.charAt(Math.floor(Math.random() * hex.length))
    mac += hex.charAt(Math.floor(Math.random() * hex.length))
  }
  return mac
}

function generateIPAddress() {
  return `${Math.floor(Math.random() * 255)}.${Math.floor(Math.random() * 255)}.${Math.floor(Math.random() * 255)}.${Math.floor(Math.random() * 255)}`
}

function generateEmail() {
  const domains = ['gmail.com', 'yahoo.com', 'outlook.com', '163.com', 'qq.com', 'example.com']
  const username = generateRandomString(8).toLowerCase()
  const domain = domains[Math.floor(Math.random() * domains.length)]
  return `${username}@${domain}`
}

function formatCardNumber(cardNumber) {
  return cardNumber.replace(/(\d{4})(?=\d)/g, '$1 ')
}

function clearResult(type) {
  switch (type) {
    case 'card':
      cardResults.value = []
      break
    case 'udid':
      udidResults.value = []
      break
    case 'package':
      packageResults.value = []
      break
    case 'other':
      otherResults.value = []
      break
  }
}

function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
    alert('已复制到剪贴板！')
  }).catch(() => {
    const textarea = document.createElement('textarea')
    textarea.value = text
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    alert('已复制到剪贴板！')
  })
}
</script>

<style scoped>
.generator-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.generator-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
  border-bottom: 2px solid var(--color-primary);
  padding-bottom: var(--spacing-sm);
}

.form-group {
  margin-bottom: var(--spacing-lg);
}

.form-group label {
  display: block;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
  font-size: var(--font-size-small);
}

.form-group input,
.form-group select {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  transition: border-color .3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: var(--spacing-sm) var(--spacing-lg);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: transform .2s;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn-group {
  display: flex;
  gap: var(--spacing-sm);
  margin-top: var(--spacing-md);
}

.result-section {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-top: var(--spacing-lg);
}

.result-section h3 {
  font-size: var(--font-size-base);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
}

.result-box {
  background: var(--color-background-alt);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: var(--spacing-md);
  min-height: 60px;
  word-break: break-all;
  font-family: 'Courier New', monospace;
  font-size: var(--font-size-small);
  color: var(--color-text);
  position: relative;
}

.result-item {
  padding: 8px 0;
  border-bottom: 1px solid var(--color-border);
}

.result-item:last-child {
  border-bottom: none;
}

.copy-btn {
  position: relative;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: #fff !important;
  border: none;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: var(--font-size-small);
  cursor: pointer;
  transition: all 0.3s;
  overflow: hidden;
  box-shadow: 0 2px 8px var(--color-shadow-primary);
}

/* 入场光效 */
.copy-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.4) 50%,
    transparent 100%
  );
  transform: skewX(-25deg);
  pointer-events: none;
  animation: btn-shine 0.8s ease-out 0.2s forwards;
}

@keyframes btn-shine {
  0% { left: -100%; }
  100% { left: 100%; }
}

.copy-btn:hover {
  background: linear-gradient(135deg, var(--color-primary-dark) 0%, var(--color-primary) 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--color-shadow-primary);
}
</style>
