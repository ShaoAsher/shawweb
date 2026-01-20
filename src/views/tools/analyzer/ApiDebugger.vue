<template>
  <ToolLayout title="🌐 API 调试工具" description="支持 HTTP 请求和 WebSocket (WSS) 连接调试，类似 APIFOX，包含请求历史记录">
    <div class="main-content">
      <!-- 请求区域 -->
      <div class="request-section">
        <div class="request-toolbar">
          <select class="method-select" v-model="httpMethod">
            <option value="GET">GET</option>
            <option value="POST">POST</option>
            <option value="PUT">PUT</option>
            <option value="DELETE">DELETE</option>
            <option value="PATCH">PATCH</option>
            <option value="HEAD">HEAD</option>
            <option value="OPTIONS">OPTIONS</option>
          </select>
          <input type="text" class="url-input" v-model="httpUrl" placeholder='接口路径, "/"起始'>
          <ButtonGroup gap="sm" class="toolbar-buttons">
            <AppButton variant="primary" icon="🚀" @click="sendRequest">发送</AppButton>
            <AppButton variant="secondary" icon="📋" @click="showHistoryModal">历史</AppButton>
          </ButtonGroup>
        </div>

        <div class="tabs-container">
          <div class="main-tabs">
            <button 
              class="main-tab" 
              :class="{ active: activeTab === 'params' }"
              @click="activeTab = 'params'"
            >
              Params
            </button>
            <button 
              class="main-tab" 
              :class="{ active: activeTab === 'body' }"
              @click="activeTab = 'body'"
            >
              Body
            </button>
            <button 
              class="main-tab" 
              :class="{ active: activeTab === 'headers' }"
              @click="activeTab = 'headers'"
            >
              Headers
            </button>
          </div>
        </div>

        <!-- Params 标签页 -->
        <div v-show="activeTab === 'params'" class="tab-panel active">
          <h3 style="margin-bottom: 15px; font-size: var(--font-size-base); color: var(--color-text-secondary);">Query 参数</h3>
          <table class="params-table">
            <thead>
              <tr>
                <th style="width: 30px;"></th>
                <th>参数名</th>
                <th>参数值</th>
                <th>类型</th>
                <th>说明</th>
                <th style="width: 80px;"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(param, index) in params" :key="index">
                <td><input type="checkbox" v-model="param.enabled" class="param-checkbox"></td>
                <td><input type="text" v-model="param.key" placeholder="参数名" class="param-key"></td>
                <td><input type="text" v-model="param.value" placeholder="参数值" class="param-value"></td>
                <td>
                  <select v-model="param.type" class="param-type">
                    <option value="text">Text</option>
                    <option value="number">Number</option>
                    <option value="boolean">Boolean</option>
                  </select>
                </td>
                <td><input type="text" v-model="param.desc" placeholder="说明" class="param-desc"></td>
                <td><button class="remove-btn" @click="removeParam(index)">删除</button></td>
              </tr>
            </tbody>
          </table>
          <div class="action-buttons">
            <button class="add-param-btn" @click="addParam">添加参数</button>
            <button class="batch-edit-btn" @click="openBatchEditModal('params')">
              <span>⋯</span>
              <span>批量编辑</span>
            </button>
          </div>
        </div>

        <!-- Body 标签页 -->
        <div v-show="activeTab === 'body'" class="tab-panel active">
          <div class="body-type-tabs">
            <button 
              v-for="type in bodyTypes" 
              :key="type.value"
              class="body-type-tab" 
              :class="{ active: currentBodyType === type.value }"
              @click="currentBodyType = type.value"
            >
              {{ type.label }}
            </button>
          </div>

          <div v-if="currentBodyType === 'none'" style="padding: var(--spacing-xl); text-align: center; color: var(--color-text-secondary);">
            该请求没有 Body
          </div>

          <div v-if="currentBodyType === 'form-data'">
            <h3 style="margin-bottom: 15px; font-size: var(--font-size-base); color: var(--color-text-secondary);">Form Data</h3>
            <table class="params-table">
              <thead>
                <tr>
                  <th style="width: 30px;"></th>
                  <th>参数名</th>
                  <th>参数值</th>
                  <th>类型</th>
                  <th>说明</th>
                  <th style="width: 80px;"></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in formData" :key="index">
                  <td><input type="checkbox" v-model="item.enabled" class="param-checkbox"></td>
                  <td><input type="text" v-model="item.key" placeholder="参数名" class="param-key"></td>
                  <td>
                    <div class="file-input-wrapper">
                      <input v-if="item.type !== 'file'" type="text" v-model="item.value" placeholder="参数值" class="param-value">
                      <input v-else type="text" v-model="item.value" placeholder="参数值" class="param-value" readonly>
                      <button v-if="item.type === 'file'" class="file-select-btn" @click="selectFile(index)">选择文件</button>
                      <input 
                        v-if="item.type === 'file'" 
                        type="file" 
                        :ref="el => { if (el) fileInputs[index] = el }"
                        style="display: none" 
                        @change="handleFileSelect(index, $event)"
                      >
                      <span v-if="item.fileName" class="file-name">{{ item.fileName }}</span>
                    </div>
                  </td>
                  <td>
                    <select v-model="item.type" @change="handleFormDataTypeChange(index)" class="param-type">
                      <option value="string">string</option>
                      <option value="integer">integer</option>
                      <option value="boolean">boolean</option>
                      <option value="number">number</option>
                      <option value="file">file</option>
                      <option value="array">array</option>
                    </select>
                  </td>
                  <td><input type="text" v-model="item.desc" placeholder="说明" class="param-desc"></td>
                  <td><button class="remove-btn" @click="removeFormData(index)">删除</button></td>
                </tr>
              </tbody>
            </table>
            <div class="action-buttons">
              <button class="add-param-btn" @click="addFormData">添加参数</button>
              <button class="batch-edit-btn" @click="openBatchEditModal('form-data')">
                <span>⋯</span>
                <span>批量编辑</span>
              </button>
            </div>
          </div>

          <div v-if="currentBodyType === 'x-www-form-urlencoded'">
            <h3 style="margin-bottom: 15px; font-size: var(--font-size-base); color: var(--color-text-secondary);">x-www-form-urlencoded</h3>
            <table class="params-table">
              <thead>
                <tr>
                  <th style="width: 30px;"></th>
                  <th>参数名</th>
                  <th>参数值</th>
                  <th>类型</th>
                  <th>说明</th>
                  <th style="width: 80px;"></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in xFormData" :key="index">
                  <td><input type="checkbox" v-model="item.enabled" class="param-checkbox"></td>
                  <td><input type="text" v-model="item.key" placeholder="参数名" class="param-key"></td>
                  <td><input type="text" v-model="item.value" placeholder="参数值" class="param-value"></td>
                  <td>
                    <select v-model="item.type" class="param-type">
                      <option value="string">string</option>
                      <option value="integer">integer</option>
                      <option value="boolean">boolean</option>
                      <option value="number">number</option>
                    </select>
                  </td>
                  <td><input type="text" v-model="item.desc" placeholder="说明" class="param-desc"></td>
                  <td><button class="remove-btn" @click="removeXForm(index)">删除</button></td>
                </tr>
              </tbody>
            </table>
            <div class="action-buttons">
              <button class="add-param-btn" @click="addXForm">添加参数</button>
              <button class="batch-edit-btn" @click="openBatchEditModal('x-form')">
                <span>⋯</span>
                <span>批量编辑</span>
              </button>
            </div>
          </div>

          <div v-if="currentBodyType === 'json'">
            <textarea class="textarea-body" v-model="jsonBody" placeholder='{"key": "value"}'></textarea>
          </div>

          <div v-if="['text', 'xml', 'binary', 'graphql', 'msgpack'].includes(currentBodyType)">
            <textarea class="textarea-body" v-model="textBody" placeholder="输入文本内容"></textarea>
          </div>
        </div>

        <!-- Headers 标签页 -->
        <div v-show="activeTab === 'headers'" class="tab-panel active">
          <h3 style="margin-bottom: 15px; font-size: var(--font-size-base); color: var(--color-text-secondary);">请求头</h3>
          <table class="params-table">
            <thead>
              <tr>
                <th style="width: 30px;"></th>
                <th>Key</th>
                <th>Value</th>
                <th>说明</th>
                <th style="width: 80px;"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(header, index) in headers" :key="index">
                <td><input type="checkbox" v-model="header.enabled" class="param-checkbox"></td>
                <td><input type="text" v-model="header.key" placeholder="Key" class="header-key"></td>
                <td><input type="text" v-model="header.value" placeholder="Value" class="header-value"></td>
                <td><input type="text" v-model="header.desc" placeholder="说明" class="header-desc"></td>
                <td><button class="remove-btn" @click="removeHeader(index)">删除</button></td>
              </tr>
            </tbody>
          </table>
          <div class="action-buttons">
            <button class="add-param-btn" @click="addHeader">添加请求头</button>
            <button class="batch-edit-btn" @click="openBatchEditModal('headers')">
              <span>⋯</span>
              <span>批量编辑</span>
            </button>
          </div>
        </div>
      </div>

      <!-- 响应区域 -->
      <div class="response-section">
        <div class="response-header">
          <h3>返回响应</h3>
          <div class="response-status">
            <span>校验响应</span>
            <label style="display: flex; align-items: center; gap: 5px;">
              <input type="checkbox" v-model="validateResponse">
            </label>
            <span class="status-badge" :class="responseStatusClass">{{ responseStatusText }}</span>
          </div>
        </div>
        <div class="response-body" v-html="responseBody"></div>
      </div>
    </div>

    <!-- 批量编辑弹窗 -->
    <div v-if="showBatchModal" class="modal active" @click.self="closeBatchEditModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>批量编辑</h3>
          <button class="modal-close" @click="closeBatchEditModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="batch-mode-tabs">
            <button 
              class="batch-mode-tab" 
              :class="{ active: batchMode === 'comma' }"
              @click="batchMode = 'comma'"
            >
              逗号模式
            </button>
            <button 
              class="batch-mode-tab" 
              :class="{ active: batchMode === 'colon' }"
              @click="batchMode = 'colon'"
            >
              冒号模式
            </button>
          </div>
          <div class="batch-format-hint">
            <span v-if="batchMode === 'comma'">
              格式: 启用,参数名,参数值,类型,必需,Content-Type,说明<br>
              数据格式遵循《标准 CSV 规范》字段之间以英文逗号(,)分隔,多条记录以换行分隔
            </span>
            <span v-else>
              格式: 参数名:参数值<br>
              每行一个参数，参数名和参数值用冒号分隔
            </span>
          </div>
          <textarea class="batch-textarea" v-model="batchEditInput" placeholder="输入批量数据..."></textarea>
        </div>
        <ButtonGroup gap="sm" align="end" class="modal-footer">
          <AppButton variant="secondary" @click="closeBatchEditModal">取消</AppButton>
          <AppButton variant="primary" icon="✓" @click="applyBatchEdit">确定</AppButton>
        </ButtonGroup>
      </div>
    </div>

    <!-- 历史记录弹窗 -->
    <div v-if="showHistory" class="modal active" @click.self="showHistory = false">
      <div class="modal-content" style="max-width: 800px;" @click.stop>
        <div class="modal-header">
          <h3>历史记录</h3>
          <button class="modal-close" @click="showHistory = false">&times;</button>
        </div>
        <div class="modal-body" style="max-height: 500px; overflow-y: auto;">
          <p v-if="requestHistory.length === 0" style="text-align: center; color: var(--color-text-secondary); padding: var(--spacing-xl);">暂无历史记录</p>
          <div 
            v-for="(item, index) in requestHistory" 
            :key="index"
            style="padding: var(--spacing-md); margin-bottom: 10px; background: var(--color-surface-alt); border-radius: var(--radius-sm); border-left: 3px solid var(--color-primary); cursor: pointer;"
            @click="loadHistoryItem(index)"
          >
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span :style="{ display: 'inline-block', padding: '4px 12px', background: getMethodColor(item.method), color: 'var(--color-text-on-primary)', borderRadius: '4px', fontSize: 'var(--font-size-small)', fontWeight: '600' }">
                {{ item.method }}
              </span>
              <span style="font-size: 11px; color: var(--color-text-secondary);">{{ new Date(item.timestamp).toLocaleString() }}</span>
            </div>
            <div style="font-size: 13px; color: var(--color-text-secondary); margin-bottom: 5px;">{{ item.url }}</div>
            <div style="font-size: var(--font-size-small); color: var(--color-text-secondary);">状态: {{ item.status }} {{ item.statusText || '' }}</div>
          </div>
        </div>
        <ButtonGroup gap="sm" align="end" class="modal-footer">
          <AppButton variant="danger" icon="🗑️" @click="clearHistory">清空历史</AppButton>
          <AppButton variant="primary" @click="showHistory = false">关闭</AppButton>
        </ButtonGroup>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { computed, onMounted, ref, watch } from 'vue'

const httpMethod = ref('GET')
const httpUrl = ref('')
const activeTab = ref('params')
const currentBodyType = ref('none')
const validateResponse = ref(false)
const showBatchModal = ref(false)
const showHistory = ref(false)
const batchMode = ref('comma')
const batchEditInput = ref('')
const currentBatchType = ref('params')
const responseStatusText = ref('成功 (200)')
const responseStatusClass = ref('status-success')
const responseBody = ref('<div class="empty-response"><div class="empty-response-icon">🚀</div><div>点击"发送"按钮获取返回结果</div></div>')
const fileInputs = ref({})

const params = ref([{ enabled: true, key: '', value: '', type: 'text', desc: '' }])
const formData = ref([{ enabled: true, key: '', value: '', type: 'string', desc: '', fileName: '' }])
const xFormData = ref([{ enabled: true, key: '', value: '', type: 'string', desc: '' }])
const headers = ref([{ enabled: true, key: 'Content-Type', value: 'application/json', desc: '' }])
const jsonBody = ref('')
const textBody = ref('')
const requestHistory = ref([])

const bodyTypes = [
  { value: 'none', label: 'none' },
  { value: 'form-data', label: 'form-data' },
  { value: 'x-www-form-urlencoded', label: 'x-www-form-urlencoded' },
  { value: 'json', label: 'JSON' },
  { value: 'xml', label: 'XML' },
  { value: 'text', label: 'Text' },
  { value: 'binary', label: 'Binary' },
  { value: 'graphql', label: 'GraphQL' },
  { value: 'msgpack', label: 'msgpack' }
]

onMounted(() => {
  const stored = localStorage.getItem('apiDebuggerHistory')
  if (stored) {
    requestHistory.value = JSON.parse(stored)
  }
})

function addParam() {
  params.value.push({ enabled: true, key: '', value: '', type: 'text', desc: '' })
}

function removeParam(index) {
  params.value.splice(index, 1)
  if (params.value.length === 0) {
    params.value.push({ enabled: true, key: '', value: '', type: 'text', desc: '' })
  }
}

function addFormData() {
  formData.value.push({ enabled: true, key: '', value: '', type: 'string', desc: '', fileName: '' })
}

function removeFormData(index) {
  formData.value.splice(index, 1)
  if (formData.value.length === 0) {
    formData.value.push({ enabled: true, key: '', value: '', type: 'string', desc: '', fileName: '' })
  }
}

function addXForm() {
  xFormData.value.push({ enabled: true, key: '', value: '', type: 'string', desc: '' })
}

function removeXForm(index) {
  xFormData.value.splice(index, 1)
  if (xFormData.value.length === 0) {
    xFormData.value.push({ enabled: true, key: '', value: '', type: 'string', desc: '' })
  }
}

function addHeader() {
  headers.value.push({ enabled: true, key: '', value: '', desc: '' })
}

function removeHeader(index) {
  headers.value.splice(index, 1)
  if (headers.value.length === 0) {
    headers.value.push({ enabled: true, key: '', value: '', desc: '' })
  }
}

function handleFormDataTypeChange(index) {
  const item = formData.value[index]
  if (item.type === 'file') {
    item.value = ''
    item.fileName = ''
  }
}

function selectFile(index) {
  if (fileInputs.value[index]) {
    fileInputs.value[index].click()
  }
}

function handleFileSelect(index, event) {
  const file = event.target.files[0]
  if (file) {
    formData.value[index].fileName = file.name
    formData.value[index].value = file.name
  }
}

function openBatchEditModal(type) {
  currentBatchType.value = type
  showBatchModal.value = true
  exportBatchData()
}

function closeBatchEditModal() {
  showBatchModal.value = false
  batchEditInput.value = ''
}

function exportBatchData() {
  let lines = []
  if (currentBatchType.value === 'params') {
    params.value.forEach(param => {
      if (param.key && param.value) {
        lines.push(`${param.enabled ? '1' : '0'},${param.key},${param.value},${param.type},,${param.desc}`)
      }
    })
  } else if (currentBatchType.value === 'form-data') {
    formData.value.forEach(item => {
      if (item.key) {
        lines.push(`${item.enabled ? '1' : '0'},${item.key},${item.value},${item.type},,${item.desc}`)
      }
    })
  } else if (currentBatchType.value === 'x-form') {
    xFormData.value.forEach(item => {
      if (item.key && item.value) {
        lines.push(`${item.enabled ? '1' : '0'},${item.key},${item.value},${item.type},,${item.desc}`)
      }
    })
  } else if (currentBatchType.value === 'headers') {
    headers.value.forEach(header => {
      if (header.key && header.value) {
        lines.push(`${header.enabled ? '1' : '0'},${header.key},${header.value},,,${header.desc}`)
      }
    })
  }
  batchEditInput.value = lines.join('\n')
}

function applyBatchEdit() {
  const input = batchEditInput.value.trim()
  if (!input) {
    alert('请输入要导入的数据')
    return
  }
  const lines = input.split('\n').filter(line => line.trim())
  if (currentBatchType.value === 'params') {
    params.value = []
    lines.forEach(line => {
      if (batchMode.value === 'comma') {
        const parts = line.split(',')
        if (parts.length >= 3) {
          params.value.push({
            enabled: parts[0] === '1',
            key: parts[1] || '',
            value: parts[2] || '',
            type: parts[3] || 'text',
            desc: parts[6] || ''
          })
        }
      } else {
        const [key, value] = line.split(':').map(s => s.trim())
        if (key && value) {
          params.value.push({ enabled: true, key, value, type: 'text', desc: '' })
        }
      }
    })
    if (params.value.length === 0) {
      params.value.push({ enabled: true, key: '', value: '', type: 'text', desc: '' })
    }
  } else if (currentBatchType.value === 'form-data') {
    formData.value = []
    lines.forEach(line => {
      if (batchMode.value === 'comma') {
        const parts = line.split(',')
        if (parts.length >= 3) {
          formData.value.push({
            enabled: parts[0] === '1',
            key: parts[1] || '',
            value: parts[2] || '',
            type: parts[3] || 'string',
            desc: parts[6] || '',
            fileName: ''
          })
        }
      } else {
        const [key, value] = line.split(':').map(s => s.trim())
        if (key && value) {
          formData.value.push({ enabled: true, key, value, type: 'string', desc: '', fileName: '' })
        }
      }
    })
    if (formData.value.length === 0) {
      formData.value.push({ enabled: true, key: '', value: '', type: 'string', desc: '', fileName: '' })
    }
  } else if (currentBatchType.value === 'x-form') {
    xFormData.value = []
    lines.forEach(line => {
      if (batchMode.value === 'comma') {
        const parts = line.split(',')
        if (parts.length >= 3) {
          xFormData.value.push({
            enabled: parts[0] === '1',
            key: parts[1] || '',
            value: parts[2] || '',
            type: parts[3] || 'string',
            desc: parts[6] || ''
          })
        }
      } else {
        const [key, value] = line.split(':').map(s => s.trim())
        if (key && value) {
          xFormData.value.push({ enabled: true, key, value, type: 'string', desc: '' })
        }
      }
    })
    if (xFormData.value.length === 0) {
      xFormData.value.push({ enabled: true, key: '', value: '', type: 'string', desc: '' })
    }
  } else if (currentBatchType.value === 'headers') {
    headers.value = []
    lines.forEach(line => {
      if (batchMode.value === 'comma') {
        const parts = line.split(',')
        if (parts.length >= 3) {
          headers.value.push({
            enabled: parts[0] === '1',
            key: parts[1] || '',
            value: parts[2] || '',
            desc: parts[6] || ''
          })
        }
      } else {
        const [key, value] = line.split(':').map(s => s.trim())
        if (key && value) {
          headers.value.push({ enabled: true, key, value, desc: '' })
        }
      }
    })
    if (headers.value.length === 0) {
      headers.value.push({ enabled: true, key: '', value: '', desc: '' })
    }
  }
  closeBatchEditModal()
}

function getMethodColor(method) {
  const colors = {
    'GET': '#07C160',
    'POST': '#1677FF',
    'PUT': '#FFA500',
    'DELETE': '#FF0050',
    'PATCH': '#FFA500'
  }
  return colors[method] || 'var(--color-text-secondary)'
}

function showHistoryModal() {
  showHistory.value = true
}

function loadHistoryItem(index) {
  const item = requestHistory.value[index]
  httpMethod.value = item.method
  httpUrl.value = item.url
  showHistory.value = false
}

function clearHistory() {
  if (confirm('确定要清空所有历史记录吗？')) {
    requestHistory.value = []
    localStorage.setItem('apiDebuggerHistory', JSON.stringify(requestHistory.value))
  }
}

async function sendRequest() {
  let url = httpUrl.value.trim()
  if (!url) {
    alert('请输入接口路径')
    return
  }

  const requestHeaders = {}
  headers.value.forEach(header => {
    if (header.enabled && header.key && header.value) {
      requestHeaders[header.key] = header.value
    }
  })

  const requestConfig = {
    method: httpMethod.value,
    headers: requestHeaders
  }

  // 处理 Query 参数
  if (activeTab.value === 'params' || (activeTab.value === 'body' && currentBodyType.value === 'none')) {
    try {
      const baseUrl = url.startsWith('http') ? url : (url.startsWith('/') ? 'https://example.com' + url : 'https://example.com/' + url)
      const urlObj = new URL(baseUrl)
      params.value.forEach(param => {
        if (param.enabled && param.key && param.value) {
          urlObj.searchParams.append(param.key, param.value)
        }
      })
      url = url.startsWith('http') ? urlObj.toString() : urlObj.pathname + urlObj.search
    } catch (e) {
      console.warn('URL 解析失败:', e)
    }
  }

  // 处理 Body
  if (activeTab.value === 'body' && currentBodyType.value !== 'none') {
    if (currentBodyType.value === 'form-data') {
      const formDataObj = new FormData()
      formData.value.forEach(item => {
        if (item.enabled && item.key) {
          if (item.type === 'file' && fileInputs.value[formData.value.indexOf(item)]?.files[0]) {
            formDataObj.append(item.key, fileInputs.value[formData.value.indexOf(item)].files[0])
          } else if (item.value) {
            formDataObj.append(item.key, item.value)
          }
        }
      })
      requestConfig.body = formDataObj
      delete requestConfig.headers['Content-Type']
    } else if (currentBodyType.value === 'json') {
      if (jsonBody.value.trim()) {
        try {
          JSON.parse(jsonBody.value)
          requestConfig.body = jsonBody.value
        } catch (e) {
          alert('JSON 格式错误：' + e.message)
          return
        }
      }
    } else if (currentBodyType.value === 'text') {
      if (textBody.value.trim()) {
        requestConfig.body = textBody.value
      }
    } else if (currentBodyType.value === 'x-www-form-urlencoded') {
      const formDataObj = new URLSearchParams()
      xFormData.value.forEach(item => {
        if (item.enabled && item.key && item.value) {
          formDataObj.append(item.key, item.value)
        }
      })
      requestConfig.body = formDataObj.toString()
      if (!requestConfig.headers['Content-Type']) {
        requestConfig.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      }
    }
  }

  // 确保 URL 格式正确
  let finalUrl = url
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    if (url.startsWith('/')) {
      finalUrl = 'https://example.com' + url
    } else {
      finalUrl = 'https://' + url
    }
  }

  try {
    const startTime = Date.now()
    const response = await fetch(finalUrl, requestConfig)
    const duration = Date.now() - startTime

    // 保存到历史
    const historyItem = {
      method: httpMethod.value,
      url: finalUrl,
      timestamp: new Date().toISOString(),
      status: response.status,
      statusText: response.statusText
    }
    requestHistory.value.unshift(historyItem)
    if (requestHistory.value.length > 50) requestHistory.value.pop()
    localStorage.setItem('apiDebuggerHistory', JSON.stringify(requestHistory.value))

    const responseHeadersObj = {}
    response.headers.forEach((value, key) => {
      responseHeadersObj[key] = value
    })

    let responseBodyText = ''
    const contentType = response.headers.get('content-type') || ''
    if (contentType.includes('application/json')) {
      try {
        const json = await response.json()
        responseBodyText = JSON.stringify(json, null, 2)
      } catch (e) {
        responseBodyText = await response.text()
      }
    } else {
      responseBodyText = await response.text()
    }

    displayResponse(response.status, response.statusText, responseHeadersObj, responseBodyText, duration)
  } catch (error) {
    displayResponse(0, 'Error', {}, '请求失败：' + error.message + '\n\n错误详情：\n' + (error.stack || ''), 0)
  }
}

function displayResponse(status, statusText, headers, body, duration) {
  if (status >= 200 && status < 300) {
    responseStatusClass.value = 'status-success'
    responseStatusText.value = `成功 (${status})`
  } else if (status >= 400) {
    responseStatusClass.value = 'status-error'
    responseStatusText.value = `错误 (${status})`
  } else if (status === 0) {
    responseStatusClass.value = 'status-error'
    responseStatusText.value = 'Error'
  } else {
    responseStatusClass.value = 'status-info'
    responseStatusText.value = status ? `${status} ${statusText}` : 'Error'
  }

  let html = ''
  if (Object.keys(headers).length > 0) {
    html += '<div style="margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px solid var(--color-border);"><strong style="font-size: var(--font-size-small); color: var(--color-text-secondary);">响应头：</strong><br>'
    Object.entries(headers).forEach(([key, value]) => {
      html += `<div style="font-size: var(--font-size-small); color: var(--color-text-secondary); margin: 5px 0;">${escapeHtml(key)}: ${escapeHtml(value)}</div>`
    })
    html += '</div>'
  }
  html += `<div style="margin-top: 15px;">${body ? escapeHtml(body) : '(无响应体)'}</div>`
  responseBody.value = html
}

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}
</script>

<style scoped>
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  height: calc(100vh - 200px);
}

.request-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border-bottom: 2px solid var(--color-border);
}

.request-toolbar {
  padding: var(--spacing-md) var(--spacing-lg);
  background: var(--color-background-alt);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  gap: var(--spacing-sm);
  align-items: center;
  flex-shrink: 0;
}

.method-select {
  padding: var(--spacing-sm) var(--spacing-md);
  background: linear-gradient(135deg, #07C160 0%, #42BD56 100%);
  color: var(--color-text-on-primary);
  border: none;
  border-radius: var(--radius-sm);
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-small);
  cursor: pointer;
  min-width: 80px;
}

.url-input {
  flex: 1;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-family: 'Courier New', monospace;
  background: var(--color-surface);
  color: var(--color-text);
}

.url-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.toolbar-buttons {
  display: flex;
  gap: var(--spacing-sm);
}

.btn {
  padding: var(--spacing-sm) var(--spacing-lg);
  border: none;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: all .2s;
}

.btn-primary {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, .4);
}

.btn-secondary {
  background: var(--color-secondary);
  color: var(--color-text-on-primary);
}

.tabs-container {
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.main-tabs {
  display: flex;
  gap: 0;
  padding: 0 20px;
  overflow-x: auto;
}

.main-tab {
  padding: 12px 20px;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  transition: all .2s;
  white-space: nowrap;
}

.main-tab:hover {
  color: var(--color-primary);
  background: var(--color-surface-alt);
}

.main-tab.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
  font-weight: 600;
}

.tab-panel {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}

.body-type-tabs {
  display: flex;
  gap: 5px;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--color-border);
  overflow-x: auto;
}

.body-type-tab {
  padding: 8px 16px;
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  font-size: 13px;
  color: var(--color-text-secondary);
  transition: all .2s;
  white-space: nowrap;
}

.body-type-tab:hover {
  color: var(--color-primary);
}

.body-type-tab.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
  font-weight: 600;
}

.params-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 15px;
}

.params-table th {
  text-align: left;
  padding: 12px;
  background: var(--color-surface-alt);
  border-bottom: 2px solid var(--color-border);
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text-secondary);
}

.params-table td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border);
}

.params-table input,
.params-table select {
  width: 100%;
  padding: 8px;
  border: 1px solid var(--color-border);
  border-radius: 4px;
  font-size: 13px;
  background: var(--color-surface);
  color: var(--color-text);
}

.params-table input:focus,
.params-table select:focus {
  outline: none;
  border-color: var(--color-primary);
}

.param-checkbox {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.file-input-wrapper {
  display: flex;
  gap: 8px;
  align-items: center;
}

.file-select-btn {
  padding: 6px 12px;
  background: var(--color-primary);
  color: var(--color-text-on-primary);
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: var(--font-size-small);
  white-space: nowrap;
}

.file-name {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 150px;
}

.action-buttons {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 10px;
}

.add-param-btn {
  color: var(--color-primary);
  background: none;
  border: none;
  cursor: pointer;
  font-size: 13px;
  text-decoration: underline;
  padding: 5px;
}

.batch-edit-btn {
  display: flex;
  gap: 5px;
  align-items: center;
  color: var(--color-text-secondary);
  background: none;
  border: none;
  cursor: pointer;
  font-size: var(--font-size-small);
  padding: 5px;
}

.batch-edit-btn:hover {
  color: var(--color-primary);
}

.remove-btn {
  background: var(--color-error);
  color: var(--color-text-on-primary);
  border: none;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

.remove-btn:hover {
  background: var(--color-error);
}

.textarea-body {
  width: 100%;
  min-height: 200px;
  padding: 12px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-family: 'Courier New', monospace;
  font-size: 13px;
  resize: vertical;
  background: var(--color-surface);
  color: var(--color-text);
}

.textarea-body:focus {
  outline: none;
  border-color: var(--color-primary);
}

.response-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: var(--color-surface-alt);
}

.response-header {
  padding: 15px 20px;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

.response-header h3 {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
}

.response-status {
  display: flex;
  gap: 15px;
  align-items: center;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
}

.status-success {
  background: var(--color-surface-alt);
  color: var(--color-success);
}

.status-error {
  background: var(--color-surface-alt);
  color: var(--color-error);
}

.status-info {
  background: var(--color-surface-alt);
  color: var(--color-text);
}

.response-body {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: var(--color-surface);
  font-family: 'Courier New', monospace;
  font-size: 13px;
  white-space: pre-wrap;
  word-break: break-all;
}

.empty-response {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: var(--color-text-secondary);
}

.empty-response-icon {
  font-size: 48px;
  margin-bottom: 15px;
  opacity: .5;
}

.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  align-items: center;
  justify-content: center;
}

.modal.active {
  display: flex;
}

.modal-content {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: 0;
  max-width: 700px;
  width: 90%;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, .3);
}

.modal-header {
  padding: 20px 25px;
  border-bottom: 1px solid var(--color-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  font-size: var(--font-size-large);
  color: var(--color-text-secondary);
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--color-text-secondary);
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all .2s;
}

.modal-close:hover {
  background: var(--color-surface-alt);
}

.modal-body {
  padding: var(--spacing-lg);
  flex: 1;
  overflow-y: auto;
}

.modal-footer {
  padding: 15px 25px;
  border-top: 1px solid var(--color-border);
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.batch-mode-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 20px;
  border-bottom: 1px solid var(--color-border);
}

.batch-mode-tab {
  padding: 10px 20px;
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  transition: all .2s;
}

.batch-mode-tab.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
  font-weight: 600;
}

.batch-format-hint {
  background: var(--color-surface-alt);
  padding: 12px;
  border-radius: 6px;
  margin-bottom: 15px;
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  line-height: 1.6;
}

.batch-textarea {
  width: 100%;
  min-height: 200px;
  padding: 12px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-family: 'Courier New', monospace;
  font-size: 13px;
  resize: vertical;
  background: var(--color-surface);
  color: var(--color-text);
}

.batch-textarea:focus {
  outline: none;
  border-color: var(--color-primary);
}
</style>
