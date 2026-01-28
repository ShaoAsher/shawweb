<template>
  <ToolLayout
    title="MBTI 性格测试"
    description="探索您的性格类型，了解您的优势与盲点，只需几分钟，即可获得详细的性格分析报告。"
    icon="🧠"
  >
    <div class="mbti-container">
      <!-- 欢迎页 -->
      <transition name="fade" mode="out-in">
        <div v-if="currentStep === 0" class="welcome-step" key="welcome">
          <div class="welcome-card glass-panel">
            <div class="welcome-icon">🚀</div>
            <h2 class="welcome-title">准备好了吗？</h2>
            <p class="welcome-desc">
              本测试包含 60 道选择题，请根据您的第一直觉回答。<br>
              没有对错之分，请真实面对自己。
            </p>
            <div class="action-buttons">
              <AppButton @click="startQuiz" size="lg" icon="▶️" block class="start-btn">开始测试</AppButton>
              <AppButton @click="showHistory" variant="secondary" icon="📜" block>查看历史记录</AppButton>
            </div>
          </div>
        </div>

        <!-- 测试页 -->
        <div v-else-if="currentStep === 1" class="quiz-step" key="quiz">
          <div class="progress-bar-container glass-panel">
            <div class="progress-info">
              <span>进度</span>
              <span class="progress-text">{{ currentQuestionIndex + 1 }} / {{ questions.length }}</span>
            </div>
            <div class="progress-track">
              <div class="progress-fill" :style="{ width: progressPercentage + '%' }"></div>
            </div>
          </div>

          <div class="question-card glass-panel">
            <transition name="slide-up" mode="out-in">
              <div :key="currentQuestion.id" class="question-content">
                <h2 class="question-text">{{ currentQuestion.text }}</h2>
                
                <div class="options-container">
                  <div class="option-item option-a">
                    <div class="option-label">A</div>
                    <div class="option-text">{{ currentQuestion.optionA }}</div>
                  </div>
                  <div class="option-item option-b">
                    <div class="option-label">B</div>
                    <div class="option-text">{{ currentQuestion.optionB }}</div>
                  </div>
                </div>

                <div class="scale-selector">
                  <div class="scale-buttons">
                    <button 
                      class="scale-btn scale-a-plus" 
                      @click="selectAnswer(2)"
                      title="非常同意 A"
                    >
                      <span class="scale-icon">👍</span>
                      <span class="scale-text">同意 A</span>
                    </button>
                    <button 
                      class="scale-btn scale-a" 
                      @click="selectAnswer(1)"
                      title="比较同意 A"
                    >
                      <span class="scale-text">A</span>
                    </button>
                    <button 
                      class="scale-btn scale-neutral" 
                      @click="selectAnswer(0)"
                      title="中立 / 不确定"
                    >
                      <span class="scale-text">⚪</span>
                    </button>
                    <button 
                      class="scale-btn scale-b" 
                      @click="selectAnswer(-1)"
                      title="比较同意 B"
                    >
                      <span class="scale-text">B</span>
                    </button>
                    <button 
                      class="scale-btn scale-b-plus" 
                      @click="selectAnswer(-2)"
                      title="非常同意 B"
                    >
                      <span class="scale-icon">👍</span>
                      <span class="scale-text">同意 B</span>
                    </button>
                  </div>
                  <div class="scale-labels">
                    <span class="label-a">A 选项</span>
                    <span class="label-b">B 选项</span>
                  </div>
                </div>
              </div>
            </transition>
          </div>

          <div class="quiz-footer">
            <AppButton 
              v-if="currentQuestionIndex > 0" 
              @click="prevQuestion" 
              variant="secondary" 
              icon="⬅️"
              size="sm"
            >
              上一题
            </AppButton>
          </div>
        </div>

        <!-- 结果页 -->
        <div v-else-if="currentStep === 2" class="result-step" key="result">
          <div class="result-header glass-panel">
            <div class="result-subtitle">您的 MBTI 人格类型是</div>
            <h1 class="result-type">{{ result.type }}</h1>
            <div class="result-name-badge">{{ result.name }}</div>
            <p class="result-slogan">{{ result.slogan }}</p>
            <p class="result-alt">可能的备选类型：{{ alternateType }}</p>
            
            <div class="result-tags">
              <span v-for="tag in result.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>

            <div class="dimension-charts">
              <div v-for="(score, dim) in dimensionScores" :key="dim" class="dimension-row">
                <div class="dim-label left">{{ getDimLabel(dim, 'left') }}</div>
                <div class="dim-bar-container">
                  <div class="dim-bar left-bar" :style="{ width: score.left + '%', backgroundColor: getDimColor(dim) }"></div>
                  <div class="dim-bar right-bar" :style="{ width: score.right + '%', backgroundColor: '#e2e8f0' }"></div>
                  <div class="dim-val left-val">{{ Math.round(score.left) }}%</div>
                  <div class="dim-val right-val">{{ Math.round(score.right) }}%</div>
                </div>
                <div class="dim-label right">{{ getDimLabel(dim, 'right') }}</div>
              </div>
            </div>
          </div>

          <div class="result-details glass-panel">
            <div class="detail-section">
              <h3><span class="icon">📝</span> 详细解析</h3>
              <p class="desc-text">{{ result.desc }}</p>
            </div>

            <div class="detail-grid">
              <div class="detail-card">
                <h4>✨ 优势</h4>
                <ul>
                  <li v-for="item in result.strengths" :key="item">{{ item }}</li>
                </ul>
              </div>
              <div class="detail-card">
                <h4>⚠️ 弱点</h4>
                <ul>
                  <li v-for="item in result.weaknesses" :key="item">{{ item }}</li>
                </ul>
              </div>
              <div class="detail-card">
                <h4>💡 改进建议</h4>
                <ul>
                  <li v-for="item in result.improvements" :key="item">{{ item }}</li>
                </ul>
              </div>
              <div class="detail-card">
                <h4>🛡️ 注意事项</h4>
                <ul>
                  <li v-for="item in result.cautions" :key="item">{{ item }}</li>
                </ul>
              </div>
            </div>
          </div>

          <div class="result-actions">
            <AppButton @click="restartQuiz" size="lg" icon="🔄" variant="primary">重新测试</AppButton>
            <AppButton @click="showHistory" size="lg" icon="📜" variant="secondary">查看历史记录</AppButton>
          </div>
        </div>

        <!-- 历史记录页 -->
        <div v-else-if="currentStep === 3" class="history-step" key="history">
          <div class="history-header">
            <AppButton @click="currentStep = 0" variant="secondary" icon="⬅️">返回</AppButton>
            <h2>历史记录</h2>
          </div>
          
          <div v-if="history.length === 0" class="empty-state">
            <div class="empty-icon">📭</div>
            <p>暂无测试记录</p>
            <AppButton @click="startQuiz" variant="primary" class="mt-4">开始测试</AppButton>
          </div>
          
          <div v-else class="history-list">
            <div v-for="entry in history" :key="entry.id" class="history-item glass-panel" @click="viewHistory(entry)">
              <div class="history-type-badge">{{ entry.type }}</div>
              <div class="history-info">
                <div class="history-date">{{ formatDate(entry.createdAt) }}</div>
                <div class="history-scores">
                  E:{{ Math.round(entry.scores.E) }}% 
                  S:{{ Math.round(entry.scores.S) }}% 
                  T:{{ Math.round(entry.scores.T) }}% 
                  J:{{ Math.round(entry.scores.J) }}%
                </div>
              </div>
              <div class="history-arrow">➡️</div>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'
import { mbtiQuestions, mbtiProfiles } from '@/data/mbti-data.js'

// State
const currentStep = ref(0) // 0: Welcome, 1: Quiz, 2: Result, 3: History
const currentQuestionIndex = ref(0)
const answers = ref({}) // map: index -> score
const history = ref([])
const result = ref({})
const alternateType = ref('')
const dimensionScores = ref({})

// Constants
const questions = mbtiQuestions

// Computed
const currentQuestion = computed(() => questions[currentQuestionIndex.value])
const progressPercentage = computed(() => ((currentQuestionIndex.value + 1) / questions.length) * 100)

// Methods
const startQuiz = () => {
  answers.value = {}
  currentQuestionIndex.value = 0
  currentStep.value = 1
}

const prevQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
  }
}

const selectAnswer = (score) => {
  answers.value[currentQuestionIndex.value] = score
  
  if (currentQuestionIndex.value < questions.length - 1) {
    setTimeout(() => {
      currentQuestionIndex.value++
    }, 200) // Small delay for visual feedback
  } else {
    calculateResult()
  }
}

const calculateResult = () => {
  let eScore = 0, sScore = 0, tScore = 0, jScore = 0
  let totalE = 0, totalS = 0, totalT = 0, totalJ = 0

  questions.forEach((q, index) => {
    const score = answers.value[index] || 0
    const w = 1.0 // weight assumed 1.0

    if (q.dimension === 'EI') { eScore += score * w; totalE += w; }
    if (q.dimension === 'SN') { sScore += score * w; totalS += w; }
    if (q.dimension === 'TF') { tScore += score * w; totalT += w; }
    if (q.dimension === 'JP') { jScore += score * w; totalJ += w; }
  })

  let type = ''
  type += (eScore >= 0) ? 'E' : 'I'
  type += (sScore >= 0) ? 'S' : 'N'
  type += (tScore >= 0) ? 'T' : 'F'
  type += (jScore >= 0) ? 'J' : 'P'

  // Calculate percentages (normalized to 0-100)
  // Logic from Flutter: ((score + 2*total) / (4*total) * 100)
  // Max score per q is 2, min is -2. Range is -2*total to +2*total. Width is 4*total.
  // (score - (-2*total)) / (4*total) = (score + 2*total) / 4*total
  const ePct = Math.min(100, Math.max(0, ((eScore + 2 * totalE) / (4 * totalE) * 100)))
  const sPct = Math.min(100, Math.max(0, ((sScore + 2 * totalS) / (4 * totalS) * 100)))
  const tPct = Math.min(100, Math.max(0, ((tScore + 2 * totalT) / (4 * totalT) * 100)))
  const jPct = Math.min(100, Math.max(0, ((jScore + 2 * totalJ) / (4 * totalJ) * 100)))

  const scores = {
    E: ePct, I: 100 - ePct,
    S: sPct, N: 100 - sPct,
    T: tPct, F: 100 - tPct,
    J: jPct, P: 100 - jPct
  }

  // Format for chart
  dimensionScores.value = {
    EI: { left: scores.E, right: scores.I },
    SN: { left: scores.S, right: scores.N },
    TF: { left: scores.T, right: scores.F },
    JP: { left: scores.J, right: scores.P }
  }

  // Alternate Type
  const margins = {
    EI: Math.abs(scores.E - 50),
    SN: Math.abs(scores.S - 50),
    TF: Math.abs(scores.T - 50),
    JP: Math.abs(scores.J - 50)
  }
  
  let flipDim = 'EI'
  let minMargin = Infinity
  for (const [k, v] of Object.entries(margins)) {
    if (v < minMargin) {
      minMargin = v
      flipDim = k
    }
  }

  let alt = type
  if (flipDim === 'EI') alt = (alt[0] === 'E' ? 'I' : 'E') + alt.substring(1)
  if (flipDim === 'SN') alt = alt[0] + (alt[1] === 'S' ? 'N' : 'S') + alt.substring(2)
  if (flipDim === 'TF') alt = alt.substring(0, 2) + (alt[2] === 'T' ? 'F' : 'T') + alt.substring(3)
  if (flipDim === 'JP') alt = alt.substring(0, 3) + (alt[3] === 'J' ? 'P' : 'J')

  result.value = mbtiProfiles[type] || mbtiProfiles['INFP']
  alternateType.value = alt

  // Save History
  const entry = {
    id: Date.now().toString(),
    type: type,
    altType: alt,
    scores: { E: scores.E, S: scores.S, T: scores.T, J: scores.J },
    createdAt: new Date().toISOString()
  }
  saveHistory(entry)
  
  currentStep.value = 2
}

const restartQuiz = () => {
  startQuiz()
}

const showHistory = () => {
  loadHistory()
  currentStep.value = 3
}

const loadHistory = () => {
  const saved = localStorage.getItem('mbti_history')
  if (saved) {
    history.value = JSON.parse(saved)
  }
}

const saveHistory = (entry) => {
  loadHistory()
  history.value.unshift(entry)
  localStorage.setItem('mbti_history', JSON.stringify(history.value))
}

const viewHistory = (entry) => {
  result.value = mbtiProfiles[entry.type]
  alternateType.value = entry.altType
  
  const s = entry.scores
  dimensionScores.value = {
    EI: { left: s.E, right: 100 - s.E },
    SN: { left: s.S, right: 100 - s.S },
    TF: { left: s.T, right: 100 - s.T },
    JP: { left: s.J, right: 100 - s.J }
  }
  
  currentStep.value = 2
}

const formatDate = (isoString) => {
  const d = new Date(isoString)
  return `${d.getFullYear()}-${(d.getMonth()+1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')} ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
}

const getDimLabel = (dim, side) => {
  const map = {
    EI: { left: '外向 (E)', right: '内向 (I)' },
    SN: { left: '实感 (S)', right: '直觉 (N)' },
    TF: { left: '理智 (T)', right: '情感 (F)' },
    JP: { left: '判断 (J)', right: '感知 (P)' }
  }
  return map[dim][side]
}

const getDimColor = (dim) => {
  const map = {
    EI: '#3b82f6', // blue
    SN: '#f59e0b', // orange
    TF: '#10b981', // green
    JP: '#8b5cf6'  // purple
  }
  return map[dim]
}

// Initial load
onMounted(() => {
  loadHistory()
})
</script>

<style scoped>
.mbti-container {
  max-width: 800px;
  margin: 0 auto;
  min-height: 600px;
  position: relative;
}

/* Glass Panel Effect */
.glass-panel {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

/* Welcome Step */
.welcome-step {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.welcome-card {
  padding: 40px;
  text-align: center;
  max-width: 500px;
  width: 100%;
}

.welcome-icon {
  font-size: 64px;
  margin-bottom: 24px;
  animation: float 3s ease-in-out infinite;
}

.welcome-title {
  font-size: 2rem;
  font-weight: 800;
  color: var(--color-text);
  margin-bottom: 16px;
  background: linear-gradient(135deg, var(--color-primary) 0%, #a855f7 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.welcome-desc {
  font-size: 1.1rem;
  color: var(--color-text-light);
  line-height: 1.6;
  margin-bottom: 32px;
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Quiz Step */
.quiz-step {
  padding: 20px 0;
}

.progress-bar-container {
  padding: 16px 24px;
  margin-bottom: 24px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-weight: 600;
  color: var(--color-text);
}

.progress-text {
  color: var(--color-primary);
}

.progress-track {
  height: 10px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 5px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--color-primary);
  border-radius: 5px;
  transition: width 0.4s ease;
}

.question-card {
  padding: 40px;
  min-height: 400px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  margin-bottom: 24px;
}

.question-text {
  font-size: 1.5rem;
  text-align: center;
  margin-bottom: 40px;
  color: var(--color-text);
  font-weight: 700;
  line-height: 1.4;
}

.options-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 40px;
}

.option-item {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  background: rgba(var(--primary-rgb), 0.05);
  border-radius: 12px;
  border: 1px solid rgba(var(--primary-rgb), 0.1);
  transition: all 0.3s ease;
}

.option-b {
  background: rgba(168, 85, 247, 0.05); /* Purple tint */
  border-color: rgba(168, 85, 247, 0.1);
}

.option-label {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-right: 16px;
  flex-shrink: 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.option-a .option-label { color: var(--color-primary); }
.option-b .option-label { color: #a855f7; }

.option-text {
  font-size: 1.1rem;
  font-weight: 500;
  color: var(--color-text);
}

.scale-selector {
  display: flex;
  flex-direction: column;
  gap: 12px;
  align-items: center;
}

.scale-buttons {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
  width: 100%;
  max-width: 600px;
}

.scale-btn {
  border: none;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  outline: none;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.scale-btn:active { transform: scale(0.95); }
.scale-btn:hover { transform: translateY(-3px); box-shadow: 0 6px 12px rgba(0,0,0,0.15); }

.scale-icon { font-size: 1.2rem; margin-bottom: 2px; }
.scale-text { font-size: 0.75rem; font-weight: bold; opacity: 0.9; }

/* Scale Sizes */
.scale-a-plus { 
  width: 80px; height: 80px; 
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
}
.scale-a { 
  width: 60px; height: 60px; 
  background: rgba(var(--primary-rgb), 0.7);
}
.scale-a .scale-text { font-size: 1rem; }

.scale-neutral { 
  width: 50px; height: 50px; 
  background: #94a3b8; 
}
.scale-neutral .scale-text { font-size: 1.2rem; }

.scale-b { 
  width: 60px; height: 60px; 
  background: rgba(168, 85, 247, 0.7); 
}
.scale-b .scale-text { font-size: 1rem; }

.scale-b-plus { 
  width: 80px; height: 80px; 
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
}

/* Mobile responsive for scale */
@media (max-width: 600px) {
  .scale-buttons { gap: 8px; }
  .scale-a-plus, .scale-b-plus { width: 60px; height: 60px; }
  .scale-a, .scale-b { width: 50px; height: 50px; }
  .scale-neutral { width: 40px; height: 40px; }
  .scale-icon { display: none; }
  .scale-text { font-size: 0.8rem; }
}

.scale-labels {
  display: flex;
  justify-content: space-between;
  width: 100%;
  font-size: 0.9rem;
  font-weight: 600;
  padding: 0 10px;
}

.label-a { color: var(--color-primary); }
.label-b { color: #a855f7; }

.quiz-footer {
  margin-top: 24px;
  display: flex;
  justify-content: flex-start;
}

/* Result Step */
.result-header {
  padding: 40px;
  text-align: center;
  margin-bottom: 24px;
  background: linear-gradient(to bottom, rgba(255,255,255,0.9), rgba(255,255,255,0.6));
}

.result-subtitle { font-size: 1rem; color: var(--color-text-light); margin-bottom: 12px; }
.result-type { 
  font-size: 4rem; 
  font-weight: 900; 
  color: var(--color-primary); 
  letter-spacing: 4px;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 10px rgba(var(--primary-rgb), 0.2);
}
.result-name-badge {
  display: inline-block;
  background: var(--color-primary);
  color: white;
  padding: 6px 20px;
  border-radius: 20px;
  font-weight: bold;
  font-size: 1.2rem;
  margin-bottom: 20px;
}
.result-slogan { font-size: 1.1rem; font-style: italic; color: var(--color-text); margin-bottom: 8px; }
.result-alt { font-size: 0.9rem; color: var(--color-text-light); margin-bottom: 24px; }

.result-tags {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-bottom: 32px;
}

.tag {
  background: white;
  border: 1px solid #e2e8f0;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 0.9rem;
  color: #64748b;
}

.dimension-charts {
  max-width: 500px;
  margin: 0 auto;
}

.dimension-row {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.dim-label {
  width: 60px;
  font-size: 0.85rem;
  font-weight: bold;
}
.dim-label.left { text-align: right; margin-right: 10px; }
.dim-label.right { text-align: left; margin-left: 10px; color: #94a3b8; }

.dim-bar-container {
  flex: 1;
  height: 24px;
  background: #f1f5f9;
  border-radius: 12px;
  position: relative;
  overflow: hidden;
  display: flex;
}

.dim-bar { height: 100%; transition: width 1s ease-out; }
.dim-val {
  position: absolute;
  top: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  font-size: 0.75rem;
  color: white;
  font-weight: bold;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
}
.left-val { left: 8px; }
.right-val { right: 8px; color: #64748b; text-shadow: none; }

.result-details {
  padding: 32px;
  margin-bottom: 24px;
}

.detail-section { margin-bottom: 32px; }
.detail-section h3 { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; font-size: 1.3rem; }
.desc-text { line-height: 1.8; color: var(--color-text); }

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
}

.detail-card h4 { margin-bottom: 12px; font-size: 1.1rem; color: var(--color-text); }
.detail-card ul { padding-left: 20px; color: var(--color-text-light); }
.detail-card li { margin-bottom: 6px; }

.result-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  margin-bottom: 40px;
}

/* History Step */
.history-header {
  display: flex;
  align-items: center;
  margin-bottom: 24px;
  padding: 0 16px;
}

.back-btn {
  background: none;
  border: none;
  font-size: 1rem;
  cursor: pointer;
  margin-right: 16px;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item {
  padding: 16px 20px;
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.history-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 12px rgba(0,0,0,0.05);
}

.history-type-badge {
  width: 50px;
  height: 50px;
  background: rgba(var(--primary-rgb), 0.1);
  color: var(--color-primary);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-right: 16px;
}

.history-info { flex: 1; }
.history-date { font-size: 0.9rem; color: var(--color-text); margin-bottom: 4px; }
.history-scores { font-size: 0.8rem; color: var(--color-text-light); }
.history-arrow { color: #cbd5e1; }

.empty-state {
  text-align: center;
  padding: 60px 0;
  color: var(--color-text-light);
}
.empty-icon { font-size: 64px; margin-bottom: 16px; opacity: 0.5; }

/* Animations */
@keyframes float {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.3s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.slide-up-enter-active, .slide-up-leave-active { transition: all 0.3s ease; }
.slide-up-enter-from { opacity: 0; transform: translateY(20px); }
.slide-up-leave-to { opacity: 0; transform: translateY(-20px); }
</style>
