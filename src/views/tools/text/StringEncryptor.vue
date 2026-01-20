<template>
  <ToolLayout
    icon="🔐"
    title="字符串加解密工具"
    description="支持 Base64、URL、Hex、Unicode、摩斯密码等编码，以及 MD5、SHA、AES、凯撒密码等加解密。"
  >
    <div class="form-section">
      <h2>选择算法</h2>
      <div class="algorithm-tabs">
        <button
          v-for="(algo, key) in algorithms"
          :key="key"
          class="tab-btn"
          :class="{ active: currentAlgorithm === key }"
          @click="selectAlgorithm(key)"
        >
          {{ algo.name }}
        </button>
      </div>
    </div>

    <div class="form-section">
      <h2>加密参数</h2>
      <div class="controls-grid">
        <div v-if="algorithms[currentAlgorithm].needsKey" class="form-group">
          <label for="keyInput">密钥/参数</label>
          <input
            v-model="keyInput"
            type="text"
            id="keyInput"
            :placeholder="currentAlgorithm === 'caesar' ? '偏移量（如：3）' : '密钥'"
          />
        </div>

        <!-- AES 高级选项 -->
        <template v-if="currentAlgorithm === 'aes'">
          <div class="form-group">
            <label for="aesMode">AES 模式</label>
            <select v-model="aesOptions.mode" id="aesMode">
              <option value="GCM">GCM (Galois/Counter Mode) - 推荐，支持认证</option>
              <option value="CBC">CBC (Cipher Block Chaining)</option>
              <option value="CTR">CTR (Counter Mode)</option>
              <option value="CFB">CFB (Cipher Feedback)</option>
              <option value="OFB">OFB (Output Feedback)</option>
            </select>
            <div class="info-text">GCM 最安全（支持认证），CBC/CTR 兼容性好</div>
          </div>

          <div class="form-group">
            <label for="aesKeyLength">密钥长度</label>
            <select v-model.number="aesOptions.keyLength" id="aesKeyLength">
              <option :value="128">128 位 (16 字节) - 较快</option>
              <option :value="192">192 位 (24 字节)</option>
              <option :value="256">256 位 (32 字节) - 最安全</option>
            </select>
            <div class="info-text">密钥长度越长越安全，但加密速度稍慢</div>
          </div>

          <div class="form-group">
            <label for="saltInput">盐值 (Salt)</label>
            <div style="display:flex;gap:8px">
              <input
                v-model="aesOptions.salt"
                type="text"
                id="saltInput"
                placeholder="留空自动生成，或输入32个Hex字符(16字节)"
                style="flex:1"
              />
              <button type="button" class="btn btn-ripple" @click="generateSalt" style="width:auto;padding:12px 20px;font-size:14px">
                生成
              </button>
            </div>
            <div class="info-text">盐值用于增强密钥安全性，建议使用16字节随机值</div>
          </div>

          <div class="form-group">
            <label for="ivInput">初始化向量 (IV)</label>
            <div style="display:flex;gap:8px">
              <input
                v-model="aesOptions.iv"
                type="text"
                id="ivInput"
                placeholder="留空自动生成，或输入Hex字符串"
                style="flex:1"
              />
              <button type="button" class="btn btn-ripple" @click="generateIV" style="width:auto;padding:12px 20px;font-size:14px">
                生成
              </button>
            </div>
            <div class="info-text">IV用于确保相同明文产生不同密文，GCM模式12字节(24个Hex字符)，其他模式16字节(32个Hex字符)</div>
          </div>

          <div class="form-group">
            <label for="iterationsInput">PBKDF2 迭代次数</label>
            <input
              v-model.number="aesOptions.iterations"
              type="number"
              id="iterationsInput"
              min="1000"
              max="10000000"
              step="1000"
            />
            <div class="info-text">迭代次数越多越安全但越慢，推荐100000-1000000</div>
          </div>

          <div class="form-group">
            <label for="hashAlgoSelect">PBKDF2 哈希算法</label>
            <select v-model="aesOptions.hashAlgo" id="hashAlgoSelect">
              <option value="SHA-256">SHA-256 - 推荐</option>
              <option value="SHA-384">SHA-384</option>
              <option value="SHA-512">SHA-512 - 更安全但更慢</option>
            </select>
            <div class="info-text">用于PBKDF2密钥派生，SHA-256是平衡选择</div>
          </div>
        </template>
      </div>
    </div>

    <div class="form-section">
      <h2>输入与输出</h2>
      <div class="input-output-grid">
        <div class="input-box-wrapper">
          <div class="form-group">
            <label for="inputText">输入文本</label>
            <textarea
              v-model="inputText"
              id="inputText"
              placeholder="请输入要加密/解密的内容..."
            ></textarea>
          </div>
          <ButtonGroup gap="sm" class="input-box-buttons">
            <AppButton variant="secondary" size="sm" icon="🗑️" @click="clearAll">清空</AppButton>
            <AppButton variant="primary" size="sm" icon="🔒" @click="handleEncrypt">加密</AppButton>
            <AppButton variant="success" size="sm" icon="🔓" @click="handleDecrypt">解密</AppButton>
          </ButtonGroup>
        </div>
        <div class="output-box-wrapper">
          <div class="form-group">
            <label for="outputText">输出结果</label>
            <div class="result-area" id="outputText">{{ outputText }}</div>
          </div>
          <ButtonGroup class="output-box-buttons">
            <AppButton variant="info" size="sm" icon="📋" @click="copyResult">复制结果</AppButton>
          </ButtonGroup>
        </div>
      </div>
      <div v-if="message" :class="['status', messageType]">
        {{ message }}
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import CryptoJS from 'crypto-js'

const algorithms = {
  base64: { name: 'Base64', type: 'encode', needsKey: false },
  url: { name: 'URL 编码', type: 'encode', needsKey: false },
  html: { name: 'HTML 实体', type: 'encode', needsKey: false },
  hex: { name: 'Hex 编码', type: 'encode', needsKey: false },
  unicode: { name: 'Unicode 编码', type: 'encode', needsKey: false },
  md5: { name: 'MD5 哈希', type: 'hash', needsKey: false },
  sha1: { name: 'SHA-1 哈希', type: 'hash', needsKey: false },
  sha256: { name: 'SHA-256 哈希', type: 'hash', needsKey: false },
  sha512: { name: 'SHA-512 哈希', type: 'hash', needsKey: false },
  aes: { name: 'AES 加密', type: 'crypto', needsKey: true },
  caesar: { name: '凯撒密码', type: 'crypto', needsKey: true },
  morse: { name: '摩斯密码', type: 'encode', needsKey: false }
}

const currentAlgorithm = ref('base64')
const inputText = ref('')
const outputText = ref('')
const keyInput = ref('')
const message = ref('')
const messageType = ref('')

const aesOptions = ref({
  mode: 'GCM',
  keyLength: 256,
  salt: '',
  iv: '',
  iterations: 100000,
  hashAlgo: 'SHA-256'
})

function showMessage(text, type) {
  message.value = text
  messageType.value = type
  setTimeout(() => {
    message.value = ''
  }, 3000)
}

function selectAlgorithm(key) {
  currentAlgorithm.value = key
  if (key === 'caesar' && !keyInput.value) {
    keyInput.value = '3'
  }
}

function generateSalt() {
  aesOptions.value.salt = generateRandomHex(16)
  showMessage('已生成16字节随机盐值', 'success')
}

function generateIV() {
  const ivLength = aesOptions.value.mode === 'GCM' ? 12 : 16
  aesOptions.value.iv = generateRandomHex(ivLength)
  showMessage(`已生成${ivLength}字节随机IV`, 'success')
}

function generateRandomHex(bytes) {
  const random = crypto.getRandomValues(new Uint8Array(bytes))
  return Array.from(random).map(b => b.toString(16).padStart(2, '0')).join('')
}

async function handleEncrypt() {
  const algo = algorithms[currentAlgorithm.value]
  if (algo.type === 'encode') {
    await process('encode')
  } else if (algo.type === 'crypto') {
    await process('encrypt')
  } else if (algo.type === 'hash') {
    await process('hash')
  }
}

async function handleDecrypt() {
  const algo = algorithms[currentAlgorithm.value]
  if (algo.type === 'encode') {
    await process('decode')
  } else if (algo.type === 'crypto') {
    await process('decrypt')
  } else {
    showMessage('该算法不支持解密操作', 'error')
  }
}

async function process(mode) {
  const input = inputText.value.trim()
  if (!input) {
    showMessage('请输入内容', 'error')
    return
  }

  try {
    const algo = algorithms[currentAlgorithm.value]
    let result = ''

    if (algo.type === 'encode') {
      result = await handleEncode(currentAlgorithm.value, input, mode)
    } else if (algo.type === 'hash') {
      result = await handleHash(currentAlgorithm.value, input)
    } else if (algo.type === 'crypto') {
      const key = keyInput.value || ''
      if (algo.needsKey && !key) {
        showMessage('请输入密钥', 'error')
        return
      }
      result = await handleCrypto(currentAlgorithm.value, input, key, mode)
    }

    outputText.value = result
    showMessage(mode === 'encrypt' || mode === 'encode' ? '加密/编码成功' : '解密/解码成功', 'success')
  } catch (err) {
    console.error(err)
    showMessage('处理失败：' + err.message, 'error')
    outputText.value = ''
  }
}

async function handleEncode(algorithm, input, mode) {
  switch (algorithm) {
    case 'base64':
      return mode === 'encode'
        ? btoa(unescape(encodeURIComponent(input)))
        : decodeURIComponent(escape(atob(input)))
    case 'url':
      return mode === 'encode' ? encodeURIComponent(input) : decodeURIComponent(input)
    case 'html':
      const div = document.createElement('div')
      if (mode === 'encode') {
        div.textContent = input
        return div.innerHTML.replace(/"/g, '&quot;').replace(/'/g, '&#39;')
      } else {
        div.innerHTML = input
        return div.textContent
      }
    case 'hex':
      if (mode === 'encode') {
        return Array.from(input).map(c => c.charCodeAt(0).toString(16).padStart(2, '0')).join(' ')
      } else {
        const hexStr = input.replace(/\s+/g, '')
        if (hexStr.length % 2 !== 0) {
          throw new Error('Hex字符串长度必须是偶数')
        }
        let result = ''
        for (let i = 0; i < hexStr.length; i += 2) {
          const hex = hexStr.substr(i, 2)
          result += String.fromCharCode(parseInt(hex, 16))
        }
        return result
      }
    case 'unicode':
      if (mode === 'encode') {
        return Array.from(input).map(c => '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')).join('')
      } else {
        return input.replace(/\\u([0-9a-fA-F]{4})/g, (_, hex) => String.fromCharCode(parseInt(hex, 16)))
      }
    case 'morse':
      const morseCode = {
        'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.', 'G': '--.', 'H': '....',
        'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---', 'P': '.--.',
        'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
        'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---', '3': '...--', '4': '....-',
        '5': '.....', '6': '-....', '7': '--...', '8': '---..', '9': '----.', '.': '.-.-.-', ',': '--..--',
        '?': '..--..', "'": '.----.', '!': '-.-.--', '/': '-..-.', '(': '-.--.', ')': '-.--.-',
        '&': '.-...', ':': '---...', ';': '-.-.-.', '=': '-...-', '+': '.-.-.', '-': '-....-',
        '_': '..--.-', '"': '.-..-.', '$': '...-..-', '@': '.--.-.'
      }
      const reverseMorse = {}
      Object.keys(morseCode).forEach(k => { reverseMorse[morseCode[k]] = k })
      if (mode === 'encode') {
        return input.toUpperCase().split('').map(c => morseCode[c] || (c === ' ' ? '/' : c)).join(' ').replace(/  +/g, ' / ')
      } else {
        return input.split(/[\s\/]+/).map(m => {
          if (m === '' || m === '/') return ' '
          return reverseMorse[m] || m
        }).join('').replace(/\s+/g, ' ')
      }
    default:
      throw new Error('不支持的编码算法')
  }
}

async function handleHash(algorithm, input) {
  switch (algorithm) {
    case 'md5':
      return CryptoJS.MD5(input).toString()
    case 'sha1':
      return CryptoJS.SHA1(input).toString()
    case 'sha256':
      return CryptoJS.SHA256(input).toString()
    case 'sha512':
      return CryptoJS.SHA512(input).toString()
    default:
      throw new Error('不支持的哈希算法')
  }
}

async function handleCrypto(algorithm, input, key, mode) {
  switch (algorithm) {
    case 'aes':
      return await aesCrypto(input, key, mode)
    case 'caesar':
      return caesarCipher(input, parseInt(key) || 3, mode)
    default:
      throw new Error('不支持的加密算法')
  }
}

async function aesCrypto(text, password, mode) {
  const options = aesOptions.value
  
  if (mode === 'encrypt') {
    // 生成盐值和IV
    const salt = options.salt ? CryptoJS.enc.Hex.parse(options.salt) : CryptoJS.lib.WordArray.random(128/8)
    const ivLength = options.mode === 'GCM' ? 12 : 16
    const iv = options.iv ? CryptoJS.enc.Hex.parse(options.iv) : CryptoJS.lib.WordArray.random(ivLength * 8 / 8)
    
    // 使用 PBKDF2 派生密钥
    const key = CryptoJS.PBKDF2(password, salt, {
      keySize: options.keyLength / 32,
      iterations: options.iterations,
      hasher: CryptoJS.algo[options.hashAlgo.replace('-', '')]
    })
    
    // 根据模式选择加密方式
    let encrypted
    if (options.mode === 'GCM') {
      encrypted = CryptoJS.AES.encrypt(text, key, {
        iv: iv,
        mode: CryptoJS.mode.GCM,
        padding: CryptoJS.pad.Pkcs7
      })
    } else {
      const modeMap = {
        'CBC': CryptoJS.mode.CBC,
        'CTR': CryptoJS.mode.CTR,
        'CFB': CryptoJS.mode.CFB,
        'OFB': CryptoJS.mode.OFB
      }
      encrypted = CryptoJS.AES.encrypt(text, key, {
        iv: iv,
        mode: modeMap[options.mode] || CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
      })
    }
    
    // 组合 salt + iv + ciphertext
    const saltHex = salt.toString(CryptoJS.enc.Hex)
    const ivHex = iv.toString(CryptoJS.enc.Hex)
    const ciphertext = encrypted.ciphertext.toString(CryptoJS.enc.Hex)
    
    // 添加元数据
    const metadata = {
      saltLen: saltHex.length / 2,
      ivLen: ivHex.length / 2,
      mode: options.mode,
      keyLen: options.keyLength,
      iterations: options.iterations,
      hashAlgo: options.hashAlgo
    }
    
    const combined = `${saltHex}:${ivHex}:${ciphertext}:${JSON.stringify(metadata)}`
    return btoa(combined)
  } else {
    // 解密
    try {
      const decoded = atob(text)
      const parts = decoded.split(':')
      if (parts.length < 4) {
        throw new Error('密文格式错误')
      }
      
      const metadata = JSON.parse(parts[3])
      const salt = CryptoJS.enc.Hex.parse(parts[0])
      const iv = CryptoJS.enc.Hex.parse(parts[1])
      const ciphertext = parts[2]
      
      // 重新派生密钥
      const key = CryptoJS.PBKDF2(password, salt, {
        keySize: metadata.keyLen / 32,
        iterations: metadata.iterations,
        hasher: CryptoJS.algo[metadata.hashAlgo.replace('-', '')]
      })
      
      // 解密
      const cipherParams = CryptoJS.lib.CipherParams.create({
        ciphertext: CryptoJS.enc.Hex.parse(ciphertext)
      })
      
      let decrypted
      if (metadata.mode === 'GCM') {
        decrypted = CryptoJS.AES.decrypt(cipherParams, key, {
          iv: iv,
          mode: CryptoJS.mode.GCM,
          padding: CryptoJS.pad.Pkcs7
        })
      } else {
        const modeMap = {
          'CBC': CryptoJS.mode.CBC,
          'CTR': CryptoJS.mode.CTR,
          'CFB': CryptoJS.mode.CFB,
          'OFB': CryptoJS.mode.OFB
        }
        decrypted = CryptoJS.AES.decrypt(cipherParams, key, {
          iv: iv,
          mode: modeMap[metadata.mode] || CryptoJS.mode.CBC,
          padding: CryptoJS.pad.Pkcs7
        })
      }
      
      return decrypted.toString(CryptoJS.enc.Utf8)
    } catch (e) {
      throw new Error('解密失败：' + e.message)
    }
  }
}

function caesarCipher(text, shift, mode) {
  shift = mode === 'decrypt' ? -shift : shift
  return text.split('').map(char => {
    const code = char.charCodeAt(0)
    if (code >= 65 && code <= 90) {
      return String.fromCharCode(((code - 65 + shift + 26) % 26) + 65)
    } else if (code >= 97 && code <= 122) {
      return String.fromCharCode(((code - 97 + shift + 26) % 26) + 97)
    }
    return char
  }).join('')
}

function clearAll() {
  inputText.value = ''
  outputText.value = ''
  showMessage('已清空', 'success')
}

function copyResult() {
  const text = outputText.value
  if (!text) {
    showMessage('没有可复制的内容', 'error')
    return
  }
  navigator.clipboard.writeText(text).then(() => {
    showMessage('已复制到剪贴板', 'success')
  }).catch(() => {
    const textarea = document.createElement('textarea')
    textarea.value = text
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    showMessage('已复制到剪贴板', 'success')
  })
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
  gap: var(--spacing-md);
  margin-top: var(--spacing-xl);
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
.form-group select,
.form-group textarea {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-family: inherit;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.form-group textarea {
  min-height: 120px;
  resize: vertical;
}

.info-text {
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
  margin-top: 5px;
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
  transition: transform .2s;
  width: 100%;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn:disabled {
  opacity: .6;
  cursor: not-allowed;
}

.btn-secondary {
  background: linear-gradient(135deg, var(--color-text-secondary) 0%, var(--color-text-light) 100%);
  margin-top: 10px;
}

.btn-encrypt {
  background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 50%, #fecfef 100%);
  color: var(--color-text-on-primary);
  border: none;
}

.btn-encrypt:hover {
  background: linear-gradient(135deg, #ff8a8e 0%, #febfdf 50%, #febfdf 100%);
  box-shadow: 0 5px 15px rgba(255, 154, 158, .4);
  transform: translateY(-2px);
}

.btn-decrypt {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  color: var(--color-text-on-primary);
  border: none;
}

.btn-decrypt:hover {
  background: linear-gradient(135deg, #98ddd8 0%, #fec6d3 100%);
  box-shadow: 0 5px 15px rgba(168, 237, 234, .4);
  transform: translateY(-2px);
}

.status {
  display: none;
  margin-top: 12px;
  padding: 10px;
  border-radius: 8px;
}

.status.show {
  display: block;
}

.status.success {
  background: var(--color-surface-alt);
  color: var(--color-success);
  border: 1px solid #c3e6cb;
}

.status.error {
  background: var(--color-surface-alt);
  color: var(--color-error);
  border: 1px solid #f5c6cb;
}

.result-area {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: var(--spacing-md);
  min-height: 120px;
  word-break: break-all;
  white-space: pre-wrap;
  font-family: 'Courier New', monospace;
  font-size: var(--font-size-small);
  user-select: text;
  color: var(--color-text);
}

.input-box-wrapper,
.output-box-wrapper {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.input-box-wrapper .form-group,
.output-box-wrapper .form-group {
  margin-bottom: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.input-box-wrapper textarea,
.output-box-wrapper .result-area {
  flex: 1;
  min-height: 250px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
}

.input-box-buttons,
.output-box-buttons {
  display: flex;
  gap: 12px;
  padding-top: 10px;
  border-top: 1px solid var(--color-border);
}

.input-box-buttons .btn {
  flex: 1;
  padding: 12px 20px;
  font-size: 14px;
}

.output-box-buttons .btn {
  width: 100%;
  padding: 12px 20px;
  font-size: 14px;
}

.input-output-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
}

.algorithm-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 20px;
}

.tab-btn {
  background: var(--color-surface-alt);
  color: var(--color-text-on-surface-alt);
  border: 2px solid var(--color-border);
  padding: 10px 20px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-weight: 600;
  transition: all .2s;
}

.tab-btn.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border-color: var(--color-primary);
}

@media (max-width: 768px) {
  .input-output-grid {
    grid-template-columns: 1fr;
  }
}
</style>
