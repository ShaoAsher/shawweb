<template>
  <ToolLayout
    title="3D 真心话转瓶"
    description="经典的聚会游戏，旋转精致的 3D 瓶子决定谁是幸运儿"
    icon="🍾"
  >
    <div class="game-wrapper" ref="wrapper">
      <div id="game-container" ref="container"></div>
      
      <!-- 控制层 -->
      <div class="controls-overlay">
        <div class="action-bar">
          <AppButton 
            @click="spinBottle" 
            :disabled="isSpinning" 
            variant="primary" 
            size="lg"
            class="spin-btn"
          >
            {{ isSpinning ? '旋转中...' : '开始旋转' }}
          </AppButton>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import * as THREE from 'three'
import gsap from 'gsap'
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'

// 状态
const container = ref(null)
const isSpinning = ref(false)

// Three.js 变量
let scene, camera, renderer, animationId
let bottleMesh
let tableMesh

// 音频
let audioCtx

const initAudio = () => {
  try {
    const AudioContext = window.AudioContext || window.webkitAudioContext
    audioCtx = new AudioContext()
  } catch (e) {
    console.warn('Web Audio API not supported')
  }
}

const playSpinSound = (duration) => {
  if (!audioCtx) initAudio()
  if (audioCtx.state === 'suspended') audioCtx.resume()

  const t = audioCtx.currentTime
  const osc = audioCtx.createOscillator()
  const gain = audioCtx.createGain()
  const filter = audioCtx.createBiquadFilter()

  // 模拟瓶子摩擦桌面的声音
  osc.type = 'sawtooth'
  osc.frequency.setValueAtTime(100, t)
  osc.frequency.linearRampToValueAtTime(50, t + duration)

  filter.type = 'lowpass'
  filter.frequency.setValueAtTime(800, t)
  filter.frequency.linearRampToValueAtTime(200, t + duration)

  gain.gain.setValueAtTime(0.1, t)
  gain.gain.exponentialRampToValueAtTime(0.001, t + duration)

  osc.connect(filter)
  filter.connect(gain)
  gain.connect(audioCtx.destination)

  osc.start(t)
  osc.stop(t + duration)
}

const initScene = () => {
  const width = container.value.clientWidth
  const height = container.value.clientHeight

  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xe0e5ec) // 与大话骰子保持一致的亮色风格

  camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100)
  camera.position.set(0, 20, 15)
  camera.lookAt(0, 0, 0)

  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(width, height)
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.0
  container.value.appendChild(renderer.domElement)

  // 灯光
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.8)
  scene.add(ambientLight)

  const dirLight = new THREE.DirectionalLight(0xffffff, 1.5)
  dirLight.position.set(10, 20, 10)
  dirLight.castShadow = true
  dirLight.shadow.mapSize.width = 2048
  dirLight.shadow.mapSize.height = 2048
  scene.add(dirLight)
  
  // 点光源增加玻璃反光
  const pointLight = new THREE.PointLight(0xffaa00, 1.0)
  pointLight.position.set(-5, 5, 5)
  scene.add(pointLight)

  createTable()
  createBottle()
  animate()

  window.addEventListener('resize', onWindowResize)
}

const createTable = () => {
  const geometry = new THREE.PlaneGeometry(100, 100)
  const material = new THREE.MeshStandardMaterial({ 
    color: 0x8fbc8f, // DarkSeaGreen
    roughness: 0.5,
    metalness: 0.0
  })
  tableMesh = new THREE.Mesh(geometry, material)
  tableMesh.rotation.x = -Math.PI / 2
  tableMesh.receiveShadow = true
  scene.add(tableMesh)
  
  // 中心装饰
  const ringGeo = new THREE.RingGeometry(8, 8.2, 64)
  const ringMat = new THREE.MeshBasicMaterial({ 
    color: 0xffffff, 
    side: THREE.DoubleSide, 
    transparent: true, 
    opacity: 0.5 
  })
  const ring = new THREE.Mesh(ringGeo, ringMat)
  ring.rotation.x = -Math.PI / 2
  ring.position.y = 0.02
  scene.add(ring)
}

const createBottle = () => {
  // 使用 LatheGeometry 生成瓶子形状
  const points = []
  // 瓶底
  points.push(new THREE.Vector2(0, 0))
  points.push(new THREE.Vector2(2.5, 0))
  points.push(new THREE.Vector2(2.5, 8)) // 瓶身
  points.push(new THREE.Vector2(1, 9))   // 肩部
  points.push(new THREE.Vector2(1, 12))  // 瓶颈
  points.push(new THREE.Vector2(1.2, 12.2)) // 瓶口
  points.push(new THREE.Vector2(0.8, 12.2)) // 瓶口内侧

  const geometry = new THREE.LatheGeometry(points, 32)
  
  // 玻璃材质
  const material = new THREE.MeshPhysicalMaterial({
    color: 0x44cf6e, // 绿色玻璃瓶
    metalness: 0,
    roughness: 0,
    transmission: 0.9, // 透光
    thickness: 0.5,
    envMapIntensity: 1.0,
    clearcoat: 1.0,
    clearcoatRoughness: 0.1
  })

  bottleMesh = new THREE.Mesh(geometry, material)
  bottleMesh.castShadow = true
  // 瓶子默认是立着的，我们需要让他躺在桌子上旋转
  // 先创建一个容器 Group 来控制中心点
  const group = new THREE.Group()
  
  // 将瓶子放倒
  bottleMesh.rotation.z = -Math.PI / 2 
  // 调整瓶子在 Group 中的位置，使其围绕质心旋转 (大概在瓶身中间)
  bottleMesh.position.x = -4 
  bottleMesh.position.y = 1.5 // 半径2.5，躺下后高度约1.25+微调
  
  group.add(bottleMesh)
  
  // 添加一个瓶塞作为指向标志
  const capGeo = new THREE.CylinderGeometry(1, 1, 1.5, 32)
  const capMat = new THREE.MeshStandardMaterial({ color: 0x8b4513 }) // 软木塞
  const cap = new THREE.Mesh(capGeo, capMat)
  cap.rotation.z = -Math.PI / 2
  cap.position.x = 8 // 瓶口位置
  cap.position.y = 1.5
  group.add(cap)

  bottleMesh = group
  scene.add(bottleMesh)
}

const spinBottle = () => {
  if (isSpinning.value) return
  isSpinning.value = true

  // 随机旋转圈数 (5-10圈) + 随机角度
  const extraRotation = Math.PI * 2 * (5 + Math.random() * 5)
  const randomAngle = Math.random() * Math.PI * 2
  const totalRotation = bottleMesh.rotation.y + extraRotation + randomAngle
  const duration = 4 + Math.random() * 2 // 4-6秒

  playSpinSound(duration)

  gsap.to(bottleMesh.rotation, {
    y: totalRotation,
    duration: duration,
    ease: "power4.out", // 模拟摩擦力减速
    onComplete: () => {
      isSpinning.value = false
    }
  })
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
  height: 600px;
  background: radial-gradient(circle at center, #f0f4f8 0%, #d9e2ec 100%);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: inset 0 0 20px rgba(0,0,0,0.05);
}

#game-container {
  width: 100%;
  height: 100%;
}

.controls-overlay {
  position: absolute;
  bottom: 30px;
  left: 0;
  width: 100%;
  display: flex;
  justify-content: center;
  pointer-events: none;
}

.action-bar {
  pointer-events: auto;
}

.spin-btn {
  min-width: 180px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
</style>
