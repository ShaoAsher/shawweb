<template>
  <ToolLayout
    title="3D 反应力训练"
    description="专业级 FPS 练枪与反应力训练工具"
    icon="🎯"
  >
    <div class="game-wrapper" ref="wrapper">
      <div id="game-container" ref="container"></div>
      
      <!-- UI 层 -->
      <div class="ui-layer">
        <!-- 菜单界面 -->
        <div v-if="gameState === 'menu'" class="menu-screen">
          <div class="title">REACTION LAB</div>
          <div class="mode-grid">
            <button 
              v-for="mode in modes" 
              :key="mode.id"
              class="mode-card"
              @click="startGame(mode.id)"
            >
              <div class="mode-icon">{{ mode.icon }}</div>
              <div class="mode-name">{{ mode.name }}</div>
              <div class="mode-desc">{{ mode.desc }}</div>
            </button>
          </div>
        </div>

        <!-- 游戏 HUD -->
        <div v-if="gameState === 'playing'" class="hud-screen">
          <div class="top-bar">
            <div class="stat-box">
              <div class="label">得分</div>
              <div class="value">{{ score }}</div>
            </div>
            <div class="stat-box">
              <div class="label">时间</div>
              <div class="value" :class="{ warning: timeLeft < 5 }">{{ timeLeft.toFixed(1) }}</div>
            </div>
            <div class="stat-box">
              <div class="label">命中率</div>
              <div class="value">{{ accuracy }}%</div>
            </div>
          </div>
          <div class="crosshair"></div>
          
          <AppButton @click="endGame" variant="secondary" size="sm" class="quit-btn">
            退出训练
          </AppButton>
        </div>

        <!-- 结算界面 -->
        <div v-if="gameState === 'gameover'" class="result-screen">
          <div class="result-title">训练报告</div>
          
          <div class="rank-badge">{{ getRank(score) }}</div>
          
          <div class="stats-grid">
            <div class="stat-item">
              <div class="label">最终得分</div>
              <div class="value highlight">{{ score }}</div>
            </div>
            <div class="stat-item">
              <div class="label">平均反应</div>
              <div class="value">{{ avgReactionTime }}<span class="unit">ms</span></div>
            </div>
            <div class="stat-item">
              <div class="label">命中率</div>
              <div class="value">{{ accuracy }}<span class="unit">%</span></div>
            </div>
            <div class="stat-item">
              <div class="label">有效点击</div>
              <div class="value">{{ hits }}/{{ clicks }}</div>
            </div>
          </div>
          
          <div class="action-buttons">
            <AppButton @click="gameState = 'menu'" variant="secondary" icon="🏠">
              返回主页
            </AppButton>
            <AppButton @click="startGame(currentMode)" variant="primary" icon="🔄">
              再次挑战
            </AppButton>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed } from 'vue'
import * as THREE from 'three'
import gsap from 'gsap'
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'

// 游戏模式配置
const modes = [
  { 
    id: 'grid', 
    name: '网格射击', 
    icon: '🕸️',
    desc: '3x3 网格随机出现目标，训练定点记忆与快速定位。' 
  },
  { 
    id: 'reflex', 
    name: '极速反应', 
    icon: '⚡',
    desc: '目标瞬间出现，考验纯粹的视觉反应速度。' 
  },
  { 
    id: 'tracking', 
    name: '动态追踪', 
    icon: '🎯',
    desc: '目标持续移动，训练平滑跟枪能力。' 
  },
  { 
    id: 'precision', 
    name: '微小目标', 
    icon: '🔬',
    desc: '极小目标精准打击，训练高精度鼠标控制。' 
  }
]

// 状态
const container = ref(null)
const gameState = ref('menu')
const currentMode = ref('grid')
const score = ref(0)
const timeLeft = ref(60)
const clicks = ref(0)
const hits = ref(0)
const reactionTimes = ref([])

const avgReactionTime = computed(() => {
  if (reactionTimes.value.length === 0) return 0
  const sum = reactionTimes.value.reduce((a, b) => a + b, 0)
  return Math.round(sum / reactionTimes.value.length)
})

const accuracy = computed(() => {
  if (clicks.value === 0) return 0
  return Math.round((hits.value / clicks.value) * 100)
})

const getRank = (s) => {
  if (s > 80000) return 'S+'
  if (s > 60000) return 'S'
  if (s > 40000) return 'A'
  if (s > 20000) return 'B'
  return 'C'
}

// Three.js
let scene, camera, renderer, animationId
let raycaster, mouse
let targets = []
let lastTargetTime = 0
let gameTimer = null

// 音频
let audioCtx
const initAudio = () => {
  try {
    const AudioContext = window.AudioContext || window.webkitAudioContext
    audioCtx = new AudioContext()
  } catch (e) {}
}

const playSound = (type) => {
  if (!audioCtx) initAudio()
  if (audioCtx.state === 'suspended') audioCtx.resume()
  
  const t = audioCtx.currentTime
  const osc = audioCtx.createOscillator()
  const gain = audioCtx.createGain()
  
  if (type === 'hit') {
    osc.frequency.setValueAtTime(880, t)
    osc.frequency.exponentialRampToValueAtTime(1760, t + 0.05)
    gain.gain.setValueAtTime(0.2, t)
    gain.gain.exponentialRampToValueAtTime(0.01, t + 0.05)
  } else if (type === 'miss') {
    osc.type = 'square'
    osc.frequency.setValueAtTime(150, t)
    osc.frequency.linearRampToValueAtTime(100, t + 0.1)
    gain.gain.setValueAtTime(0.1, t)
    gain.gain.exponentialRampToValueAtTime(0.01, t + 0.1)
  }
  
  osc.connect(gain)
  gain.connect(audioCtx.destination)
  osc.start(t)
  osc.stop(t + 0.1)
}

const initScene = () => {
  const width = container.value.clientWidth
  const height = container.value.clientHeight

  scene = new THREE.Scene()
  scene.background = new THREE.Color(0x1a1a2e)
  
  // 网格墙面
  const gridHelper = new THREE.GridHelper(40, 40, 0x33334d, 0x252535)
  gridHelper.rotation.x = Math.PI / 2
  gridHelper.position.z = -10
  scene.add(gridHelper)

  camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 100)
  camera.position.set(0, 0, 10)
  
  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize(width, height)
  renderer.setPixelRatio(window.devicePixelRatio)
  container.value.appendChild(renderer.domElement)

  const ambientLight = new THREE.AmbientLight(0xffffff, 0.8)
  scene.add(ambientLight)
  
  const dirLight = new THREE.DirectionalLight(0xffffff, 0.5)
  dirLight.position.set(0, 0, 10)
  scene.add(dirLight)

  raycaster = new THREE.Raycaster()
  mouse = new THREE.Vector2()

  container.value.addEventListener('mousedown', onMouseDown)
  container.value.addEventListener('mousemove', onMouseMove)

  animate()
  window.addEventListener('resize', onWindowResize)
}

const startGame = (modeId) => {
  currentMode.value = modeId
  gameState.value = 'playing'
  score.value = 0
  timeLeft.value = 60
  clicks.value = 0
  hits.value = 0
  reactionTimes.value = []
  
  // 重置场景
  targets.forEach(t => scene.remove(t.mesh))
  targets = []
  
  spawnTarget()
  
  if (gameTimer) clearInterval(gameTimer)
  gameTimer = setInterval(() => {
    timeLeft.value -= 0.1
    if (timeLeft.value <= 0) {
      endGame()
    }
  }, 100)
}

const endGame = () => {
  if (gameTimer) clearInterval(gameTimer)
  gameState.value = 'gameover'
  targets.forEach(t => scene.remove(t.mesh))
  targets = []
}

const spawnTarget = () => {
  if (gameState.value !== 'playing') return
  
  // 根据模式生成目标
  let geometry, material, mesh
  
  if (currentMode.value === 'precision') {
    geometry = new THREE.SphereGeometry(0.3, 32, 32) // 更小
  } else {
    geometry = new THREE.SphereGeometry(0.6, 32, 32)
  }
  
  material = new THREE.MeshStandardMaterial({
    color: 0x00ffcc,
    emissive: 0x00ffcc,
    emissiveIntensity: 0.5,
    roughness: 0.2,
    metalness: 0.8
  })
  
  mesh = new THREE.Mesh(geometry, material)
  
  // 位置逻辑
  let x, y
  if (currentMode.value === 'grid') {
    // 3x3 网格位置
    const col = Math.floor(Math.random() * 3) - 1 // -1, 0, 1
    const row = Math.floor(Math.random() * 3) - 1
    x = col * 3
    y = row * 3
  } else {
    // 随机分布
    x = (Math.random() - 0.5) * 12
    y = (Math.random() - 0.5) * 8
  }
  
  mesh.position.set(x, y, 0)
  
  // 出现动画
  if (currentMode.value !== 'tracking') {
    mesh.scale.set(0,0,0)
    gsap.to(mesh.scale, { x:1, y:1, z:1, duration: 0.15, ease: "back.out(2)" })
  }
  
  scene.add(mesh)
  
  // Tracking 模式需要特殊处理（移动向量）
  const velocity = currentMode.value === 'tracking' 
    ? new THREE.Vector3((Math.random()-0.5)*0.1, (Math.random()-0.5)*0.1, 0)
    : null

  targets.push({
    mesh,
    bornTime: Date.now(),
    velocity,
    hp: currentMode.value === 'tracking' ? 100 : 1
  })
  
  lastTargetTime = Date.now()
}

const onMouseMove = (event) => {
  const rect = container.value.getBoundingClientRect()
  mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
  mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1
  
  // 极微小的视角晃动模拟呼吸感
  camera.rotation.x = mouse.y * 0.02
  camera.rotation.y = -mouse.x * 0.02
}

const onMouseDown = () => {
  if (gameState.value !== 'playing') return
  clicks.value++
  
  raycaster.setFromCamera(mouse, camera)
  const meshes = targets.map(t => t.mesh)
  const intersects = raycaster.intersectObjects(meshes)
  
  if (intersects.length > 0) {
    const hitObject = intersects[0].object
    const targetIndex = targets.findIndex(t => t.mesh === hitObject)
    
    if (targetIndex !== -1) {
      const target = targets[targetIndex]
      const reaction = Date.now() - target.bornTime
      
      if (currentMode.value === 'tracking') {
        // 追踪模式是按住或持续点击，这里简化为点击一次扣血或销毁
        // 为了简单，追踪模式下点击直接加分但不销毁，除非移动到边界
        score.value += 50
        createParticles(intersects[0].point, 0x00ffcc)
        playSound('hit')
      } else {
        // 其他模式点击即销毁
        reactionTimes.value.push(reaction)
        scene.remove(hitObject)
        targets.splice(targetIndex, 1)
        hits.value++
        score.value += Math.max(100, 2000 - reaction) // 分数计算
        
        createParticles(intersects[0].point, 0x00ffcc)
        playSound('hit')
        spawnTarget() // 立即生成下一个
      }
    }
  } else {
    playSound('miss')
    score.value = Math.max(0, score.value - 200) // 惩罚空枪
  }
}

const createParticles = (pos, color) => {
  const count = 6
  const geo = new THREE.BoxGeometry(0.1, 0.1, 0.1)
  const mat = new THREE.MeshBasicMaterial({ color })
  
  for(let i=0; i<count; i++) {
    const p = new THREE.Mesh(geo, mat)
    p.position.copy(pos)
    scene.add(p)
    
    gsap.to(p.position, {
      x: pos.x + (Math.random()-0.5) * 2,
      y: pos.y + (Math.random()-0.5) * 2,
      z: pos.z + (Math.random()-0.5) * 2,
      duration: 0.4,
      onComplete: () => scene.remove(p)
    })
    gsap.to(p.scale, { x:0, y:0, z:0, duration: 0.4 })
  }
}

const animate = () => {
  animationId = requestAnimationFrame(animate)
  
  // 更新追踪模式的目标移动
  if (gameState.value === 'playing' && currentMode.value === 'tracking') {
    targets.forEach((t, i) => {
      if (t.velocity) {
        t.mesh.position.add(t.velocity)
        // 边界反弹
        if (t.mesh.position.x > 6 || t.mesh.position.x < -6) t.velocity.x *= -1
        if (t.mesh.position.y > 4 || t.mesh.position.y < -4) t.velocity.y *= -1
      }
    })
    // 追踪模式保持目标数量
    if (targets.length < 3) spawnTarget()
  }
  
  renderer.render(scene, camera)
}

const onWindowResize = () => {
  if (!container.value) return
  const width = container.value.clientWidth
  const height = container.value.clientHeight
  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize(width, height)
}

onMounted(() => {
  nextTick(() => {
    initScene()
  })
})

onUnmounted(() => {
  if (gameTimer) clearInterval(gameTimer)
  cancelAnimationFrame(animationId)
  window.removeEventListener('resize', onWindowResize)
  if (renderer) renderer.dispose()
  if (audioCtx) audioCtx.close()
})
</script>

<style scoped>
.game-wrapper {
  position: relative;
  width: 100%;
  height: 600px;
  background: #1a1a2e;
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: crosshair;
  user-select: none;
}

#game-container {
  width: 100%;
  height: 100%;
}

.ui-layer {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

/* 菜单样式 */
.menu-screen {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(26, 26, 46, 0.95);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: auto;
  z-index: 10;
}

.title {
  font-size: 3rem;
  font-weight: 900;
  color: #fff;
  letter-spacing: 4px;
  margin-bottom: 40px;
  text-shadow: 0 0 20px rgba(0, 255, 204, 0.5);
}

.mode-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  max-width: 800px;
}

.mode-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 24px;
  text-align: left;
  cursor: pointer;
  transition: all 0.3s ease;
  width: 280px;
}

.mode-card:hover {
  background: rgba(0, 255, 204, 0.1);
  border-color: #00ffcc;
  transform: translateY(-4px);
}

.mode-icon {
  font-size: 2.5rem;
  margin-bottom: 12px;
}

.mode-name {
  font-size: 1.2rem;
  font-weight: bold;
  color: #fff;
  margin-bottom: 8px;
}

.mode-desc {
  font-size: 0.9rem;
  color: #888;
  line-height: 1.4;
}

/* HUD 样式 */
.hud-screen {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  padding: 24px;
  pointer-events: none;
}

.top-bar {
  display: flex;
  justify-content: center;
  gap: 40px;
}

.stat-box {
  text-align: center;
  background: rgba(0, 0, 0, 0.5);
  padding: 8px 24px;
  border-radius: 8px;
  border-top: 2px solid #00ffcc;
}

.stat-box .label {
  font-size: 0.8rem;
  color: #aaa;
  text-transform: uppercase;
}

.stat-box .value {
  font-size: 1.8rem;
  font-weight: bold;
  color: #fff;
  font-family: monospace;
}

.stat-box .value.warning {
  color: #ff4444;
  animation: pulse 0.5s infinite;
}

.crosshair {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 6px;
  height: 6px;
  background: #00ffcc;
  border-radius: 50%;
  transform: translate(-50%, -50%);
  box-shadow: 0 0 10px #00ffcc;
}

.quit-btn {
  position: absolute;
  top: 24px;
  right: 24px;
  pointer-events: auto;
}

/* 结算样式 */
.result-screen {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(26, 26, 46, 0.95);
  padding: 40px;
  border-radius: 24px;
  text-align: center;
  pointer-events: auto;
  border: 1px solid rgba(255, 255, 255, 0.1);
  min-width: 400px;
}

.result-title {
  font-size: 1.5rem;
  color: #aaa;
  margin-bottom: 20px;
}

.rank-badge {
  font-size: 5rem;
  font-weight: 900;
  color: #00ffcc;
  text-shadow: 0 0 30px rgba(0, 255, 204, 0.6);
  margin-bottom: 30px;
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
}

.stat-item {
  background: rgba(255, 255, 255, 0.05);
  padding: 16px;
  border-radius: 12px;
}

.stat-item .label {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 4px;
}

.stat-item .value {
  font-size: 1.5rem;
  font-weight: bold;
  color: #fff;
}

.stat-item .value.highlight {
  color: #00ffcc;
}

.stat-item .unit {
  font-size: 0.8rem;
  color: #666;
  margin-left: 4px;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}
</style>
