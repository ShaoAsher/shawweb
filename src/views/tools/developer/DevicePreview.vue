<template>
  <ToolLayout
    icon="📱"
    title="机型预览信息工具"
    description="查看主流手机机型详细信息，支持模糊搜索，包含最新iPhone 17系列"
  >
    <div class="search-section">
      <div class="search-box">
        <input
          v-model="searchQuery"
          type="text"
          class="search-input"
          placeholder="搜索机型、品牌、型号..."
        />
        <span class="search-icon">🔍</span>
      </div>
      <div class="stats-info">
        <div class="stat-item">
          <strong>总机型数:</strong> <span>{{ totalCount }}</span>
        </div>
        <div class="stat-item">
          <strong>显示数量:</strong> <span>{{ filteredDevices.length }}</span>
        </div>
        <div class="stat-item">
          <strong>数据版本:</strong> <span>{{ lastUpdateTime }}</span>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <div class="loading-spinner"></div>
      <div>正在加载机型数据...</div>
    </div>

    <div v-else-if="filteredDevices.length === 0" class="empty-state">
      <div class="empty-state-icon">📱</div>
      <div class="empty-state-text">未找到匹配的机型</div>
    </div>

    <div v-else class="device-list">
      <div
        v-for="(group, brandIndex) in groupedDevices"
        :key="group.brand"
        class="brand-group"
      >
        <div
          class="brand-group-header"
          @click="toggleBrandGroup(brandIndex)"
        >
          <div class="brand-group-title">
            <img
              :src="getBrandIcon(group.brand)"
              :alt="group.brand"
              class="brand-group-icon"
              @error="handleImageError"
            />
            <span>{{ group.brand }}</span>
            <span class="brand-group-count">({{ group.devices.length }})</span>
          </div>
          <span
            class="brand-group-toggle"
            :class="{ collapsed: collapsedGroups.has(brandIndex) }"
          >
            ▼
          </span>
        </div>
        <div
          class="brand-group-content"
          :class="{ collapsed: collapsedGroups.has(brandIndex) }"
        >
          <div
            v-for="(device, deviceIndex) in group.devices"
            :key="deviceIndex"
            class="device-card"
            @click="showDeviceDetail(device)"
          >
            <div class="device-header">
              <img
                :src="getBrandIcon(device.brand)"
                :alt="device.brand"
                class="brand-icon"
                @error="handleImageError"
              />
              <div class="device-title">
                <div class="device-name">{{ device.name }}</div>
                <div class="device-model">{{ device.model || '-' }}</div>
              </div>
            </div>
            <div class="device-info">
              <div class="info-item">
                <span class="info-label">尺寸</span>
                <span class="info-value">{{ device.size || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">分辨率</span>
                <span class="info-value">{{ device.resolution || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">上市时间</span>
                <span class="info-value full-width">{{ device.releaseDate || '-' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 详细信息弹窗 -->
    <div
      v-if="selectedDevice"
      class="modal-overlay show"
      @click.self="closeModal"
      @keydown.esc="closeModal"
    >
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <div class="modal-title">
            <img
              :src="getBrandIcon(selectedDevice.brand)"
              :alt="selectedDevice.brand"
              style="width: 32px; height: 32px; border-radius: 6px;"
              @error="handleImageError"
            />
            <span>{{ selectedDevice.name }}</span>
          </div>
          <button class="modal-close" @click="closeModal">×</button>
        </div>
        <div class="modal-body">
          <div class="device-image-section">
            <img
              :src="getDeviceImageUrl(selectedDevice)"
              :alt="selectedDevice.name"
              class="device-image"
              @error="handleImageError"
            />
          </div>

          <div class="device-details">
            <div class="detail-section">
              <div class="detail-section-title">基本信息</div>
              <div class="detail-item">
                <span class="detail-label">品牌</span>
                <span class="detail-value">{{ selectedDevice.brand }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">型号</span>
                <span class="detail-value">{{ selectedDevice.model || '-' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">屏幕尺寸</span>
                <span class="detail-value">{{ selectedDevice.size || '-' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">分辨率</span>
                <span class="detail-value">{{ selectedDevice.resolution || '-' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">上市时间</span>
                <span class="detail-value">{{ selectedDevice.releaseDate || '-' }}</span>
              </div>
              <div v-if="selectedDevice.internalModel" class="detail-item">
                <span class="detail-label">内部型号</span>
                <span class="detail-value">{{ selectedDevice.internalModel }}</span>
              </div>
            </div>
          </div>

          <div class="brand-website">
            <div class="brand-website-title">访问 {{ selectedDevice.brand }} 官网了解更多信息</div>
            <a
              :href="getBrandWebsite(selectedDevice.brand)"
              target="_blank"
              class="brand-website-link"
            >
              访问官网 →
            </a>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { computed, onMounted, ref } from 'vue'

const searchQuery = ref('')
const loading = ref(false)
const selectedDevice = ref(null)
const collapsedGroups = ref(new Set())
const lastUpdateTime = ref('2025-09（包含iPhone 17系列）')

// 品牌图标映射
const brandIcons = {
  'Apple': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/apple.svg',
  'Samsung': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/samsung.svg',
  'Huawei': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/huawei.svg',
  'Xiaomi': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/xiaomi.svg',
  'OPPO': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/oppo.svg',
  'vivo': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/vivo.svg',
  'OnePlus': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/oneplus.svg',
  'Realme': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/realme.svg',
  'Honor': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/honor.svg',
  'Google': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/google.svg',
  'Sony': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/sony.svg',
  'LG': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/lg.svg',
  'Motorola': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/motorola.svg',
  'Nokia': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/nokia.svg',
  'Redmi': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/xiaomi.svg',
  'Meizu': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/meizu.svg',
  'Lenovo': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/lenovo.svg',
  'ZTE': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/zte.svg',
  'ASUS': 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/asus.svg'
}

// 品牌官网映射
const brandWebsites = {
  'Apple': 'https://www.apple.com.cn',
  'Samsung': 'https://www.samsung.com.cn',
  'Huawei': 'https://www.huawei.com/cn',
  'Xiaomi': 'https://www.mi.com',
  'OPPO': 'https://www.oppo.com/cn',
  'vivo': 'https://www.vivo.com.cn',
  'OnePlus': 'https://www.oneplus.com/cn',
  'Realme': 'https://www.realme.com/cn',
  'Honor': 'https://www.hihonor.com/cn',
  'Google': 'https://store.google.com',
  'Sony': 'https://www.sony.com.cn',
  'LG': 'https://www.lg.com/cn',
  'Motorola': 'https://www.motorola.com.cn',
  'Nokia': 'https://www.nokia.com',
  'Redmi': 'https://www.mi.com',
  'Meizu': 'https://www.meizu.com',
  'Lenovo': 'https://www.lenovo.com.cn',
  'ZTE': 'https://www.zte.com.cn',
  'ASUS': 'https://www.asus.com.cn'
}

// 品牌排序优先级
const brandSortOrder = {
  'Apple': 1,
  'Huawei': 2,
  'Xiaomi': 3,
  'OPPO': 4,
  'vivo': 5,
  'OnePlus': 6,
  'ASUS': 7,
  'Samsung': 8
}

// 设备数据（包含最新iPhone 17系列）
const deviceData = ref([
  // Apple - iPhone 17系列
  { brand: 'Apple', name: 'iPhone 17 Pro Max', model: 'A3526', internalModel: 'iPhone18,2', size: '6.9英寸', resolution: '3200×1440', releaseDate: '2025-09' },
  { brand: 'Apple', name: 'iPhone 17 Pro', model: 'A3521', internalModel: 'iPhone18,1', size: '6.3英寸', resolution: '2800×1260', releaseDate: '2025-09' },
  { brand: 'Apple', name: 'iPhone 17', model: 'A3520', internalModel: 'iPhone18,3', size: '6.1英寸', resolution: '2556×1179', releaseDate: '2025-09' },
  { brand: 'Apple', name: 'iPhone 17 Plus', model: 'A3522', internalModel: 'iPhone17,4', size: '6.7英寸', resolution: '2796×1290', releaseDate: '2025-09' },
  { brand: 'Apple', name: 'iPhone Air', model: 'A3517', internalModel: 'iPhone18,4', size: '6.5英寸', resolution: '2778×1284', releaseDate: '2025-09' },
  // Apple - iPhone 16系列
  { brand: 'Apple', name: 'iPhone 16 Pro Max', model: 'A2901', internalModel: 'iPhone17,2', size: '6.9英寸', resolution: '3200×1440', releaseDate: '2024-09' },
  { brand: 'Apple', name: 'iPhone 16 Pro', model: 'A2895', internalModel: 'iPhone17,1', size: '6.3英寸', resolution: '2800×1260', releaseDate: '2024-09' },
  { brand: 'Apple', name: 'iPhone 16', model: 'A2893', internalModel: 'iPhone17,3', size: '6.1英寸', resolution: '2556×1179', releaseDate: '2024-09' },
  { brand: 'Apple', name: 'iPhone 16 Plus', model: 'A2894', internalModel: 'iPhone17,4', size: '6.7英寸', resolution: '2796×1290', releaseDate: '2024-09' },
  { brand: 'Apple', name: 'iPhone 16e', model: 'A2897', internalModel: 'iPhone17,5', size: '6.1英寸', resolution: '2556×1179', releaseDate: '2024-09' },
  // Apple - iPhone 15系列
  { brand: 'Apple', name: 'iPhone 15 Pro Max', model: 'A3101', size: '6.7英寸', resolution: '2796×1290', releaseDate: '2023-09', internalModel: 'iPhone16,2' },
  { brand: 'Apple', name: 'iPhone 15 Pro', model: 'A3102', size: '6.1英寸', resolution: '2556×1179', releaseDate: '2023-09', internalModel: 'iPhone16,1' },
  { brand: 'Apple', name: 'iPhone 15 Plus', model: 'A3104', size: '6.7英寸', resolution: '2796×1290', releaseDate: '2023-09', internalModel: 'iPhone15,5' },
  { brand: 'Apple', name: 'iPhone 15', model: 'A3103', size: '6.1英寸', resolution: '2556×1179', releaseDate: '2023-09', internalModel: 'iPhone15,4' },
  // Apple - iPhone 14系列
  { brand: 'Apple', name: 'iPhone 14 Pro Max', model: 'A2896', size: '6.7英寸', resolution: '2796×1290', releaseDate: '2022-09', internalModel: 'iPhone15,3' },
  { brand: 'Apple', name: 'iPhone 14 Pro', model: 'A2892', size: '6.1英寸', resolution: '2556×1179', releaseDate: '2022-09', internalModel: 'iPhone15,2' },
  { brand: 'Apple', name: 'iPhone 14 Plus', model: 'A2888', size: '6.7英寸', resolution: '2778×1284', releaseDate: '2022-09', internalModel: 'iPhone14,8' },
  { brand: 'Apple', name: 'iPhone 14', model: 'A2882', size: '6.1英寸', resolution: '2532×1170', releaseDate: '2022-09', internalModel: 'iPhone14,7' },
  // Apple - iPhone 13系列
  { brand: 'Apple', name: 'iPhone 13 Pro Max', model: 'A2643', size: '6.7英寸', resolution: '2778×1284', releaseDate: '2021-09', internalModel: 'iPhone14,3' },
  { brand: 'Apple', name: 'iPhone 13 Pro', model: 'A2639', size: '6.1英寸', resolution: '2532×1170', releaseDate: '2021-09', internalModel: 'iPhone14,2' },
  { brand: 'Apple', name: 'iPhone 13 mini', model: 'A2629', size: '5.4英寸', resolution: '2340×1080', releaseDate: '2021-09', internalModel: 'iPhone14,4' },
  { brand: 'Apple', name: 'iPhone 13', model: 'A2634', size: '6.1英寸', resolution: '2532×1170', releaseDate: '2021-09', internalModel: 'iPhone14,5' },
  // Apple - iPhone 12系列
  { brand: 'Apple', name: 'iPhone 12 Pro Max', model: 'A2412', size: '6.7英寸', resolution: '2778×1284', releaseDate: '2020-10', internalModel: 'iPhone13,4' },
  { brand: 'Apple', name: 'iPhone 12 Pro', model: 'A2408', size: '6.1英寸', resolution: '2532×1170', releaseDate: '2020-10', internalModel: 'iPhone13,3' },
  { brand: 'Apple', name: 'iPhone 12 mini', model: 'A2399', size: '5.4英寸', resolution: '2340×1080', releaseDate: '2020-10', internalModel: 'iPhone13,1' },
  { brand: 'Apple', name: 'iPhone 12', model: 'A2404', size: '6.1英寸', resolution: '2532×1170', releaseDate: '2020-10', internalModel: 'iPhone13,2' },
  // Apple - iPhone SE系列
  { brand: 'Apple', name: 'iPhone SE (第三代)', model: 'A2785', size: '4.7英寸', resolution: '1334×750', releaseDate: '2022-03', internalModel: 'iPhone14,6' },
  { brand: 'Apple', name: 'iPhone SE (第二代)', model: 'A2275', size: '4.7英寸', resolution: '1334×750', releaseDate: '2020-04', internalModel: 'iPhone12,8' },
  // Apple - iPhone 11系列
  { brand: 'Apple', name: 'iPhone 11 Pro Max', model: 'A2161', size: '6.5英寸', resolution: '2688×1242', releaseDate: '2019-09', internalModel: 'iPhone12,5' },
  { brand: 'Apple', name: 'iPhone 11 Pro', model: 'A2160', size: '5.8英寸', resolution: '2436×1125', releaseDate: '2019-09', internalModel: 'iPhone12,3' },
  { brand: 'Apple', name: 'iPhone 11', model: 'A2221', size: '6.1英寸', resolution: '1792×828', releaseDate: '2019-09', internalModel: 'iPhone12,1' },
  // Samsung
  { brand: 'Samsung', name: 'Galaxy S24 Ultra', model: 'SM-S928', size: '6.8英寸', resolution: '3120×1440', releaseDate: '2024-01' },
  { brand: 'Samsung', name: 'Galaxy S24+', model: 'SM-S926', size: '6.7英寸', resolution: '2340×1080', releaseDate: '2024-01' },
  { brand: 'Samsung', name: 'Galaxy S24', model: 'SM-S921', size: '6.2英寸', resolution: '2340×1080', releaseDate: '2024-01' },
  { brand: 'Samsung', name: 'Galaxy S23 Ultra', model: 'SM-S918', size: '6.8英寸', resolution: '3088×1440', releaseDate: '2023-02' },
  { brand: 'Samsung', name: 'Galaxy S23+', model: 'SM-S916', size: '6.6英寸', resolution: '2340×1080', releaseDate: '2023-02' },
  { brand: 'Samsung', name: 'Galaxy S23', model: 'SM-S911', size: '6.1英寸', resolution: '2340×1080', releaseDate: '2023-02' },
  { brand: 'Samsung', name: 'Galaxy Z Fold5', model: 'SM-F946', size: '7.6英寸', resolution: '2176×1812', releaseDate: '2023-08' },
  { brand: 'Samsung', name: 'Galaxy Z Flip5', model: 'SM-F731', size: '6.7英寸', resolution: '2640×1080', releaseDate: '2023-08' },
  // Huawei
  { brand: 'Huawei', name: 'Mate 60 Pro+', model: 'ALN-AL10', size: '6.82英寸', resolution: '2720×1260', releaseDate: '2023-09' },
  { brand: 'Huawei', name: 'Mate 60 Pro', model: 'ALN-AL00', size: '6.82英寸', resolution: '2720×1260', releaseDate: '2023-08' },
  { brand: 'Huawei', name: 'Mate 60', model: 'BRA-AL00', size: '6.69英寸', resolution: '2688×1216', releaseDate: '2023-08' },
  { brand: 'Huawei', name: 'P60 Pro', model: 'ALN-AL00', size: '6.67英寸', resolution: '2700×1220', releaseDate: '2023-03' },
  { brand: 'Huawei', name: 'P60', model: 'LNA-AL00', size: '6.67英寸', resolution: '2700×1220', releaseDate: '2023-03' },
  // Xiaomi
  { brand: 'Xiaomi', name: 'Xiaomi 14 Ultra', model: '24030PN60G', size: '6.73英寸', resolution: '3200×1440', releaseDate: '2024-02' },
  { brand: 'Xiaomi', name: 'Xiaomi 14 Pro', model: '23127PN0CC', size: '6.73英寸', resolution: '3200×1440', releaseDate: '2023-10' },
  { brand: 'Xiaomi', name: 'Xiaomi 14', model: '23127PN0CG', size: '6.36英寸', resolution: '2670×1200', releaseDate: '2023-10' },
  { brand: 'Xiaomi', name: 'Xiaomi 13 Ultra', model: '2304FPN6DC', size: '6.73英寸', resolution: '3200×1440', releaseDate: '2023-04' },
  // Redmi
  { brand: 'Redmi', name: 'Redmi K70 Pro', model: '2311DRK48C', size: '6.67英寸', resolution: '3200×1440', releaseDate: '2023-11' },
  { brand: 'Redmi', name: 'Redmi K70', model: '2311DRK48C', size: '6.67英寸', resolution: '3200×1440', releaseDate: '2023-11' },
  // OPPO
  { brand: 'OPPO', name: 'Find X7 Ultra', model: 'CPH2609', size: '6.82英寸', resolution: '3168×1440', releaseDate: '2024-01' },
  { brand: 'OPPO', name: 'Find X7', model: 'CPH2607', size: '6.78英寸', resolution: '2780×1264', releaseDate: '2024-01' },
  { brand: 'OPPO', name: 'Find X6 Pro', model: 'CPH2305', size: '6.82英寸', resolution: '3168×1440', releaseDate: '2023-03' },
  // vivo
  { brand: 'vivo', name: 'X100 Pro', model: 'V2309A', size: '6.78英寸', resolution: '2800×1260', releaseDate: '2023-11' },
  { brand: 'vivo', name: 'X100', model: 'V2309A', size: '6.78英寸', resolution: '2800×1260', releaseDate: '2023-11' },
  { brand: 'vivo', name: 'X90 Pro+', model: 'V2227A', size: '6.78英寸', resolution: '3200×1440', releaseDate: '2022-11' },
  // OnePlus
  { brand: 'OnePlus', name: 'OnePlus 12', model: 'CPH2581', size: '6.82英寸', resolution: '3168×1440', releaseDate: '2024-01' },
  { brand: 'OnePlus', name: 'OnePlus 11', model: 'CPH2449', size: '6.7英寸', resolution: '3216×1440', releaseDate: '2023-01' },
  // Honor
  { brand: 'Honor', name: 'Magic6 Pro', model: 'BVL-AN16', size: '6.8英寸', resolution: '2800×1280', releaseDate: '2024-01' },
  { brand: 'Honor', name: 'Magic6', model: 'BVL-AN00', size: '6.78英寸', resolution: '2800×1280', releaseDate: '2024-01' },
  // Google
  { brand: 'Google', name: 'Pixel 8 Pro', model: 'GE9DP', size: '6.7英寸', resolution: '2992×1344', releaseDate: '2023-10' },
  { brand: 'Google', name: 'Pixel 8', model: 'G9BQD', size: '6.2英寸', resolution: '2400×1080', releaseDate: '2023-10' },
  // Realme
  { brand: 'Realme', name: 'GT5 Pro', model: 'RMX3888', size: '6.78英寸', resolution: '2780×1264', releaseDate: '2023-12' },
  // Sony
  { brand: 'Sony', name: 'Xperia 1 V', model: 'XQ-DQ72', size: '6.5英寸', resolution: '3840×1644', releaseDate: '2023-05' },
  // ASUS
  { brand: 'ASUS', name: 'ROG Phone 8 Pro', model: 'AI2401', size: '6.78英寸', resolution: '2448×1080', releaseDate: '2024-01' }
])

const totalCount = computed(() => deviceData.value.length)

const filteredDevices = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  if (!keyword) {
    return deviceData.value
  }

  return deviceData.value.filter(device => {
    return (
      device.brand.toLowerCase().includes(keyword) ||
      device.brand.includes(keyword) ||
      device.name.toLowerCase().includes(keyword) ||
      device.name.includes(keyword) ||
      device.model?.toLowerCase().includes(keyword) ||
      device.model?.includes(keyword) ||
      device.size?.toLowerCase().includes(keyword) ||
      device.size?.includes(keyword) ||
      device.resolution?.toLowerCase().includes(keyword) ||
      device.resolution?.includes(keyword) ||
      device.releaseDate?.toLowerCase().includes(keyword) ||
      device.releaseDate?.includes(keyword)
    )
  })
})

const groupedDevices = computed(() => {
  const grouped = {}
  filteredDevices.value.forEach(device => {
    if (!grouped[device.brand]) {
      grouped[device.brand] = []
    }
    grouped[device.brand].push(device)
  })

  const sortedBrands = Object.keys(grouped).sort((a, b) => {
    const orderA = brandSortOrder[a] || 999
    const orderB = brandSortOrder[b] || 999
    if (orderA !== orderB) {
      return orderA - orderB
    }
    return a.localeCompare(b)
  })

  return sortedBrands.map(brand => ({
    brand,
    devices: grouped[brand]
  }))
})

function getBrandIcon(brand) {
  return brandIcons[brand] || 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/android.svg'
}

function getBrandWebsite(brand) {
  return brandWebsites[brand] || '#'
}

function getDeviceImageUrl(device) {
  return `https://via.placeholder.com/400x600/667eea/ffffff?text=${encodeURIComponent(device.name)}`
}

function handleImageError(event) {
  event.target.src = 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/android.svg'
}

function toggleBrandGroup(brandIndex) {
  if (collapsedGroups.value.has(brandIndex)) {
    collapsedGroups.value.delete(brandIndex)
  } else {
    collapsedGroups.value.add(brandIndex)
  }
}

function showDeviceDetail(device) {
  selectedDevice.value = device
  document.body.style.overflow = 'hidden'
}

function closeModal() {
  selectedDevice.value = null
  document.body.style.overflow = ''
}

onMounted(() => {
  loading.value = false
})
</script>

<style scoped>
.search-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.search-box {
  position: relative;
  margin-bottom: var(--spacing-md);
}

.search-input {
  width: 100%;
  padding: var(--spacing-sm) 50px var(--spacing-sm) var(--spacing-lg);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  transition: border-color .3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.search-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.search-icon {
  position: absolute;
  right: var(--spacing-lg);
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-secondary);
  font-size: var(--font-size-large);
}

.stats-info {
  display: flex;
  gap: var(--spacing-lg);
  flex-wrap: wrap;
  margin-top: var(--spacing-md);
}

.stat-item {
  background: var(--color-surface);
  padding: var(--spacing-sm) var(--spacing-lg);
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  font-size: var(--font-size-small);
  color: var(--color-text);
}

.stat-item strong {
  color: var(--color-primary);
  margin-right: var(--spacing-xs);
}

.device-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.brand-group {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  overflow: hidden;
}

.brand-group-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 15px;
  background: var(--color-surface-alt);
  border-bottom: 1px solid var(--color-border);
  cursor: pointer;
  transition: background .2s;
}

.brand-group-header:hover {
  background: var(--color-hover);
}

.brand-group-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
  color: var(--color-text);
  font-size: 14px;
}

.brand-group-icon {
  width: 24px;
  height: 24px;
  border-radius: 4px;
  object-fit: contain;
  background: var(--color-surface);
  padding: 2px;
  border: 1px solid var(--color-border);
}

.brand-group-count {
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
  font-weight: normal;
  margin-left: 8px;
}

.brand-group-toggle {
  color: var(--color-text-secondary);
  font-size: var(--font-size-large);
  transition: transform .3s;
  user-select: none;
}

.brand-group-toggle.collapsed {
  transform: rotate(-90deg);
}

.brand-group-content {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 8px;
  padding: 10px;
  transition: all .3s;
}

.brand-group-content.collapsed {
  display: none;
}

.device-card {
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-radius: 6px;
  padding: 8px;
  transition: all .2s;
  cursor: pointer;
}

.device-card:hover {
  border-color: var(--color-primary);
  box-shadow: 0 2px 8px var(--color-shadow-primary);
  transform: translateY(-1px);
  background: var(--color-hover);
}

.device-header {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  margin-bottom: 6px;
}

.brand-icon {
  width: 20px;
  height: 20px;
  border-radius: 4px;
  object-fit: contain;
  background: var(--color-surface);
  padding: 2px;
  border: 1px solid var(--color-border);
  flex-shrink: 0;
  margin-top: 2px;
}

.device-title {
  flex: 1;
  min-width: 0;
}

.device-name {
  font-size: var(--font-size-small);
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 2px;
  line-height: 1.3;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
}

.device-model {
  font-size: 10px;
  color: var(--color-text-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4px;
}

.device-info {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 6px;
  margin-top: 4px;
  padding-top: 4px;
  border-top: 1px solid var(--color-border);
}

.info-item {
  display: flex;
  flex-direction: column;
}

.info-label {
  font-size: 9px;
  color: var(--color-text-secondary);
  margin-bottom: 1px;
}

.info-value {
  font-size: 10px;
  color: var(--color-text);
  font-weight: 500;
  line-height: 1.3;
}

.info-value.full-width {
  grid-column: 1 / -1;
}

.loading {
  text-align: center;
  padding: var(--spacing-xl);
  color: var(--color-text-secondary);
}

.loading-spinner {
  border: 4px solid var(--color-border);
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% { transform: rotate(0); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: var(--color-text-secondary);
}

.empty-state-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: .5;
}

.empty-state-text {
  font-size: 16px;
}

.modal-overlay {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 1000;
  overflow-y: auto;
  padding: 20px;
  animation: fadeIn 0.3s;
}

.modal-overlay.show {
  display: flex;
  align-items: center;
  justify-content: center;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  animation: slideUp 0.3s;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

@keyframes slideUp {
  from {
    transform: translateY(50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  padding: 20px 25px;
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: sticky;
  top: 0;
  background: var(--color-surface);
  z-index: 10;
}

.modal-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--color-text);
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-close {
  width: 32px;
  height: 32px;
  border: none;
  background: var(--color-surface-alt);
  border-radius: 50%;
  cursor: pointer;
  font-size: 20px;
  color: var(--color-text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.modal-close:hover {
  background: var(--color-surface-alt);
  color: var(--color-text);
}

.modal-body {
  padding: 25px;
}

.device-image-section {
  text-align: center;
  margin-bottom: 25px;
}

.device-image {
  max-width: 100%;
  max-height: 400px;
  border-radius: var(--radius-md);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.device-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 25px;
}

.detail-section {
  background: var(--color-surface-alt);
  border-radius: var(--radius-md);
  padding: 15px;
}

.detail-section-title {
  font-size: var(--font-size-small);
  font-weight: 600;
  color: var(--color-primary);
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 2px solid var(--color-primary);
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid var(--color-border);
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-label {
  font-size: 13px;
  color: var(--color-text-secondary);
  font-weight: 500;
}

.detail-value {
  font-size: 13px;
  color: var(--color-text);
  font-weight: 500;
  text-align: right;
  max-width: 60%;
}

.brand-website {
  margin-top: var(--spacing-lg);
  padding-top: 20px;
  border-top: 2px solid var(--color-border);
  text-align: center;
}

.brand-website-title {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-bottom: 12px;
}

.brand-website-link {
  display: inline-block;
  padding: 10px 20px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  text-decoration: none;
  border-radius: var(--radius-sm);
  font-weight: 500;
  transition: all 0.3s;
}

.brand-website-link:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px var(--color-shadow-primary);
}
</style>
