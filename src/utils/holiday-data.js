// 节假日数据工具
// 使用公共API获取真实的节假日数据，带重试和备用方案

// 节假日数据缓存
const holidayCache = new Map()

// 请求延迟配置（避免请求过快）
const REQUEST_DELAY = 300 // 毫秒
const MAX_RETRIES = 2

/**
 * 获取指定日期的节假日信息
 * @param {Date} date - 日期对象
 * @returns {Promise<Object|null>} - { isWork: boolean, name: string } 或 null
 */
export async function getHolidayInfo(date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
  
  // 先检查缓存
  if (holidayCache.has(dateStr)) {
    return holidayCache.get(dateStr)
  }
  
  // 先尝试使用静态数据（快速响应）
  const staticInfo = getStaticHolidayInfo(date)
  if (staticInfo) {
    holidayCache.set(dateStr, staticInfo)
    return staticInfo
  }
  
  // API调用已禁用，直接返回null（使用静态数据）
  // 如果需要实时API数据，可以在这里启用
  return null
}

/**
 * 带重试的API请求
 */
async function fetchHolidayInfoFromAPIWithRetry(date, retries = MAX_RETRIES) {
  for (let i = 0; i <= retries; i++) {
    try {
      await delay(REQUEST_DELAY * (i + 1)) // 递增延迟
      const info = await fetchHolidayInfoFromAPI(date)
      if (info) return info
    } catch (e) {
      if (i === retries) throw e
      // 继续重试
    }
  }
  return null
}

/**
 * 从API获取单个日期的节假日信息
 * @param {Date} date - 日期对象
 * @returns {Promise<Object|null>} - { isWork: boolean, name: string } 或 null
 */
async function fetchHolidayInfoFromAPI(date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const dateStr = `${year}${month}${day}`
  
  // 尝试多个API源
  const apis = [
    // API 1: 使用 CORS 代理或直接请求
    async () => {
      try {
        // 使用 mode: 'no-cors' 或使用代理
        const response = await fetch(`https://tool.bitefu.net/jiari/?d=${dateStr}`, {
          method: 'GET',
          mode: 'cors',
          cache: 'no-cache',
          headers: {
            'Accept': 'text/plain'
          }
        })
        
        if (response.ok) {
          const result = await response.text()
          const code = parseInt(result.trim())
          return parseHolidayCode(code, date)
        }
      } catch (e) {
        throw new Error(`API 1 failed: ${e.message}`)
      }
      return null
    },
    
    // API 2: 备用API（如果有）
    async () => {
      // 可以添加其他API
      return null
    }
  ]
  
  // 按顺序尝试各个API
  for (const api of apis) {
    try {
      const result = await api()
      if (result) return result
    } catch (e) {
      // 继续尝试下一个
      continue
    }
  }
  
  return null
}

/**
 * 解析节假日代码
 */
function parseHolidayCode(code, date) {
  const holidayName = getHolidayName(date)
  
  if (code === 2) {
    // 节假日
    return {
      isWork: false,
      name: holidayName || '节假日'
    }
  } else if (code === 1) {
    // 休息日（周末或调休）
    return {
      isWork: false,
      name: holidayName || '休息日'
    }
  } else if (code === 0) {
    // 工作日，但可能是调休工作日
    const dayOfWeek = date.getDay()
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      return {
        isWork: true,
        name: '调休'
      }
    }
    return {
      isWork: true,
      name: '工作日'
    }
  }
  
  return null
}

/**
 * 获取静态节假日信息（作为备用方案）
 */
function getStaticHolidayInfo(date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
  
  // 使用静态数据
  const staticData = getStaticHolidayData(year)
  return staticData[dateStr] || null
}

/**
 * 获取静态节假日数据（包含已知的节假日和调休）
 */
function getStaticHolidayData(year) {
  const holidays = {}
  
  // 固定节假日
  const fixedHolidays = {
    '01-01': { isWork: false, name: '元旦' },
    '05-01': { isWork: false, name: '劳动节' },
    '10-01': { isWork: false, name: '国庆节' },
    '10-02': { isWork: false, name: '国庆节' },
    '10-03': { isWork: false, name: '国庆节' },
    '10-04': { isWork: false, name: '国庆节' },
    '10-05': { isWork: false, name: '国庆节' },
    '10-06': { isWork: false, name: '国庆节' },
    '10-07': { isWork: false, name: '国庆节' },
  }
  
  Object.keys(fixedHolidays).forEach(key => {
    holidays[`${year}-${key}`] = fixedHolidays[key]
  })
  
  // 春节（根据年份）
  const springFestivalDates = getSpringFestivalDates(year)
  springFestivalDates.forEach(date => {
    holidays[date] = { isWork: false, name: '春节' }
  })
  
  // 清明节
  const qingmingDate = getQingmingDate(year)
  if (qingmingDate) {
    holidays[qingmingDate] = { isWork: false, name: '清明节' }
  }
  
  // 端午节
  const dragonBoatDates = getDragonBoatDates(year)
  dragonBoatDates.forEach(date => {
    holidays[date] = { isWork: false, name: '端午节' }
  })
  
  // 中秋节
  const midAutumnDates = getMidAutumnDates(year)
  midAutumnDates.forEach(date => {
    holidays[date] = { isWork: false, name: '中秋节' }
  })
  
  // 调休工作日（根据实际政策，这里提供一些常见年份的示例）
  const workdayAdjustments = getWorkdayAdjustments(year)
  Object.keys(workdayAdjustments).forEach(date => {
    holidays[date] = workdayAdjustments[date]
  })
  
  return holidays
}

/**
 * 获取调休工作日数据
 */
function getWorkdayAdjustments(year) {
  // 根据国务院发布的节假日安排添加调休数据
  const adjustments = {}
  
  // 2024年调休安排
  if (year === 2024) {
    // 春节调休
    adjustments['2024-02-04'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2024-02-18'] = { isWork: true, name: '调休' } // 周日上班
    // 清明节调休
    adjustments['2024-04-07'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2024-04-28'] = { isWork: true, name: '调休' } // 周日上班
    // 劳动节调休
    adjustments['2024-04-28'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2024-05-11'] = { isWork: true, name: '调休' } // 周六上班
    // 端午节调休
    adjustments['2024-06-09'] = { isWork: true, name: '调休' } // 周日上班
    // 中秋节调休
    adjustments['2024-09-15'] = { isWork: true, name: '调休' } // 周日上班
    // 国庆节调休
    adjustments['2024-09-29'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2024-10-12'] = { isWork: true, name: '调休' } // 周六上班
  }
  
  // 2025年调休安排
  if (year === 2025) {
    // 春节调休
    adjustments['2025-01-26'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2025-02-08'] = { isWork: true, name: '调休' } // 周六上班
    // 清明节调休
    adjustments['2025-04-06'] = { isWork: true, name: '调休' } // 周日上班
    // 劳动节调休
    adjustments['2025-04-27'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2025-05-10'] = { isWork: true, name: '调休' } // 周六上班
    // 端午节调休
    adjustments['2025-05-25'] = { isWork: true, name: '调休' } // 周日上班
    // 中秋节调休
    adjustments['2025-10-07'] = { isWork: true, name: '调休' } // 周二上班（国庆假期后）
    adjustments['2025-10-11'] = { isWork: true, name: '调休' } // 周六上班
    // 国庆节调休
    adjustments['2025-09-28'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2025-10-11'] = { isWork: true, name: '调休' } // 周六上班
  }
  
  // 2026年调休安排（预估）
  if (year === 2026) {
    // 春节调休
    adjustments['2026-02-15'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2026-02-28'] = { isWork: true, name: '调休' } // 周六上班
    // 清明节调休
    adjustments['2026-04-05'] = { isWork: true, name: '调休' } // 周日上班
    // 劳动节调休
    adjustments['2026-04-26'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2026-05-09'] = { isWork: true, name: '调休' } // 周六上班
    // 国庆节调休
    adjustments['2026-09-27'] = { isWork: true, name: '调休' } // 周日上班
    adjustments['2026-10-10'] = { isWork: true, name: '调休' } // 周六上班
  }
  
  return adjustments
}

/**
 * 根据日期获取节日名称
 */
function getHolidayName(date) {
  const month = date.getMonth() + 1
  const day = date.getDate()
  
  const fixedHolidays = {
    '01-01': '元旦',
    '05-01': '劳动节',
    '10-01': '国庆节',
    '10-02': '国庆节',
    '10-03': '国庆节',
    '10-04': '国庆节',
    '10-05': '国庆节',
    '10-06': '国庆节',
    '10-07': '国庆节',
  }
  
  const key = `${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
  return fixedHolidays[key] || null
}

/**
 * 获取春节日期
 */
function getSpringFestivalDates(year) {
  const springFestivalMap = {
    2024: ['2024-02-10', '2024-02-11', '2024-02-12', '2024-02-13', '2024-02-14', '2024-02-15', '2024-02-16', '2024-02-17'],
    2025: ['2025-01-29', '2025-01-30', '2025-01-31', '2025-02-01', '2025-02-02', '2025-02-03', '2025-02-04', '2025-02-05'],
    2026: ['2026-02-17', '2026-02-18', '2026-02-19', '2026-02-20', '2026-02-21', '2026-02-22', '2026-02-23', '2026-02-24'],
    2027: ['2027-02-06', '2027-02-07', '2027-02-08', '2027-02-09', '2027-02-10', '2027-02-11', '2027-02-12', '2027-02-13'],
  }
  
  return springFestivalMap[year] || []
}

/**
 * 获取清明节日期
 */
function getQingmingDate(year) {
  const isLeapYear = (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
  const day = isLeapYear ? '04' : '05'
  return `${year}-04-${day}`
}

/**
 * 获取端午节日期
 */
function getDragonBoatDates(year) {
  const dragonBoatMap = {
    2024: ['2024-06-10'],
    2025: ['2025-05-31'],
    2026: ['2026-06-19'],
    2027: ['2027-05-31'],
  }
  
  return dragonBoatMap[year] || []
}

/**
 * 获取中秋节日期
 */
function getMidAutumnDates(year) {
  const midAutumnMap = {
    2024: ['2024-09-17'],
    2025: ['2025-10-06'],
    2026: ['2026-09-25'],
    2027: ['2027-10-06'],
  }
  
  return midAutumnMap[year] || []
}

/**
 * 从API批量获取指定年份的节假日数据
 * @param {number} year - 年份
 * @returns {Promise<Object>} - 节假日数据对象
 */
export async function fetchHolidayDataFromAPI(year) {
  const holidays = {}
  
  // 先使用静态数据作为基础
  const staticData = getStaticHolidayData(year)
  Object.assign(holidays, staticData)
  
  // 注意：大部分节假日API都有CORS限制，无法直接从前端调用
  // HolidayUtil已经内置了节假日数据，可以直接使用
  // 如果需要实时数据，可以通过后端代理API调用
  
  return holidays
}

/**
 * 从 holiday.ailcc.com API 获取节假日数据
 * 注意：该API有CORS限制，无法直接调用
 */
async function fetchHolidayFromAilcc(year) {
  // API有CORS限制，无法直接调用
  // 如果需要使用，需要通过后端代理
  return {}
}

/**
 * 从GitHub获取节假日数据（备用方案）
 */
async function fetchHolidayFromGitHub(year) {
  const holidays = {}
  
  try {
    // 尝试不同的GitHub数据源
    const sources = [
      `https://raw.githubusercontent.com/vsme/chinese-days/main/data/${year}.json`,
      `https://raw.githubusercontent.com/lanceliao/china-holiday-calender/master/data/${year}.json`
    ]
    
    for (const url of sources) {
      try {
        const response = await fetch(url, {
          method: 'GET',
          headers: {
            'Accept': 'application/json'
          }
        })
        
        if (response.ok) {
          const data = await response.json()
          if (data.holidays && Array.isArray(data.holidays)) {
            data.holidays.forEach(item => {
              const dateStr = item.date || item.day
              if (dateStr) {
                holidays[dateStr] = {
                  isWork: item.isWork === true,
                  name: item.name || (item.isWork ? '调休' : '节假日'),
                  type: item.isWork ? 'workday' : 'holiday'
                }
              }
            })
            // 如果成功获取数据，直接返回
            if (Object.keys(holidays).length > 0) {
              return holidays
            }
          }
        }
      } catch (e) {
        // 继续尝试下一个源
        continue
      }
    }
  } catch (e) {
    // 静默失败
  }
  
  return holidays
}

/**
 * 获取重要节假日日期范围
 */
function getImportantHolidayDates(year) {
  const dates = []
  
  // 只查询已知的节假日日期，减少请求
  dates.push(`${year}-01-01`) // 元旦
  
  // 春节范围（1月20日到2月20日）
  for (let month = 1; month <= 2; month++) {
    const daysInMonth = month === 1 ? 31 : (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 ? 29 : 28
    const startDay = month === 1 ? 20 : 1
    const endDay = month === 2 ? 20 : daysInMonth
    for (let day = startDay; day <= endDay; day++) {
      dates.push(`${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`)
    }
  }
  
  // 清明节
  for (let day = 4; day <= 6; day++) {
    dates.push(`${year}-04-${String(day).padStart(2, '0')}`)
  }
  
  // 劳动节
  dates.push(`${year}-04-30`)
  dates.push(`${year}-05-01`)
  dates.push(`${year}-05-02`)
  
  // 国庆节
  dates.push(`${year}-09-30`)
  for (let day = 1; day <= 7; day++) {
    dates.push(`${year}-10-${String(day).padStart(2, '0')}`)
  }
  
  return dates
}

/**
 * 延迟函数
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}