<template>
  <ToolLayout
    title="大话骰子 (Liar's Dice)"
    description="3D 模拟大话骰子游戏，真实物理手感，聚会娱乐必备"
    icon="🎲"
  >
    <div class="game-wrapper" ref="wrapper">
      <div id="game-container" ref="container"></div>
      
      <!-- 游戏控制层 -->
      <div class="controls-overlay">
        <!-- 操作按钮 -->
        <div class="action-bar">
          <AppButton 
            @click="shakeDice" 
            :disabled="isShaking" 
            variant="primary" 
            size="lg"
            icon="🎲"
            class="action-btn"
          >
            {{ isShaking ? '摇骰中...' : '摇骰子' }}
          </AppButton>
          
          <div class="sub-actions">
            <AppButton 
              @click="toggleReveal" 
              :disabled="isShaking" 
              :variant="isRevealed ? 'warning' : 'success'"
              icon="👐"
            >
              {{ isRevealed ? '盖上' : '开盅' }}
            </AppButton>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, nextTick } from 'vue'
import * as THREE from 'three'
import gsap from 'gsap'
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'

// 状态管理
const container = ref(null)
const wrapper = ref(null)
const isShaking = ref(false)
const isRevealed = ref(false)
const diceResults = ref([1, 1, 1, 1, 1])

// Three.js 变量
let scene, camera, renderer, animationId
let diceMeshes = []
let cupMesh
let tableMesh

// 音频上下文
let audioCtx

// 初始化音频
const initAudio = () => {
  try {
    const AudioContext = window.AudioContext || window.webkitAudioContext
    audioCtx = new AudioContext()
  } catch (e) {
    console.warn('Web Audio API not supported')
  }
}

// 播放摇骰子音效 (白噪音 + 震动)
const playShakeSound = () => {
  if (!audioCtx) initAudio()
  if (audioCtx.state === 'suspended') audioCtx.resume()

  const t = audioCtx.currentTime
  const osc = audioCtx.createOscillator()
  const gain = audioCtx.createGain()
  const filter = audioCtx.createBiquadFilter()

  // 模拟碰撞杂音
  const bufferSize = audioCtx.sampleRate * 0.5 // 0.5秒
  const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate)
  const data = buffer.getChannelData(0)
  for (let i = 0; i < bufferSize; i++) {
    data[i] = Math.random() * 2 - 1
  }

  const noise = audioCtx.createBufferSource()
  noise.buffer = buffer
  noise.loop = true
  
  filter.type = 'lowpass'
  filter.frequency.setValueAtTime(800, t)
  filter.frequency.linearRampToValueAtTime(100, t + 0.4)

  gain.gain.setValueAtTime(0.5, t)
  gain.gain.exponentialRampToValueAtTime(0.01, t + 0.4)

  noise.connect(filter)
  filter.connect(gain)
  gain.connect(audioCtx.destination)

  noise.start(t)
  noise.stop(t + 0.4)
}

// 播放开盅音效 (Whoosh)
const playRevealSound = () => {
  if (!audioCtx) initAudio()
  if (audioCtx.state === 'suspended') audioCtx.resume()

  const t = audioCtx.currentTime
  const osc = audioCtx.createOscillator()
  const gain = audioCtx.createGain()

  osc.frequency.setValueAtTime(200, t)
  osc.frequency.exponentialRampToValueAtTime(600, t + 0.2)
  
  gain.gain.setValueAtTime(0.1, t)
  gain.gain.linearRampToValueAtTime(0, t + 0.2)

  osc.connect(gain)
  gain.connect(audioCtx.destination)

  osc.start(t)
  osc.stop(t + 0.2)
}

// 骰子材质缓存
const diceMaterials = []

// 初始化场景
const initScene = () => {
  const width = container.value.clientWidth
  const height = container.value.clientHeight

  // 1. 场景
  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xe0e5ec) // 亮色背景
  // 移除雾效，保持清晰
  // scene.fog = new THREE.Fog(0x1a1a1a, 10, 50)

  // 2. 相机
  camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100)
  camera.position.set(0, 18, 12) // 调整相机角度，更俯视一点
  camera.lookAt(0, 0, 0)

  // 3. 渲染器
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(width, height)
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.0
  container.value.appendChild(renderer.domElement)

  // 灯光
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.8) // 更强的环境光
  scene.add(ambientLight)

  const dirLight = new THREE.DirectionalLight(0xffffff, 1.5) // 更强的主光源
  dirLight.position.set(5, 20, 10)
  dirLight.castShadow = true
  dirLight.shadow.mapSize.width = 2048
  dirLight.shadow.mapSize.height = 2048
  dirLight.shadow.bias = -0.0001
  scene.add(dirLight)
  
  const spotLight = new THREE.SpotLight(0xffaa00, 0.5) // 辅助暖光减弱
  spotLight.position.set(-10, 15, 5)
  spotLight.angle = Math.PI / 6
  spotLight.penumbra = 0.5
  spotLight.castShadow = true
  scene.add(spotLight)

  // 5. 地面 (桌子)
  createTable()

  // 6. 骰子
  createDiceMaterials()
  createDice()

  // 7. 骰盅
  createCup()

  // 8. 动画循环
  animate()

  // 9. 响应式
  window.addEventListener('resize', onWindowResize)
}

// 创建桌子
const createTable = () => {
  // 亮色木纹
  const geometry = new THREE.PlaneGeometry(100, 100)
  const material = new THREE.MeshStandardMaterial({ 
    color: 0x8fbc8f, // DarkSeaGreen 比较明亮清新的绿色
    roughness: 0.5,
    metalness: 0.0
  })
  tableMesh = new THREE.Mesh(geometry, material)
  tableMesh.rotation.x = -Math.PI / 2
  tableMesh.receiveShadow = true
  scene.add(tableMesh)
  
  // 游戏区域光圈 - 白色
  const ringGeo = new THREE.RingGeometry(5.8, 6.0, 64) // 扩大一点范围
  const ringMat = new THREE.MeshBasicMaterial({ 
    color: 0xffffff, 
    side: THREE.DoubleSide, 
    transparent: true, 
    opacity: 0.6,
  })
  const ring = new THREE.Mesh(ringGeo, ringMat)
  ring.rotation.x = -Math.PI / 2
  ring.position.y = 0.02
  scene.add(ring)
}

// 生成高分辨率骰子贴图
const createDiceTexture = (number, color = '#000000', bgColor = '#ffffff') => {
  const size = 512 // 更高分辨率
  const canvas = document.createElement('canvas')
  canvas.width = size
  canvas.height = size
  const ctx = canvas.getContext('2d')

  // 背景 - 纯白
  ctx.fillStyle = '#ffffff'
  ctx.fillRect(0, 0, size, size)
  
  // 极细微的内阴影，增加立体感
  const grad = ctx.createRadialGradient(size/2, size/2, size/3, size/2, size/2, size/1.5)
  grad.addColorStop(0, 'rgba(0,0,0,0)')
  grad.addColorStop(1, 'rgba(0,0,0,0.05)')
  ctx.fillStyle = grad
  ctx.fillRect(0, 0, size, size)
  
  // 边框 - 浅灰
  ctx.strokeStyle = '#eeeeee'
  ctx.lineWidth = 16
  ctx.strokeRect(0, 0, size, size)

  // 点 - 鲜艳红和深黑
  ctx.fillStyle = (number === 1 || number === 4) ? '#ff0000' : '#000000'
  
  const dotSize = 70 // 更大的点
  const center = size / 2
  const offset = 130 // 调整间距

  const drawDot = (x, y) => {
    // 移除阴影，保持扁平清晰
    ctx.beginPath()
    ctx.arc(x, y, dotSize / 2, 0, Math.PI * 2)
    ctx.fill()
  }

  // 绘制点逻辑
  if (number % 2 === 1) drawDot(center, center)
  if (number > 1) {
    drawDot(center - offset, center - offset)
    drawDot(center + offset, center + offset)
  }
  if (number > 3) {
    drawDot(center + offset, center - offset)
    drawDot(center - offset, center + offset)
  }
  if (number === 6) {
    drawDot(center - offset, center)
    drawDot(center + offset, center)
  }

  return new THREE.CanvasTexture(canvas)
}

// 创建骰子材质
const createDiceMaterials = () => {
  const map = [3, 4, 1, 6, 2, 5]
  
  for (let i = 0; i < 6; i++) {
    const val = map[i]
    diceMaterials.push(new THREE.MeshStandardMaterial({
      map: createDiceTexture(val),
      color: 0xffffff, // 纯白基底
      roughness: 0.2, // 光滑
      metalness: 0.0,
    }))
  }
}

// 创建骰子
const createDice = () => {
  // 使用 BoxGeometry，但在材质上模拟一点圆角感(通过纹理)
  const geometry = new THREE.BoxGeometry(1.2, 1.2, 1.2)
  
  for (let i = 0; i < 5; i++) {
    const mesh = new THREE.Mesh(geometry, diceMaterials)
    mesh.castShadow = true
    mesh.receiveShadow = true
    
    // 初始化时确保分散
    randomizeDicePosition(mesh, i)
    
    diceMeshes.push(mesh)
    scene.add(mesh)
  }
}

// 随机化骰子位置和旋转，增加防止重叠的简单逻辑
const randomizeDicePosition = (mesh, index) => {
  // 使用固定的五边形锚点分布，确保物理上不接触
  // 骰子对角线约 1.2 * sqrt(3) ≈ 2.1
  // 圆周半径设为 3.0，周长约 18.8，除以5每个扇区弧长约 3.7，足够放下 2.1 的骰子
  
  const radius = 2.8 
  const angleStep = (Math.PI * 2) / 5
  
  // 基础角度
  const baseAngle = index * angleStep
  
  // 增加微小随机扰动，但不至于让它们碰到
  // 角度扰动 +/- 10度 (0.17弧度)
  const randomAngle = baseAngle + (Math.random() - 0.5) * 0.2 // 减小角度扰动
  
  // 半径扰动 +/- 0.2
  // 稍微缩小半径，让骰子更聚拢一点，避免碰到杯壁
  const randomRadius = (radius - 0.2) + (Math.random() - 0.5) * 0.3
  
  mesh.position.x = randomRadius * Math.cos(randomAngle)
  mesh.position.z = randomRadius * Math.sin(randomAngle)
  mesh.position.y = 0.6 // 刚好放在桌面上 (1.2 / 2)
  
  mesh.rotation.x = Math.random() * Math.PI * 2
  mesh.rotation.y = Math.random() * Math.PI * 2
  mesh.rotation.z = Math.random() * Math.PI * 2
}

// 创建骰盅 - 优化模型
const createCup = () => {
  cupMesh = new THREE.Group()

  // 材质 - 皮革质感
  const leatherMaterial = new THREE.MeshStandardMaterial({ 
    color: 0xa0522d, // Siena - 更亮的棕色
    roughness: 0.4,
    metalness: 0.1,
    side: THREE.DoubleSide
  })

  // 杯身
  const bodyGeo = new THREE.CylinderGeometry(2.8, 4.0, 6.0, 32, 1, true) // 扩大半径和高度
  const body = new THREE.Mesh(bodyGeo, leatherMaterial)
  body.position.y = 3.0
  body.castShadow = true
  cupMesh.add(body)

  // 杯底
  const capGeo = new THREE.CircleGeometry(2.8, 32) // 对应杯身顶部半径
  const cap = new THREE.Mesh(capGeo, leatherMaterial)
  cap.rotation.x = -Math.PI / 2
  cap.position.y = 6.0
  cap.castShadow = true
  cupMesh.add(cap)

  // 杯口装饰环 (金色)
  const rimGeo = new THREE.TorusGeometry(4.0, 0.2, 16, 64) // 对应杯身底部半径
  const rimMat = new THREE.MeshStandardMaterial({ color: 0xffd700, roughness: 0.3, metalness: 0.8 })
  const rim = new THREE.Mesh(rimGeo, rimMat)
  rim.rotation.x = Math.PI / 2
  rim.position.y = 0
  cupMesh.add(rim)
  
  scene.add(cupMesh)
}

// 设置骰子最终朝向
const setDiceOrientation = (mesh, value) => {
  mesh.rotation.set(0, 0, 0)
  const randomY = Math.random() * Math.PI * 2
  
  switch(value) {
    case 1: mesh.rotation.x = 0; mesh.rotation.z = 0; break
    case 6: mesh.rotation.x = Math.PI; break
    case 2: mesh.rotation.x = -Math.PI / 2; break
    case 5: mesh.rotation.x = Math.PI / 2; break
    case 3: mesh.rotation.z = -Math.PI / 2; break
    case 4: mesh.rotation.z = Math.PI / 2; break
  }
  
  mesh.rotateOnWorldAxis(new THREE.Vector3(0, 1, 0), randomY)
}

// 摇骰子逻辑
const shakeDice = () => {
  if (isShaking.value) return
  isShaking.value = true
  isRevealed.value = false
  
  // 播放音效
  playShakeSound()

  // 1. 盖上杯子
  gsap.to(cupMesh.position, {
    y: 0,
    duration: 0.3,
    ease: "power2.in",
    onComplete: () => {
      startShakingAnimation()
    }
  })
}

const startShakingAnimation = () => {
  // 生成新结果
  diceResults.value = Array.from({ length: 5 }, () => Math.floor(Math.random() * 6) + 1)
  
  const tl = gsap.timeline({
    onComplete: () => {
      isShaking.value = false
      settleDice()
    }
  })
  
  // 剧烈摇晃动画
  tl.to(cupMesh.position, { x: -2.5, z: 2.5, y: 1.5, duration: 0.08 })
    .to(cupMesh.position, { x: 2.5, z: -2.5, y: 0.8, duration: 0.08 })
    .to(cupMesh.position, { x: -2.5, z: -2.5, y: 1.5, duration: 0.08 })
    .to(cupMesh.position, { x: 2.5, z: 2.5, y: 0.8, duration: 0.08 })
    .to(cupMesh.position, { x: 0, z: 0, y: 0, duration: 0.2, ease: "bounce.out" })
    
  // 模拟骰子乱飞
  const shakeInterval = setInterval(() => {
    diceMeshes.forEach((mesh, i) => {
      randomizeDicePosition(mesh, i)
      mesh.rotation.x = Math.random() * Math.PI
      mesh.rotation.z = Math.random() * Math.PI
    })
  }, 40)
  
  setTimeout(() => {
    clearInterval(shakeInterval)
  }, 320)
}

const settleDice = () => {
  diceMeshes.forEach((mesh, index) => {
    randomizeDicePosition(mesh, index)
    setDiceOrientation(mesh, diceResults.value[index])
  })
}

// 开盅/盖上
const toggleReveal = () => {
  if (isShaking.value) return
  isRevealed.value = !isRevealed.value
  
  if (isRevealed.value) {
    playRevealSound()
    gsap.to(cupMesh.position, { y: 12, duration: 0.5, ease: "back.out(1.2)" })
    gsap.to(cupMesh.rotation, { x: 0, z: 0, duration: 0.3 })
  } else {
    gsap.to(cupMesh.position, { y: 0, duration: 0.4, ease: "power2.in" })
  }
}

const animate = () => {
  animationId = requestAnimationFrame(animate)
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
  height: 600px; /* 固定高度确保 3D 场景展示 */
  background: radial-gradient(circle at center, #2c3e50 0%, #000000 100%);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: inset 0 0 20px rgba(0,0,0,0.5);
}

#game-container {
  width: 100%;
  height: 100%;
}

.controls-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  padding: 20px;
  background: linear-gradient(to top, rgba(0,0,0,0.8) 0%, rgba(0,0,0,0) 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  pointer-events: none; /* 让点击穿透到 3D 场景，但在按钮上恢复 */
}

.action-bar {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  width: 100%;
  pointer-events: auto;
}

.sub-actions {
  display: flex;
  gap: 16px;
}

.action-btn {
  min-width: 160px;
}

@keyframes shake {
  0% { transform: translate(1px, 1px) rotate(0deg); }
  10% { transform: translate(-1px, -2px) rotate(-1deg); }
  20% { transform: translate(-3px, 0px) rotate(1deg); }
  30% { transform: translate(3px, 2px) rotate(0deg); }
  40% { transform: translate(1px, -1px) rotate(1deg); }
  50% { transform: translate(-1px, 2px) rotate(-1deg); }
  60% { transform: translate(-3px, 1px) rotate(0deg); }
  70% { transform: translate(3px, 1px) rotate(-1deg); }
  80% { transform: translate(-1px, -1px) rotate(1deg); }
  90% { transform: translate(1px, 2px) rotate(0deg); }
  100% { transform: translate(1px, -2px) rotate(-1deg); }
}

@keyframes popIn {
  from { transform: scale(0); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

/* 移动端适配 */
@media (max-width: 600px) {
  .game-wrapper {
    height: 500px;
  }
}
</style>
