<template>
  <ToolLayout
    icon="🌍"
    title="IP地址查询工具"
    description="查询当前IP和输入IP的归属地信息，包括国家、城市、ISP、时区等详细信息"
  >
    <!-- 当前IP查询 -->
    <div class="query-section">
      <h2>
        <span>🌐</span>
        <span>当前IP地址查询</span>
      </h2>
      <AppButton 
        variant="primary" 
        icon="🔍" 
        :loading="loading && currentLoading"
        :disabled="loading"
        @click="queryCurrentIP"
      >
        查询我的IP
      </AppButton>
      <div v-if="currentLoading" class="loading">
        <div class="loading-spinner"></div>
        <div>正在查询中...</div>
      </div>
      <div v-else-if="currentError" class="error">
        <strong>❌ 查询失败</strong>
        <p>{{ currentError }}</p>
      </div>
      <div v-else-if="currentResult" class="result-card">
        <h3>
          <span>🌐</span>
          <span>当前IP信息</span>
          <span class="ip-badge">{{ currentResult.ip }}</span>
        </h3>
        <div class="result-grid">
          <div class="result-item">
            <div class="result-label">国家/地区</div>
            <div class="result-value">
              {{ currentResult.country }}
              <span v-if="currentResult.countryCode">({{ currentResult.countryCode }})</span>
            </div>
          </div>
          <div class="result-item">
            <div class="result-label">省份/州</div>
            <div class="result-value">{{ currentResult.region }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">城市</div>
            <div class="result-value">{{ currentResult.city }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">邮政编码</div>
            <div class="result-value" :class="{ empty: currentResult.zip === '未知' }">
              {{ currentResult.zip }}
            </div>
          </div>
          <div class="result-item">
            <div class="result-label">时区</div>
            <div class="result-value">{{ currentResult.timezone }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">ISP服务商</div>
            <div class="result-value">{{ currentResult.isp }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">组织</div>
            <div class="result-value" :class="{ empty: currentResult.org === '未知' }">
              {{ currentResult.org }}
            </div>
          </div>
          <div class="result-item">
            <div class="result-label">AS编号</div>
            <div class="result-value" :class="{ empty: currentResult.as === '未知' }">
              {{ currentResult.as }}
            </div>
          </div>
          <div v-if="currentResult.lat && currentResult.lon" class="result-item">
            <div class="result-label">经纬度</div>
            <div class="result-value">{{ currentResult.lat }}, {{ currentResult.lon }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 输入IP查询 -->
    <div class="query-section">
      <h2>
        <span>🔍</span>
        <span>IP地址归属地查询</span>
      </h2>
      <div class="query-form">
        <div class="input-group">
          <label for="ipInput">IP地址</label>
          <input
            v-model="ipInput"
            type="text"
            id="ipInput"
            placeholder="请输入IP地址，例如：8.8.8.8"
            @keypress.enter="queryIP"
          />
        </div>
        <AppButton 
          variant="primary" 
          icon="🔍" 
          :loading="loading && !currentLoading"
          :disabled="loading"
          @click="queryIP"
        >
          查询
        </AppButton>
      </div>
      <div v-if="ipLoading" class="loading">
        <div class="loading-spinner"></div>
        <div>正在查询中...</div>
      </div>
      <div v-else-if="ipError" class="error">
        <strong>❌ 查询失败</strong>
        <p>{{ ipError }}</p>
      </div>
      <div v-else-if="ipResult" class="result-card">
        <h3>
          <span>📍</span>
          <span>IP归属地信息</span>
          <span class="ip-badge">{{ ipResult.ip }}</span>
        </h3>
        <div class="result-grid">
          <div class="result-item">
            <div class="result-label">国家/地区</div>
            <div class="result-value">
              {{ ipResult.country }}
              <span v-if="ipResult.countryCode">({{ ipResult.countryCode }})</span>
            </div>
          </div>
          <div class="result-item">
            <div class="result-label">省份/州</div>
            <div class="result-value">{{ ipResult.region }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">城市</div>
            <div class="result-value">{{ ipResult.city }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">邮政编码</div>
            <div class="result-value" :class="{ empty: ipResult.zip === '未知' }">
              {{ ipResult.zip }}
            </div>
          </div>
          <div class="result-item">
            <div class="result-label">时区</div>
            <div class="result-value">{{ ipResult.timezone }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">ISP服务商</div>
            <div class="result-value">{{ ipResult.isp }}</div>
          </div>
          <div class="result-item">
            <div class="result-label">组织</div>
            <div class="result-value" :class="{ empty: ipResult.org === '未知' }">
              {{ ipResult.org }}
            </div>
          </div>
          <div class="result-item">
            <div class="result-label">AS编号</div>
            <div class="result-value" :class="{ empty: ipResult.as === '未知' }">
              {{ ipResult.as }}
            </div>
          </div>
          <div v-if="ipResult.lat && ipResult.lon" class="result-item">
            <div class="result-label">经纬度</div>
            <div class="result-value">{{ ipResult.lat }}, {{ ipResult.lon }}</div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

const ipInput = ref('')
const loading = ref(false)
const currentLoading = ref(false)
const ipLoading = ref(false)
const currentError = ref('')
const ipError = ref('')
const currentResult = ref(null)
const ipResult = ref(null)

const IPINFO_API_BASE = 'https://ipinfo.io/'
const IPWHOIS_API_BASE = 'https://ipwhois.app/json/'

function isValidIP(ip) {
  const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  return ipRegex.test(ip)
}

async function queryIPWithIpinfo(ip = '') {
  const url = ip ? `${IPINFO_API_BASE}${ip}/json` : `${IPINFO_API_BASE}json`
  const response = await fetch(url)

  if (!response.ok) {
    throw new Error(`HTTP错误: ${response.status}`)
  }

  const data = await response.json()

  let lat = 0, lon = 0
  if (data.loc) {
    const [latitude, longitude] = data.loc.split(',').map(Number)
    lat = latitude || 0
    lon = longitude || 0
  }

  let as = '未知'
  if (data.org) {
    const asMatch = data.org.match(/AS\d+/)
    if (asMatch) {
      as = asMatch[0]
    }
  }

  return {
    ip: data.ip || ip || '未知',
    country: data.country_name || data.country || '未知',
    countryCode: data.country || '',
    region: data.region || '未知',
    city: data.city || '未知',
    zip: data.postal || '未知',
    lat: lat,
    lon: lon,
    timezone: data.timezone || '未知',
    isp: data.org ? data.org.replace(/AS\d+\s*/, '') : '未知',
    org: data.org || '未知',
    as: as
  }
}

async function queryIPWithIpwhois(ip = '') {
  const url = ip ? `${IPWHOIS_API_BASE}${ip}` : IPWHOIS_API_BASE
  const response = await fetch(url)

  if (!response.ok) {
    throw new Error(`HTTP错误: ${response.status}`)
  }

  const data = await response.json()

  if (data.success === false) {
    throw new Error(data.message || '查询失败')
  }

  return {
    ip: data.ip || ip || '未知',
    country: data.country || '未知',
    countryCode: data.country_code || '',
    region: data.region || '未知',
    city: data.city || '未知',
    zip: data.postal || '未知',
    lat: data.latitude || 0,
    lon: data.longitude || 0,
    timezone: data.timezone || '未知',
    isp: data.isp || '未知',
    org: data.org || '未知',
    as: data.asn ? `AS${data.asn}` : '未知'
  }
}

async function queryIP(ip = '') {
  const apis = [
    { name: 'ipinfo.io', func: queryIPWithIpinfo },
    { name: 'ipwhois.app', func: queryIPWithIpwhois }
  ]

  for (const api of apis) {
    try {
      return await api.func(ip)
    } catch (error) {
      console.log(`${api.name} 查询失败:`, error.message)
      continue
    }
  }

  throw new Error('所有API查询均失败，请检查网络连接或稍后重试。')
}

async function queryCurrentIP() {
  currentLoading.value = true
  loading.value = true
  currentError.value = ''
  currentResult.value = null

  try {
    const data = await queryIP()
    currentResult.value = data
  } catch (error) {
    currentError.value = error.message || '无法获取当前IP信息，请检查网络连接'
  } finally {
    currentLoading.value = false
    loading.value = false
  }
}

async function queryIPAddress() {
  const ip = ipInput.value.trim()
  
  if (!ip) {
    ipError.value = '请输入IP地址'
    return
  }

  if (!isValidIP(ip)) {
    ipError.value = 'IP地址格式不正确，请输入有效的IPv4地址'
    return
  }

  ipLoading.value = true
  loading.value = true
  ipError.value = ''
  ipResult.value = null

  try {
    const data = await queryIP(ip)
    ipResult.value = data
  } catch (error) {
    ipError.value = error.message || '查询失败，请检查IP地址是否正确'
  } finally {
    ipLoading.value = false
    loading.value = false
  }
}

onMounted(() => {
  // 延迟一下，确保页面完全加载
  setTimeout(() => {
    queryCurrentIP()
  }, 500)
})
</script>

<style scoped>
.query-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
  border: 1px solid var(--color-border);
}

.query-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.query-form {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: flex-end;
}

.input-group {
  flex: 1;
  min-width: 200px;
}

.input-group label {
  display: block;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
  font-size: var(--font-size-small);
}

.input-group input {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  background: var(--color-surface);
  color: var(--color-text);
}

.input-group input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  padding: var(--spacing-sm) var(--spacing-xl);
  border-radius: var(--radius-sm);
  border: none;
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: all .3s;
}

.btn:hover:not(:disabled) {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.loading {
  text-align: center;
  padding: var(--spacing-xl);
  color: var(--color-text-secondary);
}

.loading-spinner {
  display: inline-block;
  width: 40px;
  height: 40px;
  border: 4px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: var(--spacing-md);
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.error {
  background: var(--color-surface-alt);
  border-color: var(--color-error);
  color: var(--color-error);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-top: var(--spacing-md);
  border: 2px solid var(--color-error);
}

.result-card {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-top: var(--spacing-lg);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-sm);
}

.result-card h3 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding-bottom: var(--spacing-sm);
  border-bottom: 2px solid var(--color-border);
}

.result-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--spacing-md);
}

.result-item {
  background: var(--color-surface-alt);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
}

.result-label {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: var(--spacing-xs);
}

.result-value {
  font-size: var(--font-size-base);
  color: var(--color-text);
  font-weight: var(--font-weight-semibold);
  word-break: break-all;
}

.result-value.empty {
  color: var(--color-text-secondary);
  font-style: italic;
}

.ip-badge {
  display: inline-block;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--radius-lg);
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  margin-left: var(--spacing-sm);
}

@media (max-width: 768px) {
  .query-form {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }

  .result-grid {
    grid-template-columns: 1fr;
  }
}
</style>
