<template>
  <ToolLayout title="🔑 Android 签名文件生成工具" description="根据包名生成 .jks 并提取指纹与公钥信息，支持历史记录导入导出">
    <div class="info-box">
      <strong>使用说明：</strong>输入Android包名和其他信息，系统将自动生成签名文件（keystore）。密钥别名自动使用包名，保存的文件名也与包名相同。
    </div>

    <div class="form-section">
      <h2>签名信息配置</h2>
      <div class="form-group">
        <label for="packageName">Android 包名 *</label>
        <input type="text" id="packageName" v-model="packageName" @input="updateKeyAlias" @blur="checkExisting" placeholder="例如: com.example.myapp" required>
        <small>输入应用的完整包名</small>
      </div>
      <div class="form-group">
        <label for="keyAlias">密钥别名 (keyAlias) *</label>
        <input type="text" id="keyAlias" v-model="keyAlias" placeholder="与包名相同" readonly required>
        <small>密钥别名自动使用包名</small>
      </div>
      <div class="form-group">
        <label for="storePassword">密钥库密码 (storePassword/keyPassword) *</label>
        <input type="text" id="storePassword" v-model="storePassword" placeholder="至少6个字符" value="123456" required>
        <small>用于保护密钥库文件和密钥的密码（storePassword 和 keyPassword 使用相同密码，至少6个字符）</small>
      </div>
      <div class="form-group">
        <label for="validity">有效期（年）</label>
        <input type="number" id="validity" v-model.number="validity" placeholder="100" min="1" max="100">
        <small>证书有效期，默认100年</small>
      </div>
      <div class="form-group">
        <label for="name">姓名/组织</label>
        <input type="text" id="name" v-model="name" placeholder="CN" value="CN">
        <small>证书持有者姓名</small>
      </div>
      <div class="form-group">
        <label for="org">组织单位</label>
        <input type="text" id="org" v-model="org" placeholder="OU" value="OU">
        <small>组织单位名称</small>
      </div>
      <div class="form-group">
        <label for="orgUnit">组织</label>
        <input type="text" id="orgUnit" v-model="orgUnit" placeholder="O" value="O">
        <small>组织名称</small>
      </div>
      <div class="form-group">
        <label for="city">城市</label>
        <input type="text" id="city" v-model="city" placeholder="L" value="L">
        <small>城市名称</small>
      </div>
      <div class="form-group">
        <label for="state">州/省</label>
        <input type="text" id="state" v-model="state" placeholder="ST" value="ST">
        <small>州或省名称</small>
      </div>
      <div class="form-group">
        <label for="country">国家代码</label>
        <input type="text" id="country" v-model="country" placeholder="CN" value="CN" maxlength="2">
        <small>两字母国家代码（如：CN, US）</small>
      </div>
    </div>

    <AppButton 
      variant="primary" 
      size="lg" 
      :loading="loading" 
      :disabled="loading" 
      icon="🔑"
      @click="generateKeystore"
    >
      生成签名文件
    </AppButton>

    <div v-if="errorMessage" class="error show">
      {{ errorMessage }}
    </div>
    <div v-if="successMessage" class="success show">
      {{ successMessage }}
    </div>

    <div class="form-section history-section">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 10px;">
        <h2 style="margin: 0;">历史记录</h2>
        <ButtonGroup gap="sm">
          <AppButton variant="success" size="sm" icon="📤" @click="exportAllToProject">导出所有到项目目录</AppButton>
          <AppButton variant="info" size="sm" icon="📋" @click="exportHistoryToFile">导出元数据</AppButton>
          <AppButton variant="secondary" size="sm" icon="📥" @click="importHistoryFromFile">导入历史</AppButton>
        </ButtonGroup>
      </div>
      <div class="info-box" style="margin-bottom: 20px;">
        <strong>说明：</strong>
        <ul style="margin: 10px 0 0 20px; padding: 0; line-height: 1.8;">
          <li><strong>.keystore 和 .jks 的区别：</strong>两者都是 Java KeyStore 格式，.jks 是原始格式名称，.keystore 是别名。在 Android 开发中可以互换使用。本工具生成的是 PKCS#12 格式（兼容 .keystore/.jks），默认生成 .jks 文件。</li>
          <li><strong>密钥别名：</strong>密钥别名自动使用包名，无需手动输入。</li>
          <li><strong>导出所有到项目目录：</strong>会生成一个 ZIP 文件，包含所有 .jks 文件和元数据 JSON，下载后解压到项目根目录即可。这样换电脑也不会丢失数据。</li>
          <li><strong>导入历史：</strong>支持导入 JSON 或 ZIP 格式的历史记录文件。</li>
        </ul>
      </div>
      <div class="search-box">
        <input type="text" v-model="searchQuery" placeholder="搜索包名...">
      </div>
      <div ref="historyList" class="history-list-container"></div>
    </div>

    <!-- 详情弹窗 -->
    <Teleport to="body">
      <div v-if="showDetailModal" class="detail-modal-overlay" @click="closeDetailModal">
        <div class="detail-modal compact" @click.stop>
          <div class="detail-modal-header">
            <h3>📋 签名文件详情</h3>
            <div class="modal-header-actions">
              <AppButton variant="success" size="sm" icon="📥" @click="downloadFromHistory(selectedItem.packageName)">下载</AppButton>
              <AppButton variant="danger" size="sm" icon="🗑️" @click="handleDeleteFromModal">删除</AppButton>
              <button class="modal-close-btn" @click="closeDetailModal">×</button>
            </div>
          </div>
          <div class="detail-modal-content compact" v-if="selectedItem">
            <!-- 基础信息区 -->
            <div class="info-section">
              <div class="info-row">
                <span class="info-label">包名</span>
                <span class="info-value mono">{{ selectedItem.packageName }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">别名</span>
                <span class="info-value mono">{{ selectedItem.keyAlias || selectedItem.alias }}</span>
                <AppButton variant="secondary" size="sm" icon="📋" @click="copyToClipboard(selectedItem.keyAlias || selectedItem.alias)">复制</AppButton>
              </div>
              <div class="info-row">
                <span class="info-label">密钥库密码</span>
                <span class="info-value mono">{{ selectedItem.storePassword || selectedItem.password }}</span>
                <AppButton variant="secondary" size="sm" icon="📋" @click="copyToClipboard(selectedItem.storePassword || selectedItem.password)">复制</AppButton>
              </div>
              <div class="info-row">
                <span class="info-label">密钥密码</span>
                <span class="info-value mono">{{ selectedItem.keyPassword || selectedItem.password }}</span>
                <AppButton variant="secondary" size="sm" icon="📋" @click="copyToClipboard(selectedItem.keyPassword || selectedItem.password)">复制</AppButton>
              </div>
              <div class="info-row">
                <span class="info-label">创建时间</span>
                <span class="info-value">{{ new Date(selectedItem.timestamp).toLocaleString('zh-CN') }}</span>
              </div>
            </div>
            
            <!-- 指纹信息区 -->
            <div class="hash-section">
              <div class="hash-group">
                <div class="hash-title">MD5 指纹</div>
                <div class="hash-row">
                  <span class="hash-style-label">空格：</span>
                  <code class="hash-code">{{ formatHashForDisplay(selectedItem.md5) }}</code>
                  <AppButton variant="secondary" size="sm" icon="📋" @click="copyHash(selectedItem.md5, 'space')">复制</AppButton>
                </div>
                <div class="hash-row">
                  <span class="hash-style-label">冒号：</span>
                  <code class="hash-code">{{ formatHashForDisplay(selectedItem.md5, 'colon') }}</code>
                  <AppButton variant="secondary" size="sm" icon="📋" @click="copyHash(selectedItem.md5, 'colon')">复制</AppButton>
                </div>
              </div>
              
              <div class="hash-group">
                <div class="hash-title">SHA1 指纹</div>
                <div class="hash-row">
                  <span class="hash-style-label">空格：</span>
                  <code class="hash-code">{{ formatHashForDisplay(selectedItem.sha1) }}</code>
                  <AppButton variant="secondary" size="sm" icon="📋" @click="copyHash(selectedItem.sha1, 'space')">复制</AppButton>
                </div>
                <div class="hash-row">
                  <span class="hash-style-label">冒号：</span>
                  <code class="hash-code">{{ formatHashForDisplay(selectedItem.sha1, 'colon') }}</code>
                  <AppButton variant="secondary" size="sm" icon="📋" @click="copyHash(selectedItem.sha1, 'colon')">复制</AppButton>
                </div>
              </div>
              
              <div class="hash-group">
                <div class="hash-title">SHA256 指纹</div>
                <div class="hash-row">
                  <span class="hash-style-label">空格：</span>
                  <code class="hash-code small">{{ formatHashForDisplay(selectedItem.sha256) }}</code>
                  <AppButton variant="secondary" size="sm" icon="📋" @click="copyHash(selectedItem.sha256, 'space')">复制</AppButton>
                </div>
                <div class="hash-row">
                  <span class="hash-style-label">冒号：</span>
                  <code class="hash-code small">{{ formatHashForDisplay(selectedItem.sha256, 'colon') }}</code>
                  <AppButton variant="secondary" size="sm" icon="📋" @click="copyHash(selectedItem.sha256, 'colon')">复制</AppButton>
                </div>
              </div>
            </div>
            
            <!-- 公钥区 -->
            <div class="pubkey-section">
              <div class="pubkey-header">
                <span class="pubkey-title">公钥（大整数格式）</span>
                <AppButton variant="secondary" size="sm" icon="📋" @click="copyToClipboard(selectedItem.publicKey)">复制</AppButton>
              </div>
              <code class="pubkey-value">{{ selectedItem.publicKey }}</code>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </ToolLayout>
</template>

<script setup>
import AppButton from '@/components/AppButton.vue'
import ToolLayout from '@/components/ToolLayout.vue'
import { useToast } from '@/composables/useToast.js'
import { loadScript } from '@/utils/cdn-loader.js'
import { nextTick, onMounted, ref, watch } from 'vue'

const { success: showSuccess } = useToast()

const STORAGE_KEY = 'keystore_history'
const packageName = ref('')
const keyAlias = ref('')
const storePassword = ref('123456')
const validity = ref(100)
const name = ref('CN')
const org = ref('OU')
const orgUnit = ref('O')
const city = ref('L')
const state = ref('ST')
const country = ref('CN')
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const searchQuery = ref('')
const historyList = ref(null)
const showDetailModal = ref(false)
const selectedItem = ref(null)
let forge = null
let CryptoJS = null
let JSZip = null

onMounted(async () => {
  // 加载必要的库
  try {
    await Promise.all([
      loadScript('https://cdnjs.cloudflare.com/ajax/libs/forge/1.3.1/forge.min.js'),
      loadScript('https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js'),
      loadScript('https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js')
    ])
    forge = window.forge
    CryptoJS = window.CryptoJS
    JSZip = window.JSZip
    renderHistory()
  } catch (err) {
    console.error('Failed to load libraries:', err)
    errorMessage.value = '加载必要的库失败'
  }
})

watch(searchQuery, () => {
  renderHistory()
})

function updateKeyAlias() {
  keyAlias.value = packageName.value
}

function checkExisting() {
  if (!packageName.value.trim()) return
  const existing = checkExistingHistory(packageName.value)
  if (existing) {
    errorMessage.value = `提示：包名 "${packageName.value}" 已存在于历史记录中。点击"生成签名文件"时会提示是否覆盖，或选择"取消"直接查看历史记录。`
    setTimeout(() => {
      errorMessage.value = ''
    }, 5000)
  }
}

function generateDeterministicKeyPair(packageName, bits = 2048) {
  const seedBase = CryptoJS.SHA256(packageName).toString()
  let seedBytes = []
  let counter = 0
  while (seedBytes.length < 10000) {
    const hash = CryptoJS.SHA256(seedBase + counter.toString()).toString()
    const bytes = forge.util.hexToBytes(hash)
    for (let i = 0; i < bytes.length; i++) {
      seedBytes.push(bytes.charCodeAt(i) & 0xFF)
    }
    counter++
  }
  let seedIndex = 0
  const prng = {
    getBytesSync: function (count) {
      let result = ''
      for (let i = 0; i < count; i++) {
        const byte = seedBytes[seedIndex % seedBytes.length]
        result += String.fromCharCode(byte)
        seedIndex++
      }
      return result
    }
  }
  return forge.pki.rsa.generateKeyPair(bits, { prng: prng })
}

function formatHash(hashString) {
  return hashString.toUpperCase().match(/.{1,2}/g).join(' ')
}


function getHistory() {
  const stored = localStorage.getItem(STORAGE_KEY)
  return stored ? JSON.parse(stored) : []
}

function saveHistory(packageName, keystoreData, keyAlias, storePassword, keyPassword, md5, sha1, sha256, publicKey) {
  const history = getHistory()
  const historyItem = {
    packageName,
    keyAlias,
    storePassword,
    keyPassword,
    alias: keyAlias,
    password: storePassword,
    md5,
    sha1,
    sha256,
    publicKey,
    keystoreData: Array.from(keystoreData),
    timestamp: new Date().toISOString()
  }
  const existingIndex = history.findIndex(item => item.packageName === packageName)
  if (existingIndex >= 0) {
    history[existingIndex] = historyItem
  } else {
    history.push(historyItem)
  }
  localStorage.setItem(STORAGE_KEY, JSON.stringify(history))
  renderHistory()
}

function checkExistingHistory(packageName) {
  const history = getHistory()
  return history.find(item => item.packageName === packageName)
}

async function generateKeystore() {
  const pkgName = packageName.value.trim()
  const alias = pkgName
  const password = storePassword.value
  const keyPassword = password
  const validYears = validity.value || 100
  const certName = name.value.trim() || 'CN'
  const certOrg = org.value.trim() || 'OU'
  const certOrgUnit = orgUnit.value.trim() || 'O'
  const certCity = city.value.trim() || 'L'
  const certState = state.value.trim() || 'ST'
  const certCountry = country.value.trim() || 'CN'

  if (!pkgName) {
    errorMessage.value = '请输入Android包名'
    return
  }

  keyAlias.value = alias

  if (!password || password.length < 6) {
    errorMessage.value = '密钥库密码至少需要6个字符'
    return
  }

  const existing = checkExistingHistory(pkgName)
  if (existing) {
    if (!confirm(`包名 "${pkgName}" 已存在于历史记录中，是否重新生成并覆盖？\n\n如果选择"取消"，将直接显示历史记录中的信息。`)) {
      renderHistory('', pkgName)
      setTimeout(() => {
        const historyItems = document.querySelectorAll('.history-item.highlight')
        historyItems.forEach((item) => {
          const detailId = item.querySelector('.history-detail')?.id
          if (detailId) {
            toggleHistoryDetail(item.id, detailId, pkgName)
            item.scrollIntoView({ behavior: 'smooth', block: 'center' })
          }
        })
      }, 200)
      return
    }
  }

  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const keyPair = generateDeterministicKeyPair(pkgName, 2048)
    const publicKey = keyPair.publicKey
    const privateKey = keyPair.privateKey

    const cert = forge.pki.createCertificate()
    cert.publicKey = publicKey
    cert.serialNumber = '01'
    cert.validity.notBefore = new Date()
    cert.validity.notAfter = new Date()
    cert.validity.notAfter.setFullYear(cert.validity.notAfter.getFullYear() + validYears)

    const attrs = [
      { name: 'countryName', value: certCountry },
      { name: 'stateOrProvinceName', value: certState },
      { name: 'localityName', value: certCity },
      { name: 'organizationName', value: certOrgUnit },
      { name: 'organizationalUnitName', value: certOrg },
      { name: 'commonName', value: certName }
    ]

    cert.setSubject(attrs)
    cert.setIssuer(attrs)

    cert.setExtensions([
      { name: 'basicConstraints', cA: true },
      {
        name: 'keyUsage',
        keyCertSign: true,
        digitalSignature: true,
        nonRepudiation: true,
        keyEncipherment: true,
        dataEncipherment: true
      }
    ])

    cert.sign(privateKey, forge.md.sha256.create())

    const keyAliasHash = CryptoJS.SHA1(alias).toString()
    const localKeyIdBytes = forge.util.hexToBytes(keyAliasHash)

    const p12Asn1 = forge.pkcs12.toPkcs12Asn1(
      privateKey,
      [cert],
      password,
      {
        algorithm: '3des',
        friendlyName: alias,
        localKeyId: localKeyIdBytes,
        generateLocalKeyId: true
      }
    )

    const p12Der = forge.asn1.toDer(p12Asn1).getBytes()
    const p12Buffer = new Uint8Array(p12Der.length)
    for (let i = 0; i < p12Der.length; i++) {
      p12Buffer[i] = p12Der.charCodeAt(i)
    }

    const certDer = forge.pki.certificateToAsn1(cert)
    const certAsn1 = forge.asn1.toDer(certDer).getBytes()
    const certBuffer = new Uint8Array(certAsn1.length)
    for (let i = 0; i < certAsn1.length; i++) {
      certBuffer[i] = certAsn1.charCodeAt(i)
    }

    const md5Hash = CryptoJS.MD5(CryptoJS.lib.WordArray.create(certBuffer))
    const sha1Hash = CryptoJS.SHA1(CryptoJS.lib.WordArray.create(certBuffer))
    const sha256Hash = CryptoJS.SHA256(CryptoJS.lib.WordArray.create(certBuffer))

    const md5Formatted = formatHash(md5Hash.toString())
    const sha1Formatted = formatHash(sha1Hash.toString())
    const sha256Formatted = formatHash(sha256Hash.toString())

    const publicKeyModulus = publicKey.n.toString()

    saveHistory(pkgName, p12Buffer, alias, password, keyPassword, md5Formatted, sha1Formatted, sha256Formatted, publicKeyModulus)

    renderHistory('', pkgName)

    setTimeout(() => {
      const historyRows = document.querySelectorAll('.history-row.highlight')
      historyRows.forEach((row) => {
        row.scrollIntoView({ behavior: 'smooth', block: 'center' })
      })
    }, 200)

    successMessage.value = '签名文件生成成功！已保存到历史记录。'
  } catch (err) {
    console.error('生成失败:', err)
    errorMessage.value = '生成失败: ' + err.message
  } finally {
    loading.value = false
  }
}

function renderHistory(filter = '', highlightPackage = null) {
  nextTick(() => {
    if (!historyList.value) return
    const history = getHistory()
    let filteredHistory = history
    if (filter) {
      filteredHistory = history.filter(item =>
        item.packageName.toLowerCase().includes(filter.toLowerCase())
      )
    }
    if (filteredHistory.length === 0) {
      historyList.value.innerHTML = '<div class="empty-history">暂无历史记录</div>'
      return
    }
    filteredHistory.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
    historyList.value.innerHTML = ''
    
    // 创建卡片网格容器
    const gridContainer = document.createElement('div')
    gridContainer.className = 'history-grid'
    
    filteredHistory.forEach((item, index) => {
      const date = new Date(item.timestamp).toLocaleString('zh-CN')
      const escapedPackageName = escapeHtml(item.packageName)
      const escapedAlias = escapeHtml(item.alias || item.keyAlias || 'N/A')
      const escapedMd5 = escapeHtml(item.md5)
      const isHighlight = highlightPackage === item.packageName

      // 卡片容器
      const card = document.createElement('div')
      card.className = `history-card ${isHighlight ? 'highlight' : ''}`
      
      // 卡片头部
      const cardHeader = document.createElement('div')
      cardHeader.className = 'card-header'
      cardHeader.innerHTML = `
        <div class="card-icon">🔑</div>
        <div class="card-title">${escapedPackageName}</div>
      `
      
      // 卡片内容
      const cardBody = document.createElement('div')
      cardBody.className = 'card-body'
      cardBody.innerHTML = `
        <div class="card-info-row">
          <span class="card-label">别名</span>
          <span class="card-value">${escapedAlias}</span>
        </div>
        <div class="card-info-row">
          <span class="card-label">MD5</span>
          <span class="card-value mono">${escapedMd5.substring(0, 20)}...</span>
        </div>
        <div class="card-info-row">
          <span class="card-label">创建时间</span>
          <span class="card-value">${date}</span>
        </div>
      `
      
      // 卡片底部操作按钮
      const cardFooter = document.createElement('div')
      cardFooter.className = 'card-footer'
      
      const viewBtn = document.createElement('button')
      viewBtn.className = 'card-btn card-btn--primary'
      viewBtn.innerHTML = '<span class="btn-icon">👁️</span><span>详情</span>'
      viewBtn.onclick = () => openDetailModal(item)
      
      const downloadBtn = document.createElement('button')
      downloadBtn.className = 'card-btn card-btn--success'
      downloadBtn.innerHTML = '<span class="btn-icon">📥</span><span>下载</span>'
      downloadBtn.onclick = () => downloadFromHistory(item.packageName)
      
      const deleteBtn = document.createElement('button')
      deleteBtn.className = 'card-btn card-btn--danger'
      deleteBtn.innerHTML = '<span class="btn-icon">🗑️</span><span>删除</span>'
      deleteBtn.onclick = () => deleteFromHistory(item.packageName)
      
      cardFooter.appendChild(viewBtn)
      cardFooter.appendChild(downloadBtn)
      cardFooter.appendChild(deleteBtn)
      
      card.appendChild(cardHeader)
      card.appendChild(cardBody)
      card.appendChild(cardFooter)
      gridContainer.appendChild(card)
    })
    
    historyList.value.appendChild(gridContainer)
  })
}

function openDetailModal(item) {
  selectedItem.value = item
  showDetailModal.value = true
  document.body.style.overflow = 'hidden'
}

function closeDetailModal() {
  showDetailModal.value = false
  selectedItem.value = null
  document.body.style.overflow = ''
}

function copyToClipboard(text) {
  if (!text) return
  navigator.clipboard.writeText(text).then(() => {
    showSuccess('已复制到剪贴板')
  }).catch(err => {
    console.error('复制失败:', err)
  })
}

function copyHash(hash, style) {
  if (!hash) return
  const formatted = formatHashFromString(hash, style)
  copyToClipboard(formatted)
}

function formatHashFromString(hashString, style) {
  if (!hashString) return ''
  const cleanHash = hashString.replace(/[\s:]/g, '').toUpperCase()
  const separator = style === 'colon' ? ':' : ' '
  return cleanHash.match(/.{1,2}/g).join(separator)
}

function formatHashForDisplay(hashString, style = 'space') {
  if (!hashString) return '-'
  return formatHashFromString(hashString, style)
}

function handleDeleteFromModal() {
  if (!selectedItem.value) return
  if (confirm(`确定要删除包名 "${selectedItem.value.packageName}" 的记录吗？此操作不可恢复。`)) {
    deleteFromHistory(selectedItem.value.packageName)
    closeDetailModal()
  }
}


function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

function downloadFromHistory(packageName) {
  const history = getHistory()
  const item = history.find(h => h.packageName === packageName)
  if (!item) {
    errorMessage.value = '未找到该包名的记录'
    return
  }
  const keystoreData = new Uint8Array(item.keystoreData)
  const blob = new Blob([keystoreData], { type: 'application/x-pkcs12' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = packageName + '.jks'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

function deleteFromHistory(packageName) {
  if (!confirm(`确定要删除包名 "${packageName}" 的记录吗？\n\n此操作将永久删除该签名文件的所有信息，包括：\n- 签名文件数据\n- 密钥别名和密码\n- 指纹信息\n\n此操作不可恢复！`)) {
    return
  }
  const history = getHistory()
  const filtered = history.filter(item => item.packageName !== packageName)
  localStorage.setItem(STORAGE_KEY, JSON.stringify(filtered))
  renderHistory(searchQuery.value)
  successMessage.value = `已成功删除包名 "${packageName}" 的记录`
}

async function exportAllToProject() {
  try {
    const history = getHistory()
    if (history.length === 0) {
      errorMessage.value = '没有历史记录可导出'
      return
    }
    loading.value = true
    const zip = new JSZip()
    const keystoresFolder = zip.folder('keystores')
    history.forEach(item => {
      if (item.keystoreData && item.keystoreData.length > 0) {
        const keystoreData = new Uint8Array(item.keystoreData)
        const fileName = item.packageName + '.jks'
        keystoresFolder.file(fileName, keystoreData)
      }
    })
    const exportData = history.map(item => ({
      packageName: item.packageName,
      keyAlias: item.keyAlias || item.alias,
      storePassword: item.storePassword || item.password,
      keyPassword: item.keyPassword || item.password,
      alias: item.keyAlias || item.alias,
      password: item.storePassword || item.password,
      md5: item.md5,
      sha1: item.sha1,
      sha256: item.sha256,
      publicKey: item.publicKey,
      timestamp: item.timestamp,
      keystoreFile: `keystores/${item.packageName}.jks`
    }))
    const dataStr = JSON.stringify(exportData, null, 2)
    zip.file('keystore_history.json', dataStr)
    const readmeContent = `# Keystore 历史记录\n\n此目录包含所有生成的签名文件和历史记录。\n\n## 文件说明\n\n- \`keystores/\`: 包含所有 .jks 签名文件\n- \`keystore_history.json\`: 包含所有签名文件的元数据信息\n\n## 使用说明\n\n1. 将整个目录解压到项目根目录\n2. 在 Android 项目中使用这些签名文件进行应用签名\n3. 签名信息（别名、密码等）请查看 \`keystore_history.json\`\n\n## 格式说明\n\n- **.keystore 和 .jks 的区别：** 两者都是 Java KeyStore 格式，.jks 是原始格式名称，.keystore 是别名。在 Android 开发中可以互换使用。本工具生成的是 PKCS#12 格式（兼容 .keystore/.jks），默认生成 .jks 文件。\n\n## 导入历史记录\n\n在工具中点击"导入历史"按钮，选择 \`keystore_history.json\` 文件即可恢复历史记录。\n\n---\n生成时间: ${new Date().toLocaleString('zh-CN')}\n`
    zip.file('README.md', readmeContent)
    const blob = await zip.generateAsync({ type: 'blob' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `keystore_project_${new Date().toISOString().split('T')[0]}.zip`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    loading.value = false
    successMessage.value = `已导出 ${history.length} 个签名文件到 ZIP 包！解压后放到项目根目录即可。`
  } catch (err) {
    console.error('导出失败:', err)
    errorMessage.value = '导出失败: ' + err.message
    loading.value = false
  }
}

async function exportHistoryToFile() {
  try {
    const history = getHistory()
    if (history.length === 0) {
      errorMessage.value = '没有历史记录可导出'
      return
    }
    const exportData = history.map(item => ({
      packageName: item.packageName,
      keyAlias: item.keyAlias || item.alias,
      storePassword: item.storePassword || item.password,
      keyPassword: item.keyPassword || item.password,
      alias: item.keyAlias || item.alias,
      password: item.storePassword || item.password,
      md5: item.md5,
      sha1: item.sha1,
      sha256: item.sha256,
      publicKey: item.publicKey,
      timestamp: item.timestamp
    }))
    const dataStr = JSON.stringify(exportData, null, 2)
    const blob = new Blob([dataStr], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `keystore_history_${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    successMessage.value = '历史记录已导出成功！'
  } catch (err) {
    console.error('导出失败:', err)
    errorMessage.value = '导出失败: ' + err.message
  }
}

function importHistoryFromFile() {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = '.json,.zip'
  input.onchange = async function (e) {
    const file = e.target.files[0]
    if (!file) return
    try {
      if (file.name.endsWith('.zip')) {
        loading.value = true
        const arrayBuffer = await file.arrayBuffer()
        const zip = await JSZip.loadAsync(arrayBuffer)
        const historyFile = zip.file('keystore_history.json')
        if (!historyFile) {
          errorMessage.value = 'ZIP 文件中未找到 keystore_history.json'
          loading.value = false
          return
        }
        const historyContent = await historyFile.async('string')
        const importData = JSON.parse(historyContent)
        const currentHistory = getHistory()
        const mergedHistory = [...currentHistory]
        let importedCount = 0
        for (const importItem of importData) {
          let keystoreData = []
          if (importItem.keystoreFile) {
            const keystoreFile = zip.file(importItem.keystoreFile)
            if (keystoreFile) {
              const keystoreArrayBuffer = await keystoreFile.async('arraybuffer')
              keystoreData = Array.from(new Uint8Array(keystoreArrayBuffer))
            }
          }
          const existingIndex = mergedHistory.findIndex(item => item.packageName === importItem.packageName)
          if (existingIndex >= 0) {
            if (confirm(`包名 "${importItem.packageName}" 已存在，是否覆盖？`)) {
              mergedHistory[existingIndex] = {
                ...importItem,
                keyAlias: importItem.keyAlias || importItem.alias,
                storePassword: importItem.storePassword || importItem.password,
                keyPassword: importItem.keyPassword || importItem.password,
                keystoreData: keystoreData.length > 0 ? keystoreData : mergedHistory[existingIndex].keystoreData
              }
              importedCount++
            }
          } else {
            mergedHistory.push({
              ...importItem,
              keyAlias: importItem.keyAlias || importItem.alias,
              storePassword: importItem.storePassword || importItem.password,
              keyPassword: importItem.keyPassword || importItem.password,
              keystoreData: keystoreData
            })
            importedCount++
          }
        }
        localStorage.setItem(STORAGE_KEY, JSON.stringify(mergedHistory))
        renderHistory()
        loading.value = false
        successMessage.value = `历史记录导入成功！共导入 ${importedCount} 条记录。`
      } else {
        const reader = new FileReader()
        reader.onload = function (e) {
          try {
            const importData = JSON.parse(e.target.result)
            const currentHistory = getHistory()
            const mergedHistory = [...currentHistory]
            importData.forEach(importItem => {
              const existingIndex = mergedHistory.findIndex(item => item.packageName === importItem.packageName)
              if (existingIndex >= 0) {
                if (confirm(`包名 "${importItem.packageName}" 已存在，是否覆盖？`)) {
                  mergedHistory[existingIndex] = {
                    ...importItem,
                    keyAlias: importItem.keyAlias || importItem.alias,
                    storePassword: importItem.storePassword || importItem.password,
                    keyPassword: importItem.keyPassword || importItem.password,
                    keystoreData: mergedHistory[existingIndex].keystoreData
                  }
                }
              } else {
                if (confirm(`包名 "${importItem.packageName}" 的签名文件数据缺失，将只保存元数据信息。是否继续？`)) {
                  mergedHistory.push({
                    ...importItem,
                    keyAlias: importItem.keyAlias || importItem.alias,
                    storePassword: importItem.storePassword || importItem.password,
                    keyPassword: importItem.keyPassword || importItem.password,
                    keystoreData: []
                  })
                }
              }
            })
            localStorage.setItem(STORAGE_KEY, JSON.stringify(mergedHistory))
            renderHistory()
            successMessage.value = '历史记录导入成功！'
          } catch (err) {
            console.error('导入失败:', err)
            errorMessage.value = '导入失败: ' + err.message
          }
        }
        reader.readAsText(file)
      }
    } catch (err) {
      console.error('导入失败:', err)
      errorMessage.value = '导入失败: ' + err.message
      loading.value = false
    }
  }
  input.click()
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

.form-group input {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  transition: border-color 0.3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.form-group small {
  display: block;
  color: var(--color-text-secondary);
  margin-top: var(--spacing-xs);
  font-size: var(--font-size-small);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: var(--spacing-sm) var(--spacing-xl);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: transform 0.2s;
  width: 100%;
  margin-bottom: var(--spacing-lg);
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.loading {
  text-align: center;
  padding: 20px;
  display: none;
}

.loading.show {
  display: block;
}

.spinner {
  border: 4px solid var(--color-border);
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-error);
  color: var(--color-error);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-top: 20px;
  display: none;
}

.error.show {
  display: block;
}

.success {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-success);
  color: var(--color-success);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-top: 20px;
  display: none;
}

.success.show {
  display: block;
}

.info-box {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-info);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-bottom: 20px;
  font-size: 13px;
  color: var(--color-text);
}

.history-section {
  margin-top: 30px;
}

.history-list-container {
  min-height: 100px;
  overflow: hidden;
}

/* 卡片水平滚动布局 - 使用 :deep() 穿透到动态创建的元素 */
:deep(.history-grid) {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  overflow-y: hidden;
  padding: 8px 4px 16px 4px;
  scroll-behavior: smooth;
  -webkit-overflow-scrolling: touch;
}

/* 自定义滚动条 */
:deep(.history-grid::-webkit-scrollbar) {
  height: 8px;
}

:deep(.history-grid::-webkit-scrollbar-track) {
  background: var(--color-surface-alt);
  border-radius: 4px;
}

:deep(.history-grid::-webkit-scrollbar-thumb) {
  background: var(--color-primary);
  border-radius: 4px;
}

:deep(.history-grid::-webkit-scrollbar-thumb:hover) {
  background: var(--color-primary-dark);
}

/* 卡片样式 */
:deep(.history-card) {
  flex: 0 0 300px;
  min-width: 300px;
  max-width: 300px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  transition: box-shadow 0.2s ease, border-color 0.2s ease;
}

:deep(.history-card:hover) {
  border-color: var(--color-primary);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

:deep(.history-card.highlight) {
  border-color: var(--color-success);
  box-shadow: 0 4px 20px rgba(16, 185, 129, 0.15);
}

/* 卡片头部 */
:deep(.card-header) {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: #fff;
}

:deep(.card-icon) {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

:deep(.card-title) {
  flex: 1;
  font-size: 15px;
  font-weight: 600;
  word-break: break-all;
  line-height: 1.4;
}

/* 卡片内容 */
:deep(.card-body) {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
  background: var(--color-surface);
}

:deep(.card-info-row) {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

:deep(.card-label) {
  font-size: 13px;
  color: var(--color-text-secondary);
  flex-shrink: 0;
  min-width: 60px;
}

:deep(.card-value) {
  font-size: 13px;
  color: var(--color-text);
  text-align: right;
  word-break: break-all;
}

:deep(.card-value.mono) {
  font-family: 'SF Mono', 'Fira Code', 'Courier New', monospace;
  font-size: 12px;
}

/* 卡片底部 */
:deep(.card-footer) {
  display: flex;
  gap: 8px;
  padding: 12px 16px;
  background: var(--color-surface-alt);
  border-top: 1px solid var(--color-border);
}

/* 卡片按钮 - 统一大按钮样式 */
:deep(.card-btn) {
  flex: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 14px;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
  color: #ffffff !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

:deep(.card-btn *) {
  color: #ffffff !important;
}

:deep(.card-btn .btn-icon) {
  font-size: 14px;
  color: #ffffff !important;
}

:deep(.card-btn span) {
  color: #ffffff !important;
}

:deep(.card-btn--primary) {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

:deep(.card-btn--primary:hover) {
  filter: brightness(1.08);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

:deep(.card-btn--success) {
  background: linear-gradient(135deg, var(--color-success) 0%, #059669 100%);
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

:deep(.card-btn--success:hover) {
  filter: brightness(1.08);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

:deep(.card-btn--danger) {
  background: linear-gradient(135deg, var(--color-error) 0%, #dc2626 100%);
  box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
}

:deep(.card-btn--danger:hover) {
  filter: brightness(1.08);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
}

/* 高亮卡片的特殊头部样式 */
:deep(.history-card.highlight .card-header) {
  background: linear-gradient(135deg, var(--color-success) 0%, #059669 100%);
}

/* 响应式 */
@media (max-width: 640px) {
  :deep(.history-card) {
    flex: 0 0 280px;
    min-width: 280px;
    max-width: 280px;
  }
  
  :deep(.card-footer) {
    flex-wrap: wrap;
  }
  
  :deep(.card-btn) {
    flex: 1 1 calc(50% - 4px);
  }
  
  :deep(.card-btn:last-child) {
    flex: 1 1 100%;
  }
}

/* 弹窗样式 */
.detail-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  animation: fadeIn 0.2s ease-out;
  padding: 20px;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.detail-modal {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.detail-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid var(--color-border);
  background: linear-gradient(135deg, var(--color-surface) 0%, var(--color-surface-alt) 100%);
}

.detail-modal-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: var(--font-weight-bold);
  color: var(--color-primary);
}

.modal-header-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.modal-close-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: var(--color-surface-alt);
  border-radius: 50%;
  font-size: 24px;
  line-height: 1;
  cursor: pointer;
  color: var(--color-text);
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close-btn:hover {
  background: var(--color-error);
  color: #fff;
  transform: rotate(90deg);
}

/* 紧凑弹窗内容样式 */
.detail-modal.compact {
  max-width: 720px;
}

.detail-modal-content.compact {
  padding: 16px 20px;
  overflow-y: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 基础信息区 */
.info-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  background: var(--color-surface-alt);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
}

.info-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 0;
  border-bottom: 1px dashed var(--color-border);
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: var(--font-weight-semibold);
  color: var(--color-primary);
  font-size: 13px;
  min-width: 90px;
  flex-shrink: 0;
}

.info-value {
  flex: 1;
  color: var(--color-text);
  font-size: 13px;
  word-break: break-all;
}

.info-value.mono {
  font-family: 'SF Mono', 'Fira Code', 'Courier New', monospace;
}

/* 指纹区 */
.hash-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.hash-group {
  padding: 12px;
  background: var(--color-surface-alt);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
}

.hash-title {
  font-weight: var(--font-weight-bold);
  color: var(--color-primary);
  font-size: 13px;
  margin-bottom: 8px;
  padding-bottom: 6px;
  border-bottom: 1px solid var(--color-border);
}

.hash-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 0;
}

.hash-style-label {
  font-size: 12px;
  color: var(--color-text-secondary);
  min-width: 45px;
  flex-shrink: 0;
}

.hash-code {
  flex: 1;
  font-family: 'SF Mono', 'Fira Code', 'Courier New', monospace;
  font-size: 11px;
  color: var(--color-text);
  background: var(--color-surface);
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  word-break: break-all;
  line-height: 1.4;
}

.hash-code.small {
  font-size: 10px;
}

/* 公钥区 */
.pubkey-section {
  padding: 12px;
  background: var(--color-surface-alt);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
}

.pubkey-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  padding-bottom: 6px;
  border-bottom: 1px solid var(--color-border);
}

.pubkey-title {
  font-weight: var(--font-weight-bold);
  color: var(--color-primary);
  font-size: 13px;
}

.pubkey-value {
  display: block;
  font-family: 'SF Mono', 'Fira Code', 'Courier New', monospace;
  font-size: 10px;
  color: var(--color-text);
  background: var(--color-surface);
  padding: 8px;
  border-radius: var(--radius-sm);
  word-break: break-all;
  line-height: 1.5;
  max-height: 100px;
  overflow-y: auto;
}

/* 弹窗响应式 */
@media (max-width: 768px) {
  .detail-modal.compact {
    max-width: 100%;
    margin: 10px;
    max-height: calc(100vh - 20px);
  }
  
  .detail-modal-header {
    padding: 12px 16px;
  }
  
  .detail-modal-header h3 {
    font-size: 16px;
  }
  
  .detail-modal-content.compact {
    padding: 12px;
    gap: 12px;
  }
  
  .info-row {
    flex-wrap: wrap;
  }
  
  .info-label {
    min-width: 80px;
  }
  
  .hash-row {
    flex-wrap: wrap;
  }
  
  .hash-code {
    width: 100%;
    order: 1;
    margin-top: 4px;
  }
  
  .modal-header-actions .app-btn {
    padding: 6px 10px;
    font-size: 12px;
  }
}

.search-box {
  margin-bottom: 20px;
}

.search-box input {
  width: 100%;
  padding: 12px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  background: var(--color-surface);
  color: var(--color-text);
}

.empty-history {
  text-align: center;
  padding: var(--spacing-xl);
  color: var(--color-text-secondary);
}

.history-detail-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.detail-row {
  display: flex;
  flex-direction: column;
  padding: 16px;
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-left: 4px solid var(--color-primary);
  border-radius: var(--radius-md);
  transition: all 0.3s ease;
}

.detail-row:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border-left-color: var(--color-primary-dark);
}

.detail-label {
  font-weight: var(--font-weight-semibold);
  color: var(--color-primary);
  margin-bottom: 8px;
  font-size: 13px;
}

.detail-value {
  color: var(--color-text);
  word-break: break-all;
  font-family: 'SF Mono', 'Fira Code', 'Courier New', monospace;
  font-size: 13px;
  background: var(--color-surface);
  padding: 12px 16px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  max-height: 200px;
  overflow-y: auto;
  white-space: pre-line;
  line-height: 1.5;
}

.detail-actions {
  margin-top: 8px;
}

.copy-btn {
  position: relative;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%) !important;
  color: #ffffff !important;
  border: none;
  padding: 8px 16px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  white-space: nowrap;
  flex-shrink: 0;
  overflow: hidden;
  box-shadow: 0 2px 8px var(--color-shadow-primary);
  min-width: 90px;
  text-align: center;
}

.copy-btn * {
  color: #ffffff !important;
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
  animation: btn-shine 0.8s ease-out 0.3s forwards;
}

.copy-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 14px var(--color-shadow-primary);
}

.copy-btn:active {
  transform: translateY(0) scale(0.98);
}

.copy-btn.copied {
  background: linear-gradient(135deg, var(--color-success) 0%, #059669 100%);
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.4);
}

.download-btn {
  position: relative;
  background: linear-gradient(135deg, var(--color-success) 0%, #059669 100%) !important;
  color: #ffffff !important;
  border: none;
  padding: 12px 24px;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  margin-top: 15px;
  width: 100%;
  overflow: hidden;
  box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4);
  text-align: center;
}

.download-btn * {
  color: #ffffff !important;
}

/* 入场光效 */
.download-btn::before {
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
  animation: btn-shine 0.8s ease-out 0.4s forwards;
}

.download-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.5);
}

.download-btn:active {
  transform: translateY(0) scale(0.98);
}

/* 赛博朋克主题特效 */
:global(body[data-theme="cyberpunk"]) .copy-btn,
:global(body[data-theme="cyberpunk"]) .history-btn {
  box-shadow: 0 0 15px var(--color-shadow-primary);
}

:global(body[data-theme="cyberpunk"]) .copy-btn:hover,
:global(body[data-theme="cyberpunk"]) .history-btn:hover {
  box-shadow: 0 0 25px var(--color-shadow-primary);
}
</style>
