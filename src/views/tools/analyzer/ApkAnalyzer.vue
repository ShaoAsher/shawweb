<template>
  <ToolLayout title="📦 APK 信息提取工具" description="解析 APK，读取包名与证书指纹等信息，支持拖拽上传与结果复制">
    <div 
      class="upload-area" 
      :class="{ dragover: isDragging }"
      @click="fileInput?.click()"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleDrop"
    >
      <div class="upload-icon">📦</div>
      <div class="upload-text">点击选择文件或拖拽文件到此处</div>
      <div style="font-size: var(--font-size-small); color: var(--color-text-secondary); margin-top: 10px;">
        支持格式：APK (.apk) | Keystore (.keystore) | JKS (.jks)
      </div>
      <input ref="fileInput" type="file" accept=".apk,.keystore,.jks" @change="handleFileSelect" class="file-input">
    </div>

    <div v-if="loading" class="loading show">
      <div class="spinner"></div>
      <div>正在解析 APK 文件...</div>
    </div>

    <div v-if="errorMessage" class="error show">
      {{ errorMessage }}
    </div>

    <div v-if="showResults" class="results show">
      <div class="result-item">
        <div class="result-label">公钥（大整数格式）</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.publicKey || '-' }}</div>
          <button class="copy-btn" @click="copyToClipboard('publicKey')">复制</button>
        </div>
      </div>
      <div class="result-item">
        <div class="result-label">MD5 指纹</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.md5 || '-' }}</div>
          <div style="display: flex; gap: 5px;">
            <button class="copy-btn" @click="copyHash('md5', 'space')">复制空格</button>
            <button class="copy-btn" @click="copyHash('md5', 'colon')">复制冒号</button>
          </div>
        </div>
      </div>
      <div class="result-item">
        <div class="result-label">SHA1 指纹</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.sha1 || '-' }}</div>
          <div style="display: flex; gap: 5px;">
            <button class="copy-btn" @click="copyHash('sha1', 'space')">复制空格</button>
            <button class="copy-btn" @click="copyHash('sha1', 'colon')">复制冒号</button>
          </div>
        </div>
      </div>
      <div class="result-item">
        <div class="result-label">SHA256 指纹</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.sha256 || '-' }}</div>
          <div style="display: flex; gap: 5px;">
            <button class="copy-btn" @click="copyHash('sha256', 'space')">复制空格</button>
            <button class="copy-btn" @click="copyHash('sha256', 'colon')">复制冒号</button>
          </div>
        </div>
      </div>
      <div v-if="results.alias" class="result-item">
        <div class="result-label">密钥别名 (keyAlias)</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.alias }}</div>
          <button class="copy-btn" @click="copyToClipboard('alias')">复制</button>
        </div>
      </div>
      <div v-if="results.storePassword !== undefined" class="result-item">
        <div class="result-label">密钥库密码 (storePassword)</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.storePassword || '未找到（无法从文件中提取，请查看历史记录）' }}</div>
          <button v-if="results.storePassword" class="copy-btn" @click="copyToClipboard('storePassword')">复制</button>
        </div>
      </div>
      <div v-if="results.keyPassword !== undefined" class="result-item">
        <div class="result-label">密钥密码 (keyPassword)</div>
        <div class="result-value-wrapper">
          <div class="result-value">{{ results.keyPassword || '未找到（无法从文件中提取，请查看历史记录）' }}</div>
          <button v-if="results.keyPassword" class="copy-btn" @click="copyToClipboard('keyPassword')">复制</button>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { onMounted, ref } from 'vue'
import { loadScript } from '@/utils/cdn-loader.js'

const fileInput = ref(null)
const isDragging = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const showResults = ref(false)
const results = ref({
  publicKey: '',
  md5: '',
  sha1: '',
  sha256: '',
  alias: '',
  storePassword: '',
  keyPassword: ''
})
let lastHashData = null
let JSZip = null
let CryptoJS = null
let forge = null

onMounted(async () => {
  try {
    await Promise.all([
      loadScript('https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js'),
      loadScript('https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js'),
      loadScript('https://cdnjs.cloudflare.com/ajax/libs/forge/1.3.1/forge.min.js')
    ])
    JSZip = window.JSZip
    CryptoJS = window.CryptoJS
    forge = window.forge
  } catch (err) {
    console.error('Failed to load libraries:', err)
    errorMessage.value = '加载必要的库失败'
  }
})

function handleFileSelect(e) {
  const file = e.target.files[0]
  if (file) handleFile(file)
}

function handleDrop(e) {
  isDragging.value = false
  const files = e.dataTransfer.files
  if (files.length > 0) handleFile(files[0])
}

async function handleFile(file) {
  const fileName = file.name.toLowerCase()
  const isAPK = fileName.endsWith('.apk')
  const isKeystore = fileName.endsWith('.keystore') || fileName.endsWith('.jks')

  if (!isAPK && !isKeystore) {
    errorMessage.value = '请选择 APK、Keystore 或 JKS 文件'
    return
  }

  loading.value = true
  showResults.value = false
  errorMessage.value = ''

  try {
    const arrayBuffer = await file.arrayBuffer()
    if (isAPK) {
      await analyzeAPK(arrayBuffer)
    } else if (isKeystore) {
      await analyzeKeystore(arrayBuffer, file.name)
    }
  } catch (err) {
    console.error('解析错误:', err)
    errorMessage.value = '解析失败: ' + err.message
  } finally {
    loading.value = false
  }
}

async function analyzeAPK(arrayBuffer) {
  try {
    const zip = await JSZip.loadAsync(arrayBuffer)
    const signatureInfo = await extractSignatureInfo(zip, arrayBuffer)
    const md5Formatted = lastHashData ? lastHashData.md5 : (signatureInfo.md5 ? signatureInfo.md5.replace(/[\s:]/g, '').toUpperCase() : null)
    const matchedInfo = signatureInfo.publicKey ? findMatchingHistory(signatureInfo.publicKey, md5Formatted) : null

    results.value = {
      publicKey: signatureInfo.publicKey || '-',
      md5: signatureInfo.md5 || '-',
      sha1: signatureInfo.sha1 || '-',
      sha256: signatureInfo.sha256 || '-',
      alias: matchedInfo ? (matchedInfo.keyAlias || matchedInfo.alias) : (signatureInfo.alias || null),
      storePassword: matchedInfo ? (matchedInfo.storePassword || matchedInfo.password || '未找到') : '未找到（无法从 APK 中提取，请查看历史记录）',
      keyPassword: matchedInfo ? (matchedInfo.keyPassword || '未找到') : '未找到（无法从 APK 中提取，请查看历史记录）'
    }

    showResults.value = true

    if (!signatureInfo.publicKey || !signatureInfo.md5) {
      errorMessage.value = '警告: 部分签名信息提取失败，可能是使用了新的签名方案（v2/v3）'
    }
  } catch (err) {
    console.error('APK 解析错误:', err)
    throw new Error('APK 解析错误: ' + err.message)
  }
}

async function extractSignatureInfo(zip, arrayBuffer) {
  const info = {
    publicKey: null,
    md5: null,
    sha1: null,
    sha256: null
  }

  try {
    let certData = null
    const metaInfFiles = Object.keys(zip.files).filter(f => f.startsWith('META-INF/'))
    for (const filename of metaInfFiles) {
      if (filename.endsWith('.RSA') || filename.endsWith('.DSA') || filename.endsWith('.EC')) {
        const file = zip.file(filename)
        if (file) {
          certData = await file.async('uint8array')
          break
        }
      }
    }

    if (!certData) {
      certData = await extractFromSignatureBlock(arrayBuffer)
    }

    if (certData && certData.length > 0) {
      const md5Hash = await calculateHash(certData, 'MD5')
      const sha1Hash = await calculateHash(certData, 'SHA-1')
      const sha256Hash = await calculateHash(certData, 'SHA-256')

      lastHashData = {
        md5: Array.from(md5Hash).map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase(),
        sha1: Array.from(sha1Hash).map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase(),
        sha256: Array.from(sha256Hash).map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase()
      }

      info.md5 = formatHash(md5Hash)
      info.sha1 = formatHash(sha1Hash)
      info.sha256 = formatHash(sha256Hash)

      info.publicKey = await extractPublicKey(certData)
    } else {
      const md5Hash = await calculateHash(new Uint8Array(arrayBuffer), 'MD5')
      const sha1Hash = await calculateHash(new Uint8Array(arrayBuffer), 'SHA-1')
      const sha256Hash = await calculateHash(new Uint8Array(arrayBuffer), 'SHA-256')
      lastHashData = {
        md5: Array.from(md5Hash).map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase(),
        sha1: Array.from(sha1Hash).map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase(),
        sha256: Array.from(sha256Hash).map(b => b.toString(16).padStart(2, '0')).join('').toUpperCase()
      }
      info.md5 = formatHash(md5Hash) + '\n(整个 APK)'
      info.sha1 = formatHash(sha1Hash) + '\n(整个 APK)'
      info.sha256 = formatHash(sha256Hash) + '\n(整个 APK)'
    }
  } catch (err) {
    console.error('提取签名信息失败:', err)
    throw err
  }

  return info
}

async function extractFromSignatureBlock(arrayBuffer) {
  const view = new DataView(arrayBuffer)
  const length = arrayBuffer.byteLength
  const magicBytes = [0x41, 0x50, 0x4B, 0x20, 0x53, 0x69, 0x67, 0x20, 0x42, 0x6C, 0x6F, 0x63, 0x6B, 0x20, 0x34, 0x32]
  const searchRange = Math.min(65536, length)
  for (let i = length - searchRange; i < length - 16; i++) {
    let match = true
    for (let j = 0; j < magicBytes.length; j++) {
      if (view.getUint8(i + j) !== magicBytes[j]) {
        match = false
        break
      }
    }
    if (match) {
      try {
        const blockSizeOffset = i - 8
        if (blockSizeOffset >= 0) {
          const blockSize = Number(view.getBigUint64(blockSizeOffset, true))
          const blockStart = blockSizeOffset - Number(blockSize)
          if (blockStart >= 0 && blockStart < length) {
            const blockData = new Uint8Array(arrayBuffer, blockStart, Number(blockSize))
            for (let k = 0; k < blockData.length - 100; k++) {
              if (blockData[k] === 0x30 && blockData[k + 1] === 0x82) {
                const certLength = (blockData[k + 2] << 8) | blockData[k + 3]
                if (certLength > 500 && certLength < 5000 && k + 4 + certLength <= blockData.length) {
                  return blockData.slice(k, k + 4 + certLength)
                }
              }
            }
          }
        }
      } catch (err) {
        console.warn('解析签名块失败:', err)
      }
      return null
    }
  }
  return null
}

async function calculateHash(data, algorithm) {
  if (algorithm === 'MD5') {
    const wordArray = CryptoJS.lib.WordArray.create(data)
    const hash = CryptoJS.MD5(wordArray)
    const words = hash.words
    const sigBytes = hash.sigBytes
    const result = new Uint8Array(sigBytes)
    for (let i = 0; i < sigBytes; i++) {
      const byte = (words[i >>> 2] >>> (24 - (i % 4) * 8)) & 0xff
      result[i] = byte
    }
    return result
  } else if (algorithm === 'SHA-1') {
    const wordArray = CryptoJS.lib.WordArray.create(data)
    const hash = CryptoJS.SHA1(wordArray)
    const words = hash.words
    const sigBytes = hash.sigBytes
    const result = new Uint8Array(sigBytes)
    for (let i = 0; i < sigBytes; i++) {
      const byte = (words[i >>> 2] >>> (24 - (i % 4) * 8)) & 0xff
      result[i] = byte
    }
    return result
  } else {
    const hashBuffer = await crypto.subtle.digest(algorithm, data)
    return new Uint8Array(hashBuffer)
  }
}

function formatHash(hashArray, style = 'both') {
  let hashString = ''
  if (typeof hashArray === 'string') {
    hashString = hashArray.replace(/[\s:]/g, '').toUpperCase()
  } else {
    hashString = Array.from(hashArray)
      .map(b => b.toString(16).padStart(2, '0').toUpperCase())
      .join('')
  }
  const spaceFormat = hashString.match(/.{1,2}/g).join(' ')
  const colonFormat = hashString.match(/.{1,2}/g).join(':')
  if (style === 'space') {
    return spaceFormat
  } else if (style === 'colon') {
    return colonFormat
  } else {
    return `空格样式: ${spaceFormat}\n冒号样式: ${colonFormat}`
  }
}

function findMatchingHistory(publicKey, md5Hash) {
  try {
    const STORAGE_KEY = 'keystore_history'
    const stored = localStorage.getItem(STORAGE_KEY)
    if (!stored) return null
    const history = JSON.parse(stored)
    if (publicKey) {
      const matchByPublicKey = history.find(item => {
        const itemPublicKey = item.publicKey || ''
        return itemPublicKey.toString().replace(/\s+/g, '') === publicKey.toString().replace(/\s+/g, '')
      })
      if (matchByPublicKey) return matchByPublicKey
    }
    if (md5Hash) {
      const matchByMd5 = history.find(item => {
        const itemMd5 = (item.md5 || '').replace(/\s+/g, '').toUpperCase()
        const searchMd5 = md5Hash.replace(/\s+/g, '').toUpperCase()
        return itemMd5 === searchMd5
      })
      if (matchByMd5) return matchByMd5
    }
    return null
  } catch (err) {
    console.warn('查找历史记录失败:', err)
    return null
  }
}

async function extractPublicKey(certData) {
  return await parseRSAPublicKeyFallback(certData)
}

async function parseRSAPublicKeyFallback(certData) {
  const data = new Uint8Array(certData)
  let bestModulus = null
  let bestModulusSize = 0
  for (let i = 0; i < data.length - 10; i++) {
    if (data[i] === 0x02) {
      let length
      let offset = i + 1
      if (offset >= data.length) continue
      if ((data[offset] & 0x80) === 0) {
        length = data[offset]
        offset += 1
      } else {
        const lengthBytes = data[offset] & 0x7F
        if (lengthBytes === 0 || lengthBytes > 4 || offset + lengthBytes >= data.length) continue
        offset += 1
        length = 0
        for (let j = 0; j < lengthBytes; j++) {
          length = (length << 8) | data[offset + j]
        }
        offset += lengthBytes
      }
      if (length >= 128 && length <= 512 && offset + length <= data.length) {
        const modulusBytes = data.slice(offset, offset + length)
        let startIdx = 0
        while (startIdx < modulusBytes.length - 1 && modulusBytes[startIdx] === 0) {
          startIdx++
        }
        const actualModulusBytes = startIdx > 0 ? modulusBytes.slice(startIdx) : modulusBytes
        if (actualModulusBytes.length >= 128) {
          let modulusInt = BigInt(0)
          for (let j = 0; j < actualModulusBytes.length; j++) {
            modulusInt = modulusInt * BigInt(256) + BigInt(actualModulusBytes[j])
          }
          const modulusStr = modulusInt.toString()
          if (modulusStr.length > 200 && modulusInt > BigInt('1' + '0'.repeat(200))) {
            if (actualModulusBytes.length > bestModulusSize) {
              bestModulus = modulusInt.toString()
              bestModulusSize = actualModulusBytes.length
            }
          }
        }
      }
    }
  }
  return bestModulus || '无法提取公钥，请确保 APK 已正确签名'
}

async function analyzeKeystore(arrayBuffer, fileName) {
  try {
    const password = prompt('请输入 Keystore 密码（如果为空则尝试空密码）:')
    const inputPassword = password === null ? null : (password || '')
    const p12Der = new Uint8Array(arrayBuffer)
    const p12String = String.fromCharCode.apply(null, p12Der)
    try {
      const p12Asn1 = forge.asn1.fromDer(p12String)
      const p12 = forge.pkcs12.pkcs12FromAsn1(p12Asn1, inputPassword === null ? false : inputPassword)
      const bags = p12.getBags({ bagType: forge.pki.oids.certBag })
      if (!bags || bags[forge.pki.oids.certBag].length === 0) {
        throw new Error('未找到证书，请检查密码是否正确')
      }
      const cert = bags[forge.pki.oids.certBag][0].cert
      let alias = null
      try {
        const friendlyNames = p12.getBags({ bagType: forge.pki.oids.friendlyName })
        if (friendlyNames && friendlyNames[forge.pki.oids.friendlyName].length > 0) {
          alias = friendlyNames[forge.pki.oids.friendlyName][0].friendlyName
        }
      } catch (e) {
        console.warn('无法获取别名:', e)
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
      const publicKey = cert.publicKey
      let publicKeyModulus = null
      if (publicKey && publicKey.n) {
        publicKeyModulus = publicKey.n.toString()
      } else {
        publicKeyModulus = await extractPublicKey(certBuffer)
      }
      const md5HashStr = md5Hash.toString().replace(/[\s:]/g, '').toUpperCase()
      const sha1HashStr = sha1Hash.toString().replace(/[\s:]/g, '').toUpperCase()
      const sha256HashStr = sha256Hash.toString().replace(/[\s:]/g, '').toUpperCase()
      lastHashData = {
        md5: md5HashStr,
        sha1: sha1HashStr,
        sha256: sha256HashStr
      }
      const matchedInfo = findMatchingHistory(publicKeyModulus, md5HashStr)
      const finalStorePassword = inputPassword !== null ? inputPassword : (matchedInfo ? (matchedInfo.storePassword || matchedInfo.password) : null)
      const finalKeyPassword = inputPassword !== null ? inputPassword : (matchedInfo ? matchedInfo.keyPassword : null)
      results.value = {
        publicKey: publicKeyModulus || '无法提取公钥',
        md5: formatHash(md5HashStr),
        sha1: formatHash(sha1HashStr),
        sha256: formatHash(sha256HashStr),
        alias: matchedInfo ? (matchedInfo.keyAlias || matchedInfo.alias) : (alias || '未找到别名'),
        storePassword: finalStorePassword,
        keyPassword: finalKeyPassword
      }
      showResults.value = true
    } catch (err) {
      if (err.message.includes('密码') || err.message.includes('password') || err.message.includes('Mac verify')) {
        throw new Error('密码错误或文件格式不正确。请确认：\n1. 密码是否正确\n2. 文件是否为有效的 PKCS#12 格式（.keystore/.jks）')
      }
      throw err
    }
  } catch (err) {
    console.error('Keystore 解析错误:', err)
    throw new Error('Keystore 解析错误: ' + err.message)
  }
}

function copyToClipboard(field) {
  const value = results.value[field]
  if (value && value !== '-') {
    navigator.clipboard.writeText(value).then(() => {
      showCopySuccess()
    }).catch(err => {
      console.error('复制失败:', err)
    })
  }
}

function copyHash(field, style) {
  if (!lastHashData || !lastHashData[field]) return
  const value = formatHash(lastHashData[field], style)
  navigator.clipboard.writeText(value).then(() => {
    showCopySuccess()
  }).catch(err => {
    console.error('复制失败:', err)
  })
}

function showCopySuccess() {
  // 可以添加一个临时提示
}
</script>

<style scoped>
.upload-area {
  border: 3px dashed var(--color-primary);
  border-radius: var(--radius-md);
  padding: var(--spacing-xxl);
  text-align: center;
  background: var(--color-background-alt);
  transition: all 0.3s;
  cursor: pointer;
}

.upload-area:hover {
  background: var(--color-surface-alt);
  border-color: var(--color-primary-dark);
}

.upload-area.dragover {
  background: var(--color-hover);
  border-color: var(--color-primary);
}

.upload-icon {
  font-size: 48px;
  margin-bottom: var(--spacing-md);
}

.upload-text {
  font-size: var(--font-size-base);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
}

.file-input {
  display: none;
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

.results {
  margin-top: var(--spacing-xl);
  display: none;
}

.results.show {
  display: block;
}

.result-item {
  background: var(--color-background-alt);
  border-left: 4px solid var(--color-primary);
  padding: var(--spacing-md) var(--spacing-lg);
  margin-bottom: var(--spacing-md);
  border-radius: var(--radius-sm);
}

.result-label {
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 8px;
  font-size: var(--font-size-small);
}

.result-value-wrapper {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.result-value {
  color: var(--color-text);
  word-break: break-all;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  background: var(--color-surface);
  padding: 10px;
  border-radius: 4px;
  border: 1px solid var(--color-border);
  flex: 1;
  white-space: pre-line;
}

.copy-btn {
  position: relative;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: #fff !important;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  flex-shrink: 0;
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
