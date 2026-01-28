<template>
  <ToolLayout
    icon="📅"
    title="中国日历"
    description="查看农历日期、节气、节日、宜忌和历史上的今天"
  >
    <div class="chinese-calendar">
      <!-- 日历区域 -->
      <div class="calendar-section">
        <div class="calendar-header">
          <button class="nav-button" @click="previousMonth" title="上一月">‹</button>
          <h2 ref="titleRef" class="calendar-title" @click="showDatePicker" title="点击选择日期">
            {{ currentYear }}年{{ currentMonth }}月
          </h2>
          <button class="nav-button" @click="nextMonth" title="下一月">›</button>
        </div>
        <!-- 隐藏的日期输入框 -->
        <input
          ref="dateInputRef"
          type="date"
          class="hidden-date-input"
          :min="'1900-01-01'"
          :max="'2100-12-31'"
          @change="handleDateChange"
        />
        <div class="calendar-grid">
          <div class="calendar-weekdays">
            <div v-for="day in weekdays" :key="day" class="weekday">
              {{ day }}
            </div>
          </div>
          <div class="calendar-days">
            <div
              v-for="(date, index) in calendarDays"
              :key="index"
              :class="[
                'calendar-day',
                {
                  'other-month': !date.isCurrentMonth,
                  'today': date.isToday,
                  'selected': date.isSelected,
                  'holiday': date.isHoliday
                }
              ]"
              @click="selectDate(date)"
            >
              <div class="day-number">{{ date.day }}</div>
              <div class="day-lunar">{{ date.lunar }}</div>
              <div v-if="date.festival" class="day-festival">{{ date.festival }}</div>
              <div v-if="date.holidayBadge" class="day-badge" :class="date.holidayBadge">
                {{ date.holidayBadge === 'work' ? '班' : '休' }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 自定义日期选择器弹窗 -->
      <Teleport to="body">
        <transition name="date-picker-fade">
          <div v-if="showDatePickerModal" class="date-picker-overlay" @click.self="closeDatePicker">
            <div class="date-picker-modal">
              <div class="date-picker-header">
                <h3>选择日期</h3>
                <button class="date-picker-close" @click="closeDatePicker">×</button>
              </div>
              <div class="date-picker-content">
                <input
                  ref="modalDateInputRef"
                  type="date"
                  class="date-picker-input"
                  :min="'1900-01-01'"
                  :max="'2100-12-31'"
                  :value="datePickerValue"
                  @change="handleModalDateChange"
                />
              </div>
            </div>
          </div>
        </transition>
      </Teleport>

      <!-- 详情区域 -->
      <div class="detail-section">
        <!-- 今日详情卡片 -->
        <div class="detail-card">
          <div class="lunar-header">
            <div class="lunar-date">
              <div class="lunar-date-main">{{ lunarDateStr }}</div>
              <div class="lunar-year">{{ lunarYearStr }} [{{ zodiacStr }}年]</div>
            </div>
            <div v-if="festivalStr" class="festival-badge">
              {{ festivalStr }}
            </div>
          </div>
          <div class="divider"></div>
          <div class="yiji-section">
            <div class="yiji-item yi">
              <div class="yiji-label">宜</div>
              <div class="yiji-content">{{ yiStr || '无' }}</div>
            </div>
            <div class="yiji-item ji">
              <div class="yiji-label">忌</div>
              <div class="yiji-content">{{ jiStr || '无' }}</div>
            </div>
          </div>
        </div>

        <!-- 历史上的今天 -->
        <div class="history-section">
          <h3 class="history-title">
            <span>📚</span>
            <span>历史上的今天</span>
          </h3>
          <div v-if="isLoadingHistory" class="loading">
            <div class="loading-spinner"></div>
            <div>加载中...</div>
          </div>
          <div v-else-if="historyEvents.length === 0" class="empty-history">
            暂无历史事件数据
          </div>
          <div v-else class="history-list">
            <div
              v-for="(event, index) in historyEvents"
              :key="index"
              class="history-item"
            >
              <div class="history-year">{{ event.year }}</div>
              <div class="history-content">
                <div class="history-title-text">{{ event.title }}</div>
                <div class="history-desc">{{ event.desc }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick, onUnmounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import { Solar, Lunar, HolidayUtil } from 'lunar-javascript'
import { getHolidayInfo, fetchHolidayDataFromAPI } from '@/utils/holiday-data'

// 状态
const currentDate = ref(new Date())
const selectedDate = ref(new Date())
const dateInputRef = ref(null)
const titleRef = ref(null)
const showDatePickerModal = ref(false)
const modalDateInputRef = ref(null)

// 农历信息
const lunarDateStr = ref('')
const lunarYearStr = ref('')
const zodiacStr = ref('')
const festivalStr = ref('')
const yiStr = ref('')
const jiStr = ref('')

// 历史上的今天
const historyEvents = ref([])
const isLoadingHistory = ref(false)

// 节假日数据缓存
const holidayDataCache = ref({})

// 周几
const weekdays = ['日', '一', '二', '三', '四', '五', '六']

// 计算属性
const currentYear = computed(() => currentDate.value.getFullYear())
const currentMonth = computed(() => currentDate.value.getMonth() + 1)

const calendarDays = computed(() => {
  const year = currentYear.value
  const month = currentMonth.value
  const firstDay = new Date(year, month - 1, 1)
  const lastDay = new Date(year, month, 0)
  const daysInMonth = lastDay.getDate()
  const startWeekday = firstDay.getDay()

  const days = []
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const selected = new Date(selectedDate.value)
  selected.setHours(0, 0, 0, 0)

  // 上个月的日期
  const prevMonthLastDay = new Date(year, month - 1, 0).getDate()
  for (let i = startWeekday - 1; i >= 0; i--) {
    const day = prevMonthLastDay - i
    const date = new Date(year, month - 2, day)
    days.push(createDayData(date, false, today, selected))
  }

  // 当前月的日期
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month - 1, day)
    days.push(createDayData(date, true, today, selected))
  }

  // 下个月的日期（填满6行）
  const remainingDays = 42 - days.length
  for (let day = 1; day <= remainingDays; day++) {
    const date = new Date(year, month, day)
    days.push(createDayData(date, false, today, selected))
  }

  return days
})

// 方法
const createDayData = (date, isCurrentMonth, today, selected) => {
  const day = date.getDate()
  const lunar = getLunarDay(date)
  const festival = getFestival(date)
  const isToday = date.getTime() === today.getTime()
  const isSelected = date.getTime() === selected.getTime()
  const holidayInfo = getHolidayInfoForDate(date)
  const isHoliday = holidayInfo && !holidayInfo.isWork
  const holidayBadge = holidayInfo ? (holidayInfo.isWork ? 'work' : 'rest') : null

  return {
    date,
    day,
    lunar,
    festival,
    isCurrentMonth,
    isToday,
    isSelected,
    isHoliday,
    holidayBadge
  }
}

const getLunarDay = (date) => {
  try {
    const solar = Solar.fromDate(date)
    const lunar = solar.getLunar()
    const dayStr = lunar.getDayInChinese()
    if (dayStr === '初一') {
      return lunar.getMonthInChinese() + '月'
    }
    return dayStr
  } catch (e) {
    return ''
  }
}

const getFestival = (date) => {
  try {
    const solar = Solar.fromDate(date)
    const lunar = solar.getLunar()
    
    // 优先显示节日，其次节气
    const festivals = []
    festivals.push(...solar.getFestivals())
    festivals.push(...lunar.getFestivals())
    
    if (festivals.length > 0) {
      const festival = festivals[0]
      return festival.length > 4 ? festival.substring(0, 3) + '..' : festival
    }
    
    // 获取节气
    const jieqi = lunar.getJieQi()
    if (jieqi) {
      return jieqi
    }
    
    return ''
  } catch (e) {
    const month = date.getMonth() + 1
    const day = date.getDate()
    return getFestivalNameByDate(month, day)
  }
}

const getHolidayInfoForDate = (date) => {
  // 先检查缓存
  const dateStr = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  
  // 如果缓存中有，直接返回
  if (holidayDataCache.value[dateStr]) {
    return holidayDataCache.value[dateStr]
  }
  
  // 使用 HolidayUtil 获取节假日信息（与Flutter项目一致）
  try {
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    
    // HolidayUtil.getHoliday 可以接受字符串 'YYYY-MM-DD' 或三个参数 (year, month, day)
    const holiday = HolidayUtil.getHoliday(year, month, day)
    
    if (holiday) {
      const info = {
        isWork: holiday.isWork(),
        name: holiday.getName() || (holiday.isWork() ? '调休' : '节假日')
      }
      // 缓存结果
      holidayDataCache.value[dateStr] = info
      return info
    }
  } catch (e) {
    // 如果HolidayUtil不可用，静默失败
  }
  
  return null
}

const selectDate = (dayData) => {
  selectedDate.value = new Date(dayData.date)
  updateDateInfo(selectedDate.value)
}

const previousMonth = () => {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() - 1, 1)
}

const nextMonth = () => {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() + 1, 1)
}

const datePickerValue = computed(() => {
  return `${currentYear.value}-${String(currentMonth.value).padStart(2, '0')}-${String(selectedDate.value.getDate()).padStart(2, '0')}`
})

const showDatePicker = () => {
  showDatePickerModal.value = true
  // 等待 DOM 更新后触发日期选择器
  nextTick(() => {
    if (modalDateInputRef.value) {
      setTimeout(() => {
        try {
          if (typeof modalDateInputRef.value.showPicker === 'function') {
            modalDateInputRef.value.showPicker().catch(() => {
              modalDateInputRef.value.click()
            })
          } else {
            modalDateInputRef.value.click()
          }
        } catch (e) {
          modalDateInputRef.value.click()
        }
      }, 100)
    }
  })
}

const closeDatePicker = () => {
  showDatePickerModal.value = false
}

const handleModalDateChange = (e) => {
  if (e.target.value) {
    const selected = new Date(e.target.value)
    currentDate.value = selected
    selectedDate.value = selected
    updateDateInfo(selected)
  }
  closeDatePicker()
}

const handleDateChange = (e) => {
  if (e.target.value) {
    const selected = new Date(e.target.value)
    currentDate.value = selected
    selectedDate.value = selected
    updateDateInfo(selected)
  }
}

const updateDateInfo = async (date) => {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  try {
    // 使用 lunar-javascript 库（与Flutter项目一致）
    const solar = Solar.fromDate(date)
    const lunar = solar.getLunar()

    // 农历日期
    lunarDateStr.value = `${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`
    lunarYearStr.value = `${lunar.getYearInGanZhi()}年`
    zodiacStr.value = lunar.getYearShengXiao()

    // 节日
    const festivals = []
    festivals.push(...solar.getFestivals()) // 阳历节日
    festivals.push(...lunar.getFestivals()) // 农历节日
    
    // 节气
    const jieqi = lunar.getJieQi()
    if (jieqi) {
      festivals.push(jieqi)
    }
    
    festivalStr.value = festivals.length > 0 ? festivals.join(' ') : ''

    // 宜忌
    const yi = lunar.getDayYi()
    yiStr.value = Array.isArray(yi) ? yi.join(' ') : (yi || '')
    
    const ji = lunar.getDayJi()
    jiStr.value = Array.isArray(ji) ? ji.join(' ') : (ji || '')

    // 获取历史上的今天
    fetchHistoryToday(date)
  } catch (e) {
    console.error('Error updating date info:', e)
    // 使用备用方案
    lunarDateStr.value = `${month}月${day}日`
    lunarYearStr.value = `${getGanZhiByYear(year)}年`
    zodiacStr.value = getZodiacByYear(year)
    festivalStr.value = getFestivalNameByDate(month, day)
    yiStr.value = ''
    jiStr.value = ''
    fetchHistoryToday(date)
  }
}

// 备用函数：根据年份获取生肖
const getZodiacByYear = (year) => {
  const zodiacs = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪']
  return zodiacs[(year - 4) % 12]
}

// 备用函数：根据年份获取天干地支
const getGanZhiByYear = (year) => {
  const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']
  const zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']
  return gan[(year - 4) % 10] + zhi[(year - 4) % 12]
}

// 备用函数：简化的农历日期计算（基于已知数据）
const getFallbackLunarDate = (year, month, day) => {
  // 这里可以添加一些已知的农历日期映射
  // 为了简化，返回基本信息
  return {
    date: '', // 留空，让界面显示公历
    festival: '',
    yi: '',
    ji: ''
  }
}

// 备用函数：根据日期获取节日名称
const getFestivalNameByDate = (month, day) => {
  const festivals = {
    '01-01': '元旦',
    '02-14': '情人节',
    '03-08': '妇女节',
    '03-12': '植树节',
    '04-01': '愚人节',
    '05-01': '劳动节',
    '05-04': '青年节',
    '06-01': '儿童节',
    '07-01': '建党节',
    '08-01': '建军节',
    '09-10': '教师节',
    '10-01': '国庆节',
    '12-25': '圣诞节'
  }
  const key = `${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
  return festivals[key] || ''
}

// 不再需要loadLunarLib，因为已经通过npm安装并直接导入

const fetchHolidayData = async () => {
  // 从API获取节假日数据
  try {
    const year = currentYear.value
    
    // 获取整年重要节假日数据（包含静态数据和API数据）
    const yearData = await fetchHolidayDataFromAPI(year)
    holidayDataCache.value = { ...holidayDataCache.value, ...yearData }
    
    // 静态数据已经包含了大部分节假日，API只是补充
    // 不再需要逐个查询当前月份，减少请求
  } catch (e) {
    console.error('Failed to fetch holiday data:', e)
    // 即使API失败，静态数据仍然可用
  }
}

const fetchHistoryToday = async (date) => {
  isLoadingHistory.value = true
  historyEvents.value = []

  try {
    const month = date.getMonth() + 1
    const day = date.getDate()
    const url = `https://baike.baidu.com/cms/home/eventsOnHistory/${month.toString().padStart(2, '0')}.json`

    const response = await fetch(url)
    if (response.ok) {
      const data = await response.json()
      const monthKey = month.toString().padStart(2, '0')
      const dayKey = monthKey + day.toString().padStart(2, '0')

      if (data[monthKey] && data[monthKey][dayKey]) {
        const events = data[monthKey][dayKey]
        historyEvents.value = events
          .map((e) => ({
            year: e.year || '',
            title: cleanHtml(e.title || ''),
            desc: cleanHtml(e.desc || '')
          }))
          .sort((a, b) => {
            const yearA = parseInt(a.year) || 0
            const yearB = parseInt(b.year) || 0
            return yearB - yearA
          })
      }
    }
  } catch (e) {
    console.error('Failed to fetch history:', e)
  } finally {
    isLoadingHistory.value = false
  }
}

const cleanHtml = (html) => {
  if (!html) return ''
  return html.replace(/<[^>]*>/g, '').trim()
}

// 监听月份变化，重新获取节假日数据
watch([currentYear, currentMonth], () => {
  fetchHolidayData()
})

// 监听 ESC 键关闭弹窗
const handleEsc = (e) => {
  if (e.key === 'Escape' && showDatePickerModal.value) {
    closeDatePicker()
  }
}

// 生命周期
onMounted(async () => {
  await fetchHolidayData()
  updateDateInfo(selectedDate.value)
  window.addEventListener('keydown', handleEsc)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleEsc)
})
</script>

<style scoped>
.chinese-calendar {
  padding: 24px 16px;
  width: 100%;
  margin: 0 auto;
}

/* 日历区域 */
.calendar-section {
  background: var(--color-surface-variant, rgba(255, 255, 255, 0.1));
  border-radius: 12px;
  padding: 10px;
  margin-bottom: 20px;
  backdrop-filter: blur(10px);
  width: 100%;
}

.calendar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.nav-button {
  width: 28px;
  height: 28px;
  border: none;
  background: var(--color-surface, white);
  border-radius: 50%;
  font-size: 18px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  color: var(--color-text, #333);
  line-height: 1;
}

.nav-button:hover {
  background: var(--color-primary, #667eea);
  color: white;
  transform: scale(1.1);
}

.calendar-title {
  font-size: 14px;
  font-weight: bold;
  color: var(--color-text, #333);
  margin: 0;
  cursor: pointer;
  padding: 3px 10px;
  border-radius: 6px;
  transition: all 0.3s ease;
  user-select: none;
}

.calendar-title:hover {
  background: var(--color-surface-hover, rgba(0, 0, 0, 0.02));
  color: var(--color-primary, #667eea);
}

.calendar-title:active {
  transform: scale(0.95);
}

.hidden-date-input {
  position: fixed;
  top: -9999px;
  left: -9999px;
  width: 1px;
  height: 1px;
  opacity: 0;
  pointer-events: none;
  z-index: -1;
}

/* 日期选择器弹窗 */
.date-picker-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.date-picker-modal {
  background: var(--color-surface, white);
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 400px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: datePickerSlideIn 0.3s ease-out;
}

@keyframes datePickerSlideIn {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(-20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.date-picker-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--color-border, rgba(0, 0, 0, 0.1));
}

.date-picker-header h3 {
  font-size: 18px;
  font-weight: bold;
  color: var(--color-text, #333);
  margin: 0;
}

.date-picker-close {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: var(--color-surface-alt, rgba(0, 0, 0, 0.05));
  color: var(--color-text-secondary, #666);
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  line-height: 1;
}

.date-picker-close:hover {
  background: var(--color-error, #f44336);
  color: #fff;
  transform: rotate(90deg);
}

.date-picker-content {
  padding: 24px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.date-picker-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid var(--color-border, rgba(0, 0, 0, 0.1));
  border-radius: 8px;
  font-size: 16px;
  background: var(--color-surface, white);
  color: var(--color-text, #333);
  transition: all 0.3s ease;
}

.date-picker-input:focus {
  outline: none;
  border-color: var(--color-primary, #667eea);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* 弹窗过渡动画 */
.date-picker-fade-enter-active,
.date-picker-fade-leave-active {
  transition: opacity 0.3s ease;
}

.date-picker-fade-enter-active .date-picker-modal,
.date-picker-fade-leave-active .date-picker-modal {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.date-picker-fade-enter-from {
  opacity: 0;
}

.date-picker-fade-enter-from .date-picker-modal {
  transform: scale(0.9) translateY(-20px);
  opacity: 0;
}

.date-picker-fade-leave-to {
  opacity: 0;
}

.date-picker-fade-leave-to .date-picker-modal {
  transform: scale(0.9) translateY(-20px);
  opacity: 0;
}

.calendar-grid {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.calendar-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.weekday {
  text-align: center;
  font-weight: 600;
  color: var(--color-text-secondary, #666);
  padding: 3px 2px;
  font-size: 13px;
}

.calendar-days {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.calendar-day {
  aspect-ratio: 1;
  padding: 3px 1px;
  border-radius: 5px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  transition: all 0.2s ease;
  background: var(--color-surface, white);
  border: 1px solid transparent;
  min-height: 0;
  min-width: 0;
  max-height: 60px;
}

.calendar-day:hover {
  background: var(--color-surface-hover, rgba(0, 0, 0, 0.02));
  border-color: var(--color-primary, #667eea);
  transform: scale(1.05);
}

.calendar-day.other-month {
  opacity: 0.3;
}

.calendar-day.today {
  border-color: var(--color-primary, #667eea);
  background: var(--color-primary, #667eea);
  color: white;
}

.calendar-day.selected {
  background: var(--color-primary, #667eea);
  color: white;
  font-weight: bold;
  border-color: var(--color-primary-dark, #5568d3);
}

.calendar-day.holiday .day-number {
  color: #ff5252;
}

.calendar-day.today.holiday .day-number,
.calendar-day.selected.holiday .day-number {
  color: white;
}

.day-number {
  font-size: 14px;
  font-weight: 600;
  line-height: 1.2;
  margin-bottom: 2px;
}

.day-lunar {
  font-size: 10px;
  color: var(--color-text-secondary, #999);
  line-height: 1;
  margin-top: 2px;
}

.calendar-day.today .day-lunar,
.calendar-day.selected .day-lunar {
  color: rgba(255, 255, 255, 0.8);
}

.day-festival {
  font-size: 9px;
  color: #ff5252;
  line-height: 1;
  margin-top: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.calendar-day.today .day-festival,
.calendar-day.selected .day-festival {
  color: rgba(255, 255, 255, 0.9);
}

.day-badge {
  position: absolute;
  top: 2px;
  right: 2px;
  font-size: 9px;
  padding: 2px 4px;
  border-radius: 4px;
  color: white;
  font-weight: bold;
  line-height: 1;
}

.day-badge.work {
  background: #999;
}

.day-badge.rest {
  background: #ff5252;
}

/* 详情区域 */
.detail-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-card {
  background: var(--color-surface-variant, rgba(255, 255, 255, 0.1));
  border-radius: 12px;
  padding: 20px;
  backdrop-filter: blur(10px);
}

.lunar-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.lunar-date-main {
  font-size: 28px;
  font-weight: bold;
  color: var(--color-primary, #667eea);
  line-height: 1.2;
}

.lunar-year {
  font-size: 14px;
  color: var(--color-text-secondary, #666);
  margin-top: 4px;
}

.festival-badge {
  padding: 6px 12px;
  background: rgba(255, 82, 82, 0.1);
  border: 1px solid rgba(255, 82, 82, 0.5);
  border-radius: 16px;
  color: #ff5252;
  font-weight: bold;
  font-size: 12px;
  white-space: nowrap;
}

.divider {
  height: 1px;
  background: var(--color-border, rgba(0, 0, 0, 0.1));
  margin: 12px 0;
}

.yiji-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.yiji-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.yiji-label {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: bold;
  color: white;
}

.yi .yiji-label {
  background: #4caf50;
}

.ji .yiji-label {
  background: #f44336;
}

.yiji-content {
  font-size: 13px;
  color: var(--color-text, #333);
  line-height: 1.5;
}

/* 历史上的今天 */
.history-section {
  background: var(--color-surface-variant, rgba(255, 255, 255, 0.1));
  border-radius: 12px;
  padding: 20px;
  backdrop-filter: blur(10px);
}

.history-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: bold;
  color: var(--color-text, #333);
  margin: 0 0 12px 0;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 40px;
  color: var(--color-text-secondary, #999);
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--color-border, rgba(0, 0, 0, 0.1));
  border-top-color: var(--color-primary, #667eea);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.empty-history {
  text-align: center;
  padding: 40px;
  color: var(--color-text-secondary, #999);
  font-size: 14px;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 500px;
  overflow-y: auto;
}

.history-item {
  display: flex;
  gap: 12px;
  padding: 12px;
  background: var(--color-surface, white);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.history-item:hover {
  background: var(--color-surface-hover, rgba(0, 0, 0, 0.02));
  transform: translateX(4px);
}

.history-year {
  min-width: 50px;
  padding: 4px 10px;
  background: var(--color-primary, #667eea);
  color: white;
  border-radius: 6px;
  font-weight: bold;
  font-size: 12px;
  text-align: center;
  height: fit-content;
}

.history-content {
  flex: 1;
}

.history-title-text {
  font-weight: 600;
  color: var(--color-text, #333);
  margin-bottom: 4px;
  font-size: 14px;
}

.history-desc {
  font-size: 13px;
  color: var(--color-text-secondary, #666);
  line-height: 1.5;
}

/* 响应式 */
@media (max-width: 768px) {
  .chinese-calendar {
    padding: 16px 12px;
  }

  .calendar-section {
    padding: 12px;
  }

  .calendar-day {
    padding: 3px 1px;
  }

  .day-number {
    font-size: 13px;
  }

  .day-lunar {
    font-size: 9px;
  }

  .day-festival {
    font-size: 8px;
  }
  
  .weekday {
    font-size: 12px;
  }

  .lunar-date-main {
    font-size: 24px;
  }

  .yiji-section {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .history-item {
    flex-direction: column;
    gap: 8px;
  }

  .history-year {
    width: fit-content;
  }
}

/* 暗色主题适配 */
@media (prefers-color-scheme: dark) {
  .calendar-section,
  .detail-card,
  .history-section {
    background: rgba(255, 255, 255, 0.05);
  }

  .calendar-day {
    background: rgba(255, 255, 255, 0.05);
  }

  .history-item {
    background: rgba(255, 255, 255, 0.05);
  }
}
</style>