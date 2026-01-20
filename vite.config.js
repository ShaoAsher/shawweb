import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [vue()],
  base: '/shawweb/',
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // 启用源码映射（生产环境可设为 false）
    sourcemap: false,
    // 代码混淆和压缩 - 使用 terser
    minify: 'terser',
    terserOptions: {
      compress: {
        // 删除 console 和 debugger
        drop_console: true,
        drop_debugger: true,
        // 删除特定函数调用
        pure_funcs: ['console.log', 'console.info', 'console.debug', 'console.warn'],
        // 删除无法访问的代码
        dead_code: true,
        // 优化条件表达式
        conditionals: true,
        // 优化布尔值
        booleans: true,
        // 删除未使用的变量
        unused: true,
        // 优化 if-return 和 if-continue
        if_return: true,
        // 合并连续的变量声明
        join_vars: true,
        // 折叠常量
        collapse_vars: true,
        // 减少代码体积
        reduce_vars: true,
        // 传递次数
        passes: 2
      },
      mangle: {
        // Safari 10 兼容
        safari10: true
        // 注意：不要启用 toplevel 和 properties，会破坏 Vue 组件
      },
      format: {
        // 删除所有注释
        comments: false,
        // ASCII 输出
        ascii_only: true
      }
    },
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html')
      },
      output: {
        // 混淆文件名 - 使用 hash
        chunkFileNames: 'assets/js/[hash].js',
        entryFileNames: 'assets/js/[hash].js',
        assetFileNames: 'assets/[ext]/[hash].[ext]',
        // 手动分块优化
        manualChunks(id) {
          if (id.includes('node_modules')) {
            // 将 node_modules 中的依赖分离
            if (id.includes('vue')) {
              return 'vue-vendor'
            }
            if (id.includes('crypto-js') || id.includes('node-forge')) {
              return 'crypto-vendor'
            }
            return 'vendor'
          }
        }
      }
    },
    // 块大小警告限制
    chunkSizeWarningLimit: 1000
  },
  server: {
    port: 3000,
    open: true
  }
})
