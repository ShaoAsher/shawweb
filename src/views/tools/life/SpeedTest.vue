<template>
  <ToolLayout
    icon="🚀"
    title="网络测速工具"
    description="测试网络延迟、下载速度和上传速度，类似 Speedtest，实时显示测试进度和结果"
  >
    <div class="speed-test-container">
      <div class="server-info">
        {{ serverInfo }}
      </div>

      <button class="test-button" @click="runSpeedTest" :disabled="testing">
        <span v-if="testing" class="spinner"></span>
        <span v-else>🚀</span>
        <span>{{ testing ? '测试中...' : '开始测速' }}</span>
      </button>

      <div class="test-results">
        <div class="result-card" :class="{ testing: pingTesting }">
          <div class="result-icon">📡</div>
          <div class="result-label">延迟 (Ping)</div>
          <div class="result-value">{{ pingValue }}</div>
          <div class="result-unit">ms</div>
          <div class="result-status">{{ pingStatus }}</div>
          <div v-if="pingTesting" class="progress-bar active">
            <div class="progress-fill" :style="{ width: pingProgress + '%' }"></div>
          </div>
        </div>

        <div class="result-card" :class="{ testing: downloadTesting }">
          <div class="result-icon">⬇️</div>
          <div class="result-label">下载速度</div>
          <div class="result-value">{{ downloadValue }}</div>
          <div class="result-unit">Mbps</div>
          <div class="result-status">{{ downloadStatus }}</div>
          <div v-if="downloadTesting" class="progress-bar active">
            <div class="progress-fill" :style="{ width: downloadProgress + '%' }"></div>
          </div>
        </div>

        <div class="result-card" :class="{ testing: uploadTesting }">
          <div class="result-icon">⬆️</div>
          <div class="result-label">上传速度</div>
          <div class="result-value">{{ uploadValue }}</div>
          <div class="result-unit">Mbps</div>
          <div class="result-status">{{ uploadStatus }}</div>
          <div v-if="uploadTesting" class="progress-bar active">
            <div class="progress-fill" :style="{ width: uploadProgress + '%' }"></div>
          </div>
        </div>
      </div>

      <div v-if="showSummary" class="summary-section show">
        <div class="summary-title">
          <span>📊</span>
          <span>测试结果摘要</span>
        </div>
        <div class="summary-grid">
          <div class="summary-item">
            <div class="summary-label">延迟</div>
            <div class="summary-value">{{ summaryPing }} ms</div>
          </div>
          <div class="summary-item">
            <div class="summary-label">下载速度</div>
            <div class="summary-value">{{ summaryDownload }} Mbps</div>
          </div>
          <div class="summary-item">
            <div class="summary-label">上传速度</div>
            <div class="summary-value">{{ summaryUpload }} Mbps</div>
          </div>
          <div class="summary-item">
            <div class="summary-label">测试时间</div>
            <div class="summary-value">{{ summaryTime }} 秒</div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

const serverInfo = ref('正在选择最佳测试服务器...')
const testing = ref(false)
const pingValue = ref('--')
const pingStatus = ref('等待测试')
const pingTesting = ref(false)
const pingProgress = ref(0)

const downloadValue = ref('--')
const downloadStatus = ref('等待测试')
const downloadTesting = ref(false)
const downloadProgress = ref(0)

const uploadValue = ref('--')
const uploadStatus = ref('等待测试')
const uploadTesting = ref(false)
const uploadProgress = ref(0)

const showSummary = ref(false)
const summaryPing = ref('--')
const summaryDownload = ref('--')
const summaryUpload = ref('--')
const summaryTime = ref('--')

let currentServer = null
let testStartTime = null

const testServers = [
  {
    name: 'Cloudflare',
    pingUrl: 'https://1.1.1.1',
    downloadUrl: 'https://speed.cloudflare.com/__down?bytes=',
    uploadUrl: 'https://speed.cloudflare.com/__up'
  },
  {
    name: 'Google',
    pingUrl: 'https://www.google.com',
    downloadUrl: 'https://speed.cloudflare.com/__down?bytes=',
    uploadUrl: 'https://speed.cloudflare.com/__up'
  }
]

async function selectBestServer() {
  serverInfo.value = '正在选择最佳测试服务器...'
  
  let bestServer = testServers[0]
  let bestPing = Infinity

  for (const server of testServers) {
    try {
      const startTime = performance.now()
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 5000)

      try {
        await fetch(server.pingUrl, {
          method: 'HEAD',
          mode: 'no-cors',
          cache: 'no-store',
          signal: controller.signal
        })
        clearTimeout(timeoutId)
        const ping = performance.now() - startTime

        if (ping < bestPing) {
          bestPing = ping
          bestServer = server
        }
      } catch (fetchError) {
        clearTimeout(timeoutId)
        if (fetchError.name !== 'AbortError') {
          throw fetchError
        }
      }
    } catch (error) {
      console.log(`服务器 ${server.name} 测试失败:`, error)
    }
  }

  currentServer = bestServer
  serverInfo.value = `已选择测试服务器: ${bestServer.name}`
  return bestServer
}

async function testPing() {
  pingTesting.value = true
  pingStatus.value = '测试中...'
  pingProgress.value = 0

  try {
    const times = []
    const testCount = 3

    for (let i = 0; i < testCount; i++) {
      const startTime = performance.now()
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 5000)

      try {
        await fetch(currentServer.pingUrl, {
          method: 'HEAD',
          mode: 'no-cors',
          cache: 'no-store',
          signal: controller.signal
        })
        clearTimeout(timeoutId)
        const ping = performance.now() - startTime
        times.push(ping)
      } catch (fetchError) {
        clearTimeout(timeoutId)
        if (fetchError.name === 'AbortError') {
          times.push(5000)
        } else {
          throw fetchError
        }
      }

      pingProgress.value = ((i + 1) / testCount) * 100
      await new Promise(resolve => setTimeout(resolve, 200))
    }

    const avgPing = times.reduce((a, b) => a + b, 0) / times.length
    pingValue.value = Math.round(avgPing).toString()
    pingStatus.value = '测试完成'
    pingTesting.value = false

    return avgPing
  } catch (error) {
    pingValue.value = '错误'
    pingStatus.value = '测试失败: ' + error.message
    pingTesting.value = false
    throw error
  }
}

async function testDownload() {
  downloadTesting.value = true
  downloadStatus.value = '测试中...'
  downloadProgress.value = 0

  try {
    const testSizes = [1 * 1024 * 1024, 5 * 1024 * 1024, 10 * 1024 * 1024]
    let totalBytes = 0
    let totalTime = 0

    for (let i = 0; i < testSizes.length; i++) {
      const size = testSizes[i]
      const url = `${currentServer.downloadUrl}${size}`

      const startTime = performance.now()
      const response = await fetch(url, {
        cache: 'no-store'
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      const reader = response.body.getReader()
      let receivedBytes = 0

      while (true) {
        const { done, value } = await reader.read()
        if (done) break
        receivedBytes += value.length

        const progress = ((receivedBytes / size) * 100) / testSizes.length + (i * 100 / testSizes.length)
        downloadProgress.value = Math.min(progress, 100)
      }

      const endTime = performance.now()
      const duration = (endTime - startTime) / 1000
      totalBytes += receivedBytes
      totalTime += duration
    }

    const speedMbps = (totalBytes * 8) / (totalTime * 1000000)
    downloadValue.value = speedMbps.toFixed(2)
    downloadStatus.value = '测试完成'
    downloadTesting.value = false
    downloadProgress.value = 100

    return speedMbps
  } catch (error) {
    downloadValue.value = '错误'
    downloadStatus.value = '测试失败: ' + error.message
    downloadTesting.value = false
    throw error
  }
}

async function testUpload() {
  uploadTesting.value = true
  uploadStatus.value = '测试中...'
  uploadProgress.value = 0

  try {
    const testSizes = [1 * 1024 * 1024, 2 * 1024 * 1024]
    let totalBytes = 0
    let totalTime = 0

    for (let i = 0; i < testSizes.length; i++) {
      const size = testSizes[i]
      const testData = new Uint8Array(size)
      for (let j = 0; j < size; j++) {
        testData[j] = Math.floor(Math.random() * 256)
      }

      const blob = new Blob([testData])
      const formData = new FormData()
      formData.append('file', blob, 'test.dat')

      const startTime = performance.now()

      try {
        const response = await fetch(currentServer.uploadUrl, {
          method: 'POST',
          body: formData,
          cache: 'no-store',
          mode: 'cors'
        })

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`)
        }

        await response.text()
        const endTime = performance.now()
        const duration = (endTime - startTime) / 1000
        totalBytes += size
        totalTime += duration
      } catch (uploadError) {
        if (i === 0) {
          const downloadSpeed = parseFloat(downloadValue.value) || 10
          const estimatedUpload = downloadSpeed * 0.1
          uploadValue.value = estimatedUpload.toFixed(2)
          uploadStatus.value = '估算值（上传测试受限）'
          uploadTesting.value = false
          uploadProgress.value = 100
          return estimatedUpload
        }
        throw uploadError
      }

      uploadProgress.value = ((i + 1) / testSizes.length) * 100
    }

    const speedMbps = (totalBytes * 8) / (totalTime * 1000000)
    uploadValue.value = speedMbps.toFixed(2)
    uploadStatus.value = '测试完成'
    uploadTesting.value = false
    uploadProgress.value = 100

    return speedMbps
  } catch (error) {
    try {
      const downloadSpeed = parseFloat(downloadValue.value) || 10
      const estimatedUpload = downloadSpeed * 0.1
      uploadValue.value = estimatedUpload.toFixed(2)
      uploadStatus.value = '估算值（上传测试受限）'
      uploadTesting.value = false
      uploadProgress.value = 100
      return estimatedUpload
    } catch (fallbackError) {
      uploadValue.value = '错误'
      uploadStatus.value = '测试失败: ' + error.message
      uploadTesting.value = false
      throw error
    }
  }
}

async function runSpeedTest() {
  testing.value = true
  pingValue.value = '--'
  downloadValue.value = '--'
  uploadValue.value = '--'
  pingStatus.value = '等待测试'
  downloadStatus.value = '等待测试'
  uploadStatus.value = '等待测试'
  showSummary.value = false

  testStartTime = new Date()

  try {
    await selectBestServer()
    const ping = await testPing()
    const download = await testDownload()
    const upload = await testUpload()

    const testEndTime = new Date()
    const testDuration = Math.round((testEndTime - testStartTime) / 1000)

    summaryPing.value = Math.round(ping).toString()
    summaryDownload.value = download.toFixed(2)
    summaryUpload.value = upload.toFixed(2)
    summaryTime.value = testDuration.toString()
    showSummary.value = true
  } catch (error) {
    console.error('测试失败:', error)
    alert('测试过程中出现错误: ' + error.message)
  } finally {
    testing.value = false
  }
}

onMounted(() => {
  selectBestServer()
})
</script>

<style scoped>
.speed-test-container {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-xl);
  margin-bottom: var(--spacing-lg);
  border: 1px solid var(--color-border);
}

.server-info {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-md);
  margin-bottom: var(--spacing-lg);
  border: 1px solid var(--color-border);
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  text-align: center;
}

.test-button {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  padding: var(--spacing-md) var(--spacing-xl);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  border: none;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  width: 100%;
  max-width: 300px;
  margin: 0 auto;
}

.test-button:hover:not(:disabled) {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.test-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.test-results {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-lg);
  margin-top: var(--spacing-xl);
}

.result-card {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  border: 2px solid var(--color-border);
  box-shadow: var(--shadow-sm);
  text-align: center;
  transition: all 0.3s;
}

.result-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-md);
  border-color: var(--color-primary);
}

.result-card.testing {
  border-color: var(--color-primary);
  box-shadow: 0 0 20px var(--color-shadow-primary);
}

.result-icon {
  font-size: 48px;
  margin-bottom: var(--spacing-md);
}

.result-label {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: var(--spacing-sm);
}

.result-value {
  font-size: 36px;
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
  min-height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.result-unit {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-normal);
}

.result-status {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-top: var(--spacing-sm);
  min-height: 20px;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: var(--color-border);
  border-radius: var(--radius-full);
  overflow: hidden;
  margin-top: var(--spacing-md);
  display: none;
}

.progress-bar.active {
  display: block;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  border-radius: var(--radius-full);
  transition: width 0.3s ease;
}

.summary-section {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-top: var(--spacing-lg);
  border: 1px solid var(--color-border);
  display: none;
}

.summary-section.show {
  display: block;
}

.summary-title {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-md);
}

.summary-item {
  background: var(--color-background-alt);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
}

.summary-label {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-xs);
}

.summary-value {
  font-size: var(--font-size-base);
  color: var(--color-text);
  font-weight: var(--font-weight-semibold);
}

.spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top-color: var(--color-text-on-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 768px) {
  .test-results {
    grid-template-columns: 1fr;
  }

  .test-button {
    width: 100%;
  }
}
</style>
