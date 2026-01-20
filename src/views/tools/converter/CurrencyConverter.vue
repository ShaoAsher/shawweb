<template>
  <ToolLayout
    icon="💱"
    title="汇率转换工具"
    description="实时汇率查询与转换，支持全球主要货币，包含汇率换算工具和实时汇率列表，支持搜索功能"
  >
    <!-- 汇率换算工具 -->
    <div class="converter-section">
      <h2>
        <span>💱</span>
        <span>汇率换算</span>
      </h2>
      <div class="converter-form">
        <div class="input-group">
          <label class="input-label">金额</label>
          <div class="input-wrapper">
            <input
              v-model.number="amount"
              type="number"
              class="amount-input"
              placeholder="0"
              step="any"
              @input="performConversion"
            />
          </div>
        </div>
        <div class="input-group">
          <label class="input-label">从</label>
          <select v-model="fromCurrency" class="currency-select" @change="handleFromCurrencyChange">
            <option v-for="code in availableCurrencies" :key="code" :value="code">
              {{ getCurrencyDisplay(code) }}
            </option>
          </select>
        </div>
        <div class="arrow-icon">⇄</div>
        <div class="input-group">
          <label class="input-label">到</label>
          <select v-model="toCurrency" class="currency-select" @change="performConversion">
            <option v-for="code in availableCurrencies" :key="code" :value="code">
              {{ getCurrencyDisplay(code) }}
            </option>
          </select>
        </div>
      </div>
      <div v-if="conversionResult" class="result-display show">
        <div class="result-amount">{{ conversionResult.amount }} {{ toCurrency }}</div>
        <div class="result-info">1 {{ fromCurrency }} = {{ conversionResult.rate }} {{ toCurrency }}</div>
      </div>
    </div>

    <!-- 错误提示 -->
    <div v-if="errorMessage" class="error-message show">
      {{ errorMessage }}
    </div>

    <!-- 汇率列表 -->
    <div class="rates-section">
      <div class="rates-header">
        <div class="rates-title">
          <span>📊</span>
          <span>实时汇率列表</span>
        </div>
        <input
          v-model="searchQuery"
          type="text"
          class="search-box"
          placeholder="🔍 搜索货币..."
          @input="renderRatesList"
        />
        <div v-if="lastUpdateTime" class="update-time">
          更新时间: {{ formatTime(lastUpdateTime) }}
        </div>
      </div>
      <div class="rates-section-wrapper">
        <div class="rates-list">
          <div class="rates-list-header">
            <div>货币</div>
            <div>名称</div>
            <div style="text-align: right;">汇率</div>
          </div>
          <div v-if="loading" class="loading-message">正在加载汇率数据...</div>
          <div v-else-if="filteredRates.length === 0" class="no-results show">
            <div style="font-size: var(--font-size-large); margin-bottom: 8px;">未找到相关货币</div>
            <div>试试其他关键词吧</div>
          </div>
          <div v-else id="ratesGrid">
            <div
              v-for="(rate, code) in filteredRates"
              :key="code"
              class="rate-row"
              @click="selectCurrency(code)"
            >
              <div class="rate-flag">{{ getCurrencyFlag(code) }}</div>
              <div class="rate-info">
                <div class="rate-code-name">
                  <span class="rate-code">{{ code }}</span>
                  <span class="rate-name">{{ getCurrencyName(code) }}</span>
                </div>
              </div>
              <div class="rate-value">{{ rate.toFixed(4) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

const amount = ref(1)
const fromCurrency = ref('CNY')
const toCurrency = ref('USD')
const exchangeRates = ref({})
const availableCurrencies = ref([])
const baseCurrency = ref('CNY')
const lastUpdateTime = ref(null)
const searchQuery = ref('')
const errorMessage = ref('')
const loading = ref(false)
const conversionResult = ref(null)

// 货币代码到国家图标的映射（简化版，包含主要货币）
const currencyFlags = {
  'AED': '🇦🇪', 'AUD': '🇦🇺', 'BRL': '🇧🇷', 'CAD': '🇨🇦', 'CHF': '🇨🇭', 'CNY': '🇨🇳',
  'EUR': '🇪🇺', 'GBP': '🇬🇧', 'HKD': '🇭🇰', 'INR': '🇮🇳', 'JPY': '🇯🇵', 'KRW': '🇰🇷',
  'MXN': '🇲🇽', 'RUB': '🇷🇺', 'SGD': '🇸🇬', 'THB': '🇹🇭', 'USD': '🇺🇸', 'ZAR': '🇿🇦'
}

// 货币代码到货币名称的映射（简化版）
const currencyNames = {
  'AED': '阿联酋迪拉姆', 'AUD': '澳元', 'BRL': '巴西雷亚尔', 'CAD': '加元', 'CHF': '瑞士法郎',
  'CNY': '人民币', 'EUR': '欧元', 'GBP': '英镑', 'HKD': '港币', 'INR': '印度卢比',
  'JPY': '日元', 'KRW': '韩元', 'MXN': '墨西哥比索', 'RUB': '俄罗斯卢布', 'SGD': '新加坡元',
  'THB': '泰铢', 'USD': '美元', 'ZAR': '南非兰特'
}

function getCurrencyFlag(code) {
  return currencyFlags[code] || '💱'
}

function getCurrencyName(code) {
  return currencyNames[code] || code
}

function getCurrencyDisplay(code) {
  return `${getCurrencyFlag(code)} ${getCurrencyName(code)} (${code})`
}

async function fetchExchangeRates(base = 'CNY') {
  loading.value = true
  errorMessage.value = ''
  try {
    const response = await fetch(`https://api.exchangerate-api.com/v4/latest/${base}`)
    if (!response.ok) {
      throw new Error('获取汇率数据失败')
    }
    const data = await response.json()
    exchangeRates.value = data.rates
    baseCurrency.value = base
    
    availableCurrencies.value = [base, ...Object.keys(data.rates)].filter((v, i, a) => a.indexOf(v) === i)
    lastUpdateTime.value = new Date()
    
    // 确保目标货币在列表中
    if (!availableCurrencies.value.includes(toCurrency.value) || toCurrency.value === fromCurrency.value) {
      const firstAvailable = availableCurrencies.value.find(c => c !== fromCurrency.value)
      if (firstAvailable) {
        toCurrency.value = firstAvailable
      }
    }
    
    performConversion()
    renderRatesList()
    loading.value = false
    return true
  } catch (error) {
    console.error('获取汇率失败:', error)
    errorMessage.value = '无法获取实时汇率数据，请稍后重试'
    loading.value = false
    setTimeout(() => {
      errorMessage.value = ''
    }, 5000)
    return false
  }
}

function performConversion() {
  if (!amount.value || amount.value < 0) {
    conversionResult.value = null
    return
  }

  if (baseCurrency.value !== fromCurrency.value) {
    fetchExchangeRates(fromCurrency.value)
    return
  }

  const rate = exchangeRates.value[toCurrency.value]
  if (!rate) {
    if (toCurrency.value === fromCurrency.value) {
      conversionResult.value = {
        amount: amount.value.toFixed(2),
        rate: '1.0000'
      }
    } else {
      conversionResult.value = null
    }
    return
  }

  const result = (amount.value * rate).toFixed(2)
  conversionResult.value = {
    amount: result,
    rate: rate.toFixed(4)
  }
}

function handleFromCurrencyChange() {
  fetchExchangeRates(fromCurrency.value)
}

const filteredRates = computed(() => {
  const query = searchQuery.value.toLowerCase().trim()
  const filtered = {}
  
  Object.keys(exchangeRates.value).forEach(code => {
    if (code === baseCurrency.value) return
    
    const name = getCurrencyName(code).toLowerCase()
    const codeLower = code.toLowerCase()
    
    if (!query || name.includes(query) || codeLower.includes(query)) {
      filtered[code] = exchangeRates.value[code]
    }
  })
  
  return filtered
})

function renderRatesList() {
  // 列表通过 computed 自动更新
}

function selectCurrency(code) {
  toCurrency.value = code
  performConversion()
}

function formatTime(date) {
  return date.toLocaleString('zh-CN')
}

watch(amount, performConversion)
watch(toCurrency, performConversion)

onMounted(async () => {
  await fetchExchangeRates('CNY')
  
  // 定期更新汇率（每5分钟）
  setInterval(async () => {
    await fetchExchangeRates(fromCurrency.value)
  }, 5 * 60 * 1000)
})
</script>

<style scoped>
.converter-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-lg);
  padding: var(--spacing-xl);
  margin-bottom: var(--spacing-xl);
  border: 1px solid var(--color-border);
}

.converter-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.converter-form {
  display: flex;
  gap: 20px;
  align-items: flex-end;
  flex-wrap: wrap;
}

.input-group {
  flex: 1;
  min-width: 200px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.amount-input {
  flex: 1;
  padding: var(--spacing-sm) var(--spacing-lg);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: var(--font-size-large);
  font-weight: var(--font-weight-semibold);
  transition: all 0.3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.amount-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.currency-select {
  min-width: 150px;
  padding: var(--spacing-sm) var(--spacing-lg);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: var(--font-size-base);
  background: var(--color-surface);
  cursor: pointer;
  transition: all 0.3s;
  font-weight: 500;
  color: var(--color-text);
}

.currency-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.arrow-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: var(--color-primary);
  padding: 0 10px;
  flex-shrink: 0;
}

.result-display {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  padding: 20px 24px;
  border-radius: var(--radius-md);
  text-align: center;
  min-height: 80px;
  display: none;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin-top: 20px;
}

.result-display.show {
  display: flex;
}

.result-amount {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 8px;
}

.result-info {
  font-size: var(--font-size-small);
  opacity: 0.9;
}

.error-message {
  background: var(--color-surface-alt);
  color: var(--color-error);
  padding: 16px;
  border-radius: var(--radius-md);
  margin-bottom: 20px;
  border: 1px solid #fcc;
  display: none;
}

.error-message.show {
  display: block;
}

.rates-section {
  margin-top: 30px;
}

.rates-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
}

.rates-title {
  font-size: 22px;
  color: var(--color-text);
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 10px;
}

.search-box {
  flex: 1;
  min-width: 250px;
  max-width: 400px;
  padding: 12px 20px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: 15px;
  transition: all 0.3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.search-box:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.update-time {
  font-size: 13px;
  color: var(--color-text-secondary);
  text-align: right;
}

.rates-list {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  overflow: visible;
  position: relative;
}

.rates-list-header {
  display: grid;
  grid-template-columns: 60px 1fr 120px;
  gap: 16px;
  padding: 12px 16px;
  background: var(--color-surface-alt);
  border-bottom: 2px solid var(--color-border);
  font-size: var(--font-size-small);
  font-weight: 600;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.rate-row {
  display: grid;
  grid-template-columns: 60px 1fr 120px;
  gap: 16px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--color-border);
  transition: all 0.2s;
  cursor: pointer;
  align-items: center;
}

.rate-row:last-child {
  border-bottom: none;
}

.rate-row:hover {
  background: var(--color-surface-alt);
  border-left: 3px solid var(--color-primary);
}

.rate-flag {
  font-size: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.rate-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.rate-code-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.rate-code {
  font-size: var(--font-size-small);
  font-weight: 700;
  color: var(--color-text);
}

.rate-name {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.rate-value {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-primary);
  font-family: 'SF Mono', 'Monaco', 'Courier New', monospace;
  text-align: right;
}

.loading-message {
  padding: 40px;
  text-align: center;
  color: var(--color-text-secondary);
}

.no-results {
  text-align: center;
  padding: 60px 20px;
  color: var(--color-text-light);
  display: none;
}

.no-results.show {
  display: block;
}

@media (max-width: 768px) {
  .converter-form {
    flex-direction: column;
  }

  .arrow-icon {
    transform: rotate(90deg);
    padding: 10px 0;
  }

  .rates-list-header,
  .rate-row {
    grid-template-columns: 50px 1fr 100px;
    gap: 12px;
    padding: 10px 12px;
  }
}
</style>
