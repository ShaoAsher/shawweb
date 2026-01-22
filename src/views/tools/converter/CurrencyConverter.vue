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
          <div class="currency-select-wrapper" :class="{ open: showFromDropdown }" ref="fromCurrencyWrapper">
            <input
              v-model="fromCurrencyDisplay"
              type="text"
              class="currency-select-input"
              readonly
              @click="toggleFromDropdown"
              @keydown="handleFromKeydown"
            />
            <span class="currency-select-arrow">▼</span>
            <div v-if="showFromDropdown" class="currency-dropdown">
              <input
                v-model="fromSearchQuery"
                type="text"
                class="currency-search-input"
                placeholder="🔍 搜索货币..."
                ref="fromSearchInput"
                @input="filterFromCurrencies"
                @keydown="handleFromSearchKeydown"
              />
              <div class="currency-options">
                <div
                  v-for="(currency, index) in filteredFromCurrencies"
                  :key="currency.code"
                  class="currency-option"
                  :class="{ selected: currency.code === fromCurrency, highlight: index === fromHighlightedIndex }"
                  @click="selectFromCurrency(currency.code)"
                >
                  <span class="currency-option-flag">{{ currency.flag }}</span>
                  <div class="currency-option-info">
                    <div class="currency-option-code">{{ currency.code }}</div>
                    <div class="currency-option-name">{{ currency.name }}</div>
                  </div>
                </div>
                <div v-if="filteredFromCurrencies.length === 0" class="currency-no-results">
                  未找到匹配的货币
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="arrow-icon">⇄</div>
        <div class="input-group">
          <label class="input-label">到</label>
          <div class="currency-select-wrapper" :class="{ open: showToDropdown }" ref="toCurrencyWrapper">
            <input
              v-model="toCurrencyDisplay"
              type="text"
              class="currency-select-input"
              readonly
              @click="toggleToDropdown"
              @keydown="handleToKeydown"
            />
            <span class="currency-select-arrow">▼</span>
            <div v-if="showToDropdown" class="currency-dropdown">
              <input
                v-model="toSearchQuery"
                type="text"
                class="currency-search-input"
                placeholder="🔍 搜索货币..."
                ref="toSearchInput"
                @input="filterToCurrencies"
                @keydown="handleToSearchKeydown"
              />
              <div class="currency-options">
                <div
                  v-for="(currency, index) in filteredToCurrencies"
                  :key="currency.code"
                  class="currency-option"
                  :class="{ selected: currency.code === toCurrency, highlight: index === toHighlightedIndex }"
                  @click="selectToCurrency(currency.code)"
                >
                  <span class="currency-option-flag">{{ currency.flag }}</span>
                  <div class="currency-option-info">
                    <div class="currency-option-code">{{ currency.code }}</div>
                    <div class="currency-option-name">{{ currency.name }}</div>
                  </div>
                </div>
                <div v-if="filteredToCurrencies.length === 0" class="currency-no-results">
                  未找到匹配的货币
                </div>
              </div>
            </div>
          </div>
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
import { ref, computed, onMounted, watch, nextTick } from 'vue'
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

// 货币选择器状态
const showFromDropdown = ref(false)
const showToDropdown = ref(false)
const fromSearchQuery = ref('')
const toSearchQuery = ref('')
const fromHighlightedIndex = ref(-1)
const toHighlightedIndex = ref(-1)
const fromCurrencyDisplay = ref('')
const toCurrencyDisplay = ref('')
const fromCurrencyWrapper = ref(null)
const toCurrencyWrapper = ref(null)
const fromSearchInput = ref(null)
const toSearchInput = ref(null)

// 货币代码到国家图标的映射（完整版）
const currencyFlags = {
  'AED': '🇦🇪', 'AFN': '🇦🇫', 'ALL': '🇦🇱', 'AMD': '🇦🇲', 'ANG': '🇨🇼', 'AOA': '🇦🇴', 'ARS': '🇦🇷', 'AUD': '🇦🇺',
  'AWG': '🇦🇼', 'AZN': '🇦🇿', 'BAM': '🇧🇦', 'BBD': '🇧🇧', 'BDT': '🇧🇩', 'BGN': '🇧🇬', 'BHD': '🇧🇭', 'BIF': '🇧🇮',
  'BMD': '🇧🇲', 'BND': '🇧🇳', 'BOB': '🇧🇴', 'BRL': '🇧🇷', 'BSD': '🇧🇸', 'BTN': '🇧🇹', 'BWP': '🇧🇼', 'BYN': '🇧🇾',
  'BZD': '🇧🇿', 'CAD': '🇨🇦', 'CDF': '🇨🇩', 'CHF': '🇨🇭', 'CLP': '🇨🇱', 'CNY': '🇨🇳', 'COP': '🇨🇴', 'CRC': '🇨🇷',
  'CUP': '🇨🇺', 'CVE': '🇨🇻', 'CZK': '🇨🇿', 'DJF': '🇩🇯', 'DKK': '🇩🇰', 'DOP': '🇩🇴', 'DZD': '🇩🇿', 'EGP': '🇪🇬',
  'ERN': '🇪🇷', 'ETB': '🇪🇹', 'EUR': '🇪🇺', 'FJD': '🇫🇯', 'FKP': '🇫🇰', 'GBP': '🇬🇧', 'GEL': '🇬🇪', 'GHS': '🇬🇭',
  'GIP': '🇬🇮', 'GMD': '🇬🇲', 'GNF': '🇬🇳', 'GTQ': '🇬🇹', 'GYD': '🇬🇾', 'HKD': '🇭🇰', 'HNL': '🇭🇳', 'HRK': '🇭🇷',
  'HTG': '🇭🇹', 'HUF': '🇭🇺', 'IDR': '🇮🇩', 'ILS': '🇮🇱', 'INR': '🇮🇳', 'IQD': '🇮🇶', 'IRR': '🇮🇷', 'ISK': '🇮🇸',
  'JMD': '🇯🇲', 'JOD': '🇯🇴', 'JPY': '🇯🇵', 'KES': '🇰🇪', 'KGS': '🇰🇬', 'KHR': '🇰🇭', 'KMF': '🇰🇲', 'KPW': '🇰🇵',
  'KRW': '🇰🇷', 'KWD': '🇰🇼', 'KYD': '🇰🇾', 'KZT': '🇰🇿', 'LAK': '🇱🇦', 'LBP': '🇱🇧', 'LKR': '🇱🇰', 'LRD': '🇱🇷',
  'LSL': '🇱🇸', 'LYD': '🇱🇾', 'MAD': '🇲🇦', 'MDL': '🇲🇩', 'MGA': '🇲🇬', 'MKD': '🇲🇰', 'MMK': '🇲🇲', 'MNT': '🇲🇳',
  'MOP': '🇲🇴', 'MRU': '🇲🇷', 'MUR': '🇲🇺', 'MVR': '🇲🇻', 'MWK': '🇲🇼', 'MXN': '🇲🇽', 'MYR': '🇲🇾', 'MZN': '🇲🇿',
  'NAD': '🇳🇦', 'NGN': '🇳🇬', 'NIO': '🇳🇮', 'NOK': '🇳🇴', 'NPR': '🇳🇵', 'NZD': '🇳🇿', 'OMR': '🇴🇲', 'PAB': '🇵🇦',
  'PEN': '🇵🇪', 'PGK': '🇵🇬', 'PHP': '🇵🇭', 'PKR': '🇵🇰', 'PLN': '🇵🇱', 'PYG': '🇵🇾', 'QAR': '🇶🇦', 'RON': '🇷🇴',
  'RSD': '🇷🇸', 'RUB': '🇷🇺', 'RWF': '🇷🇼', 'SAR': '🇸🇦', 'SBD': '🇸🇧', 'SCR': '🇸🇨', 'SDG': '🇸🇩', 'SEK': '🇸🇪',
  'SGD': '🇸🇬', 'SHP': '🇸🇭', 'SLE': '🇸🇱', 'SLL': '🇸🇱', 'SOS': '🇸🇴', 'SRD': '🇸🇷', 'STN': '🇸🇹', 'SYP': '🇸🇾',
  'SZL': '🇸🇿', 'THB': '🇹🇭', 'TJS': '🇹🇯', 'TMT': '🇹🇲', 'TND': '🇹🇳', 'TOP': '🇹🇴', 'TRY': '🇹🇷', 'TTD': '🇹🇹',
  'TWD': '🇹🇼', 'TZS': '🇹🇿', 'UAH': '🇺🇦', 'UGX': '🇺🇬', 'USD': '🇺🇸', 'UYU': '🇺🇾', 'UZS': '🇺🇿', 'VES': '🇻🇪',
  'VND': '🇻🇳', 'VUV': '🇻🇺', 'WST': '🇼🇸', 'XAF': '🇨🇲', 'XCD': '🇦🇬', 'XOF': '🇸🇳', 'XPF': '🇵🇫', 'YER': '🇾🇪',
  'ZAR': '🇿🇦', 'ZMW': '🇿🇲', 'ZWL': '🇿🇼'
}

// 货币代码到货币名称的映射（完整版）
const currencyNames = {
  'AED': '阿联酋迪拉姆', 'AFN': '阿富汗尼', 'ALL': '阿尔巴尼亚列克', 'AMD': '亚美尼亚德拉姆', 'ANG': '荷属安的列斯盾', 'AOA': '安哥拉宽扎', 'ARS': '阿根廷比索', 'AUD': '澳元',
  'AWG': '阿鲁巴弗罗林', 'AZN': '阿塞拜疆马纳特', 'BAM': '波黑可兑换马克', 'BBD': '巴巴多斯元', 'BDT': '孟加拉塔卡', 'BGN': '保加利亚列弗', 'BHD': '巴林第纳尔', 'BIF': '布隆迪法郎',
  'BMD': '百慕大元', 'BND': '文莱元', 'BOB': '玻利维亚诺', 'BRL': '巴西雷亚尔', 'BSD': '巴哈马元', 'BTN': '不丹努尔特鲁姆', 'BWP': '博茨瓦纳普拉', 'BYN': '白俄罗斯卢布',
  'BZD': '伯利兹元', 'CAD': '加元', 'CDF': '刚果法郎', 'CHF': '瑞士法郎', 'CLP': '智利比索', 'CNY': '人民币', 'COP': '哥伦比亚比索', 'CRC': '哥斯达黎加科朗',
  'CUP': '古巴比索', 'CVE': '佛得角埃斯库多', 'CZK': '捷克克朗', 'DJF': '吉布提法郎', 'DKK': '丹麦克朗', 'DOP': '多米尼加比索', 'DZD': '阿尔及利亚第纳尔', 'EGP': '埃及镑',
  'ERN': '厄立特里亚纳克法', 'ETB': '埃塞俄比亚比尔', 'EUR': '欧元', 'FJD': '斐济元', 'FKP': '福克兰群岛镑', 'GBP': '英镑', 'GEL': '格鲁吉亚拉里', 'GHS': '加纳塞地',
  'GIP': '直布罗陀镑', 'GMD': '冈比亚达拉西', 'GNF': '几内亚法郎', 'GTQ': '危地马拉格查尔', 'GYD': '圭亚那元', 'HKD': '港币', 'HNL': '洪都拉斯伦皮拉', 'HRK': '克罗地亚库纳',
  'HTG': '海地古德', 'HUF': '匈牙利福林', 'IDR': '印尼盾', 'ILS': '以色列新谢克尔', 'INR': '印度卢比', 'IQD': '伊拉克第纳尔', 'IRR': '伊朗里亚尔', 'ISK': '冰岛克朗',
  'JMD': '牙买加元', 'JOD': '约旦第纳尔', 'JPY': '日元', 'KES': '肯尼亚先令', 'KGS': '吉尔吉斯斯坦索姆', 'KHR': '柬埔寨瑞尔', 'KMF': '科摩罗法郎', 'KPW': '朝鲜元',
  'KRW': '韩元', 'KWD': '科威特第纳尔', 'KYD': '开曼群岛元', 'KZT': '哈萨克斯坦坚戈', 'LAK': '老挝基普', 'LBP': '黎巴嫩镑', 'LKR': '斯里兰卡卢比', 'LRD': '利比里亚元',
  'LSL': '莱索托洛蒂', 'LYD': '利比亚第纳尔', 'MAD': '摩洛哥迪拉姆', 'MDL': '摩尔多瓦列伊', 'MGA': '马达加斯加阿里亚里', 'MKD': '马其顿第纳尔', 'MMK': '缅甸元', 'MNT': '蒙古图格里克',
  'MOP': '澳门元', 'MRU': '毛里塔尼亚乌吉亚', 'MUR': '毛里求斯卢比', 'MVR': '马尔代夫拉菲亚', 'MWK': '马拉维克瓦查', 'MXN': '墨西哥比索', 'MYR': '马来西亚林吉特', 'MZN': '莫桑比克梅蒂卡尔',
  'NAD': '纳米比亚元', 'NGN': '尼日利亚奈拉', 'NIO': '尼加拉瓜科多巴', 'NOK': '挪威克朗', 'NPR': '尼泊尔卢比', 'NZD': '新西兰元', 'OMR': '阿曼里亚尔', 'PAB': '巴拿马巴波亚',
  'PEN': '秘鲁索尔', 'PGK': '巴布亚新几内亚基那', 'PHP': '菲律宾比索', 'PKR': '巴基斯坦卢比', 'PLN': '波兰兹罗提', 'PYG': '巴拉圭瓜拉尼', 'QAR': '卡塔尔里亚尔', 'RON': '罗马尼亚列伊',
  'RSD': '塞尔维亚第纳尔', 'RUB': '俄罗斯卢布', 'RWF': '卢旺达法郎', 'SAR': '沙特里亚尔', 'SBD': '所罗门群岛元', 'SCR': '塞舌尔卢比', 'SDG': '苏丹镑', 'SEK': '瑞典克朗',
  'SGD': '新加坡元', 'SHP': '圣赫勒拿镑', 'SLE': '塞拉利昂利昂', 'SLL': '塞拉利昂利昂', 'SOS': '索马里先令', 'SRD': '苏里南元', 'STN': '圣多美和普林西比多布拉', 'SYP': '叙利亚镑',
  'SZL': '斯威士兰里兰吉尼', 'THB': '泰铢', 'TJS': '塔吉克斯坦索莫尼', 'TMT': '土库曼斯坦马纳特', 'TND': '突尼斯第纳尔', 'TOP': '汤加潘加', 'TRY': '土耳其里拉', 'TTD': '特立尼达和多巴哥元',
  'TWD': '新台币', 'TZS': '坦桑尼亚先令', 'UAH': '乌克兰格里夫纳', 'UGX': '乌干达先令', 'USD': '美元', 'UYU': '乌拉圭比索', 'UZS': '乌兹别克斯坦索姆', 'VES': '委内瑞拉玻利瓦尔',
  'VND': '越南盾', 'VUV': '瓦努阿图瓦图', 'WST': '萨摩亚塔拉', 'XAF': '中非法郎', 'XCD': '东加勒比元', 'XOF': '西非法郎', 'XPF': '太平洋法郎', 'YER': '也门里亚尔',
  'ZAR': '南非兰特', 'ZMW': '赞比亚克瓦查', 'ZWL': '津巴布韦元'
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

// 更新货币显示
function updateCurrencyDisplay() {
  fromCurrencyDisplay.value = getCurrencyDisplay(fromCurrency.value)
  toCurrencyDisplay.value = getCurrencyDisplay(toCurrency.value)
}

// 过滤货币列表
const filteredFromCurrencies = computed(() => {
  const query = fromSearchQuery.value.toLowerCase().trim()
  return availableCurrencies.value
    .map(code => ({
      code,
      flag: getCurrencyFlag(code),
      name: getCurrencyName(code)
    }))
    .filter(currency => {
      if (!query) return true
      return currency.code.toLowerCase().includes(query) ||
        currency.name.toLowerCase().includes(query)
    })
    .sort((a, b) => a.code.localeCompare(b.code))
})

const filteredToCurrencies = computed(() => {
  const query = toSearchQuery.value.toLowerCase().trim()
  return availableCurrencies.value
    .map(code => ({
      code,
      flag: getCurrencyFlag(code),
      name: getCurrencyName(code)
    }))
    .filter(currency => {
      if (!query) return true
      return currency.code.toLowerCase().includes(query) ||
        currency.name.toLowerCase().includes(query)
    })
    .sort((a, b) => a.code.localeCompare(b.code))
})

// 切换下拉框
function toggleFromDropdown() {
  showFromDropdown.value = !showFromDropdown.value
  if (showFromDropdown.value) {
    fromSearchQuery.value = ''
    fromHighlightedIndex.value = -1
    nextTick(() => {
      fromSearchInput.value?.focus()
    })
  }
}

function toggleToDropdown() {
  showToDropdown.value = !showToDropdown.value
  if (showToDropdown.value) {
    toSearchQuery.value = ''
    toHighlightedIndex.value = -1
    nextTick(() => {
      toSearchInput.value?.focus()
    })
  }
}

// 选择货币
function selectFromCurrency(code) {
  fromCurrency.value = code
  updateCurrencyDisplay()
  showFromDropdown.value = false
  fromSearchQuery.value = ''
  fromHighlightedIndex.value = -1
  handleFromCurrencyChange()
}

function selectToCurrency(code) {
  toCurrency.value = code
  updateCurrencyDisplay()
  showToDropdown.value = false
  toSearchQuery.value = ''
  toHighlightedIndex.value = -1
  performConversion()
}

// 过滤函数（用于响应式更新）
function filterFromCurrencies() {
  fromHighlightedIndex.value = -1
}

function filterToCurrencies() {
  toHighlightedIndex.value = -1
}

// 键盘导航
function handleFromKeydown(e) {
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault()
    toggleFromDropdown()
  } else if (e.key === 'Escape') {
    showFromDropdown.value = false
  }
}

function handleToKeydown(e) {
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault()
    toggleToDropdown()
  } else if (e.key === 'Escape') {
    showToDropdown.value = false
  }
}

function handleFromSearchKeydown(e) {
  const options = filteredFromCurrencies.value
  if (options.length === 0) return

  if (e.key === 'ArrowDown') {
    e.preventDefault()
    fromHighlightedIndex.value = (fromHighlightedIndex.value + 1) % options.length
    scrollToHighlighted('from')
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    fromHighlightedIndex.value = fromHighlightedIndex.value <= 0 ? options.length - 1 : fromHighlightedIndex.value - 1
    scrollToHighlighted('from')
  } else if (e.key === 'Enter') {
    e.preventDefault()
    if (fromHighlightedIndex.value >= 0 && options[fromHighlightedIndex.value]) {
      selectFromCurrency(options[fromHighlightedIndex.value].code)
    }
  } else if (e.key === 'Escape') {
    showFromDropdown.value = false
  }
}

function handleToSearchKeydown(e) {
  const options = filteredToCurrencies.value
  if (options.length === 0) return

  if (e.key === 'ArrowDown') {
    e.preventDefault()
    toHighlightedIndex.value = (toHighlightedIndex.value + 1) % options.length
    scrollToHighlighted('to')
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    toHighlightedIndex.value = toHighlightedIndex.value <= 0 ? options.length - 1 : toHighlightedIndex.value - 1
    scrollToHighlighted('to')
  } else if (e.key === 'Enter') {
    e.preventDefault()
    if (toHighlightedIndex.value >= 0 && options[toHighlightedIndex.value]) {
      selectToCurrency(options[toHighlightedIndex.value].code)
    }
  } else if (e.key === 'Escape') {
    showToDropdown.value = false
  }
}

function scrollToHighlighted(type) {
  nextTick(() => {
    const wrapper = type === 'from' ? fromCurrencyWrapper.value : toCurrencyWrapper.value
    if (!wrapper) return
    
    const highlighted = wrapper.querySelector('.currency-option.highlight')
    if (highlighted) {
      highlighted.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }
  })
}

// 点击外部关闭下拉框
function handleClickOutside(e) {
  if (fromCurrencyWrapper.value && !fromCurrencyWrapper.value.contains(e.target)) {
    showFromDropdown.value = false
  }
  if (toCurrencyWrapper.value && !toCurrencyWrapper.value.contains(e.target)) {
    showToDropdown.value = false
  }
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
    updateCurrencyDisplay()
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
  updateCurrencyDisplay()
  
  // 点击外部关闭下拉框
  document.addEventListener('click', handleClickOutside)
  
  // 定期更新汇率（每5分钟）
  setInterval(async () => {
    await fetchExchangeRates(fromCurrency.value)
  }, 5 * 60 * 1000)
})

// 监听货币变化，更新显示
watch([fromCurrency, toCurrency], () => {
  updateCurrencyDisplay()
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

.currency-select-wrapper {
  position: relative;
  min-width: 150px;
}

.currency-select-input {
  width: 100%;
  padding: var(--spacing-sm) 40px var(--spacing-sm) var(--spacing-lg);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: var(--font-size-base);
  background: var(--color-surface);
  cursor: pointer;
  transition: all 0.3s;
  font-weight: 500;
  color: var(--color-text);
}

.currency-select-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
  cursor: text;
}

.currency-select-arrow {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: var(--color-primary);
  font-size: var(--font-size-small);
  transition: transform 0.3s;
}

.currency-select-wrapper.open .currency-select-arrow {
  transform: translateY(-50%) rotate(180deg);
}

.currency-dropdown {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  right: 0;
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  max-height: 300px;
  overflow: hidden;
  z-index: 1000;
  display: flex;
  flex-direction: column;
}

.currency-search-input {
  width: 100%;
  padding: 12px 16px;
  border: none;
  border-bottom: 2px solid var(--color-border);
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  font-size: var(--font-size-small);
  background: var(--color-surface-alt);
  color: var(--color-text);
}

.currency-search-input:focus {
  outline: none;
  background: var(--color-surface);
  border-bottom-color: var(--color-primary);
}

.currency-options {
  max-height: 250px;
  overflow-y: auto;
}

.currency-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 1px solid var(--color-border);
}

.currency-option:last-child {
  border-bottom: none;
}

.currency-option:hover,
.currency-option.highlight {
  background: var(--color-surface-alt);
  border-left: 3px solid var(--color-primary);
  padding-left: 13px;
}

.currency-option.selected {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
}

.currency-option.selected .currency-option-code,
.currency-option.selected .currency-option-name {
  color: var(--color-text-on-primary);
}

.currency-option-flag {
  font-size: 20px;
  flex-shrink: 0;
}

.currency-option-info {
  flex: 1;
  min-width: 0;
}

.currency-option-code {
  font-size: var(--font-size-small);
  font-weight: 700;
  color: var(--color-text);
  margin-bottom: 2px;
}

.currency-option-name {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.currency-no-results {
  padding: 20px;
  text-align: center;
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
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
