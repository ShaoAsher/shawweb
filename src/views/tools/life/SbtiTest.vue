<template>
  <ToolLayout
    title="SBTI 人格测试"
    description="MBTI 已经过时，SBTI 来了。31 题娱乐向人格测试，十五维度匹配标准人格库，仅供娱乐。"
    icon="🎭"
  >
    <div class="sbti-root">
      <!-- 介绍 -->
      <transition name="fade" mode="out-in">
        <section v-if="screen === 'intro'" class="card intro-card" key="intro">
          <p class="eyebrow">娱乐测试 · 非专业心理测评</p>
          <h2 class="hero-title">MBTI 已经过时，<span class="accent">SBTI</span> 来了。</h2>
          <p class="lead">
            题目顺序每次随机打乱，其中包含一道「爱好」相关题；若选项触发展开，总题数会增加一题。请全部答完后再提交。
          </p>
          <div class="intro-actions">
            <AppButton size="lg" icon="▶️" block @click="startTest">开始测试</AppButton>
          </div>
        </section>

        <!-- 答题 -->
        <section v-else-if="screen === 'test'" class="test-section" key="test">
          <div class="card test-top">
            <div class="progress-row">
              <div class="progress-track">
                <div class="progress-fill" :style="{ width: progress.percent + '%' }" />
              </div>
              <span class="progress-text">{{ progress.done }} / {{ progress.total }}</span>
            </div>
            <p class="hint">{{ testHint }}</p>
          </div>

          <article
            v-for="(q, index) in visibleQuestions"
            :key="q.id"
            class="card q-card"
          >
            <div class="q-meta">
              <span class="badge">第 {{ index + 1 }} 题</span>
              <span class="dim-tag">{{ q.special ? '补充题' : '维度已隐藏' }}</span>
            </div>
            <p class="q-text">{{ q.text }}</p>
            <div class="options">
              <label
                v-for="(opt, i) in q.options"
                :key="i"
                class="option"
                :class="{ checked: answers[q.id] === opt.value }"
              >
                <input
                  type="radio"
                  :name="q.id"
                  :value="opt.value"
                  :checked="answers[q.id] === opt.value"
                  @change="onPick(q.id, opt.value)"
                >
                <span class="opt-code">{{ optionCode(i) }}</span>
                <span class="opt-label">{{ opt.label }}</span>
              </label>
            </div>
          </article>

          <div class="card actions-bottom">
            <div class="btn-row">
              <AppButton variant="secondary" icon="⬅️" @click="screen = 'intro'">返回首页</AppButton>
              <AppButton
                icon="✓"
                :disabled="!progress.complete"
                @click="submitResult"
              >
                提交并查看结果
              </AppButton>
            </div>
          </div>
        </section>

        <!-- 结果 -->
        <section v-else class="result-section" key="result">
          <div class="card result-card">
            <div class="result-grid">
              <div class="poster-box" :class="{ 'no-image': !posterUrl }">
                <img
                  v-if="posterUrl"
                  :src="posterUrl"
                  :alt="`${resultPayload.finalType.code}（${resultPayload.finalType.cn}）`"
                  class="poster-img"
                >
                <p class="poster-caption">{{ resultPayload.finalType.intro }}</p>
              </div>
              <div class="type-box">
                <div class="type-kicker">{{ resultPayload.modeKicker }}</div>
                <div class="type-name">
                  {{ resultPayload.finalType.code }}（{{ resultPayload.finalType.cn }}）
                </div>
                <div class="match-badge">{{ resultPayload.badge }}</div>
                <p class="type-sub">{{ resultPayload.sub }}</p>
              </div>
            </div>

            <div class="analysis-box">
              <h3>该人格的简单解读</h3>
              <p class="desc">{{ resultPayload.finalType.desc }}</p>
            </div>

            <div class="dim-box">
              <h3>十五维度评分</h3>
              <div class="dim-list">
                <div
                  v-for="dim in dimensionOrder"
                  :key="dim"
                  class="dim-item"
                >
                  <div class="dim-item-top">
                    <span class="dim-name">{{ dimensionMeta[dim].name }}</span>
                    <span class="dim-score">
                      {{ resultPayload.levels[dim] }} / {{ resultPayload.rawScores[dim] }}分
                    </span>
                  </div>
                  <p class="dim-expl">{{ dimExpl(dim, resultPayload.levels[dim]) }}</p>
                </div>
              </div>
            </div>

            <div class="note-box">
              <h3>友情提示</h3>
              <p>{{ funNote }}</p>
            </div>
          </div>

          <div class="btn-row result-actions">
            <AppButton variant="secondary" icon="🔄" @click="startTest">重新测试</AppButton>
            <AppButton icon="🏠" @click="goIntro">回到首页</AppButton>
          </div>
        </section>
      </transition>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'
import {
  dimensionMeta,
  dimensionOrder,
  questions,
  specialQuestions,
  DIM_EXPLANATIONS,
  shuffle,
  getVisibleQuestions,
  computeSbtiResult,
  resolveTypeImageUrl
} from '@/data/sbti-data.js'

const screen = ref('intro')
const answers = ref({})
const shuffledQuestions = ref([])
const resultPayload = ref(null)

const visibleQuestions = computed(() =>
  getVisibleQuestions(shuffledQuestions.value, answers.value)
)

const progress = computed(() => {
  const list = visibleQuestions.value
  const total = list.length
  const done = list.filter((q) => answers.value[q.id] !== undefined).length
  const percent = total ? (done / total) * 100 : 0
  return {
    total,
    done,
    percent,
    complete: done === total && total > 0
  }
})

const testHint = computed(() =>
  progress.value.complete
    ? '都做完了。现在可以把你的电子魂魄交给结果页审判。'
    : '全选完才会放行。世界已经够乱了，起码把题做完整。'
)

const posterUrl = computed(() => {
  if (!resultPayload.value) return null
  return resolveTypeImageUrl(resultPayload.value.finalType.code)
})

const funNote = computed(() => {
  if (!resultPayload.value) return ''
  return resultPayload.value.special
    ? '本测试仅供娱乐。隐藏人格和傻乐兜底都属于作者故意埋的损招，请勿把它当成医学、心理学、相学、命理学或灵异学依据。'
    : '本测试仅供娱乐，别拿它当诊断、面试、相亲、分手、招魂、算命或人生判决书。你可以笑，但别太当真。'
})

function optionCode(i) {
  return ['A', 'B', 'C', 'D'][i] ?? String(i + 1)
}

function dimExpl(dim, level) {
  return DIM_EXPLANATIONS[dim]?.[level] ?? ''
}

function startTest() {
  answers.value = {}
  const shuffledRegular = shuffle(questions)
  const insertIndex = Math.floor(Math.random() * shuffledRegular.length) + 1
  shuffledQuestions.value = [
    ...shuffledRegular.slice(0, insertIndex),
    specialQuestions[0],
    ...shuffledRegular.slice(insertIndex)
  ]
  resultPayload.value = null
  screen.value = 'test'
}

function onPick(qid, value) {
  const n = { ...answers.value, [qid]: Number(value) }
  if (qid === 'drink_gate_q1' && Number(value) !== 3) {
    delete n.drink_gate_q2
  }
  answers.value = n
}

function submitResult() {
  resultPayload.value = computeSbtiResult(answers.value)
  screen.value = 'result'
}

function goIntro() {
  screen.value = 'intro'
}
</script>

<style scoped>
.sbti-root {
  max-width: 720px;
  margin: 0 auto;
  padding-bottom: 2rem;
  --sbti-accent: #6c8d71;
  --sbti-accent-strong: #4d6a53;
  --sbti-line: #dbe8dd;
  --sbti-soft: #edf6ef;
  --sbti-text: #1e2a22;
  --sbti-muted: #6a786f;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.card {
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(10px);
  border: 1px solid var(--sbti-line);
  border-radius: 20px;
  box-shadow: 0 16px 40px rgba(47, 73, 55, 0.08);
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.intro-card .eyebrow {
  display: inline-flex;
  font-size: 12px;
  color: var(--sbti-accent-strong);
  border: 1px solid var(--sbti-line);
  background: var(--sbti-soft);
  border-radius: 999px;
  padding: 6px 12px;
  margin-bottom: 1rem;
}

.hero-title {
  font-size: clamp(1.35rem, 4vw, 1.85rem);
  line-height: 1.2;
  color: var(--sbti-text);
  margin: 0 0 1rem;
  font-weight: 700;
}

.accent {
  color: var(--sbti-accent-strong);
}

.lead {
  color: var(--sbti-muted);
  line-height: 1.65;
  margin: 0 0 1.5rem;
  font-size: 15px;
}

.intro-actions {
  margin-bottom: 1.25rem;
}

.test-top .progress-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.progress-track {
  flex: 1;
  height: 8px;
  background: var(--sbti-soft);
  border-radius: 999px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--sbti-accent), var(--sbti-accent-strong));
  border-radius: 999px;
  transition: width 0.25s ease;
}

.progress-text {
  font-size: 14px;
  font-weight: 600;
  color: var(--sbti-text);
  min-width: 4.5rem;
  text-align: right;
}

.hint {
  margin: 0;
  font-size: 14px;
  color: var(--sbti-muted);
  line-height: 1.5;
}

.q-card .q-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.badge {
  font-size: 12px;
  font-weight: 600;
  background: var(--sbti-soft);
  color: var(--sbti-accent-strong);
  padding: 4px 10px;
  border-radius: 999px;
}

.dim-tag {
  font-size: 12px;
  color: var(--sbti-muted);
}

.q-text {
  margin: 0 0 1rem;
  font-size: 15px;
  line-height: 1.65;
  color: var(--sbti-text);
}

.options {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.option {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 14px;
  border: 1px solid var(--sbti-line);
  border-radius: 14px;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}

.option:hover {
  border-color: var(--sbti-accent);
  background: rgba(108, 141, 113, 0.06);
}

.option.checked {
  border-color: var(--sbti-accent-strong);
  background: var(--sbti-soft);
}

.option input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.opt-code {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 700;
  background: var(--sbti-soft);
  color: var(--sbti-accent-strong);
  border-radius: 8px;
}

.opt-label {
  font-size: 14px;
  line-height: 1.5;
  color: var(--sbti-text);
}

.actions-bottom .btn-row,
.result-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.result-grid {
  display: grid;
  gap: 1.25rem;
  margin-bottom: 1.5rem;
}

@media (min-width: 600px) {
  .result-grid {
    grid-template-columns: 1fr 1.1fr;
    align-items: start;
  }
}

.poster-box {
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--sbti-line);
  background: var(--sbti-soft);
}

.poster-box.no-image {
  min-height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.poster-img {
  width: 100%;
  display: block;
  max-height: 280px;
  object-fit: contain;
  background: #fff;
}

.poster-caption {
  margin: 0;
  padding: 12px 14px;
  font-size: 14px;
  color: var(--sbti-muted);
  font-style: italic;
  border-top: 1px solid var(--sbti-line);
}

.type-kicker {
  font-size: 13px;
  color: var(--sbti-accent-strong);
  font-weight: 600;
  margin-bottom: 6px;
}

.type-name {
  font-size: clamp(1.25rem, 3vw, 1.6rem);
  font-weight: 800;
  color: var(--sbti-text);
  margin-bottom: 8px;
}

.match-badge {
  display: inline-block;
  font-size: 13px;
  padding: 6px 12px;
  background: var(--sbti-soft);
  border-radius: 999px;
  color: var(--sbti-accent-strong);
  margin-bottom: 10px;
}

.type-sub {
  margin: 0;
  font-size: 14px;
  line-height: 1.55;
  color: var(--sbti-muted);
}

.analysis-box,
.dim-box,
.note-box {
  margin-top: 1.25rem;
  padding-top: 1.25rem;
  border-top: 1px solid var(--sbti-line);
}

.analysis-box h3,
.dim-box h3,
.note-box h3 {
  margin: 0 0 10px;
  font-size: 16px;
  color: var(--sbti-text);
}

.desc {
  margin: 0;
  font-size: 14px;
  line-height: 1.7;
  color: var(--sbti-muted);
}

.dim-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.dim-item {
  padding: 12px 14px;
  background: var(--sbti-soft);
  border-radius: 12px;
  border: 1px solid var(--sbti-line);
}

.dim-item-top {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 10px;
  margin-bottom: 6px;
}

.dim-name {
  font-size: 14px;
  font-weight: 600;
  color: var(--sbti-text);
}

.dim-score {
  font-size: 13px;
  color: var(--sbti-accent-strong);
  white-space: nowrap;
}

.dim-expl {
  margin: 0;
  font-size: 13px;
  line-height: 1.55;
  color: var(--sbti-muted);
}

.note-box p {
  margin: 0;
  font-size: 14px;
  line-height: 1.65;
  color: var(--sbti-muted);
}
</style>
