// CDN 资源加载工具
// 用于在 Vue 组件中动态加载外部库

const loadedScripts = new Set()
const loadedStyles = new Set()

export function loadScript(src) {
  return new Promise((resolve, reject) => {
    if (loadedScripts.has(src)) {
      resolve()
      return
    }

    const script = document.createElement('script')
    script.src = src
    script.onload = () => {
      loadedScripts.add(src)
      resolve()
    }
    script.onerror = () => {
      reject(new Error(`Failed to load script: ${src}`))
    }
    document.head.appendChild(script)
  })
}

export function loadStyle(href) {
  return new Promise((resolve, reject) => {
    if (loadedStyles.has(href)) {
      resolve()
      return
    }

    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = href
    link.onload = () => {
      loadedStyles.add(href)
      resolve()
    }
    link.onerror = () => {
      reject(new Error(`Failed to load style: ${href}`))
    }
    document.head.appendChild(link)
  })
}

// 预定义的 CDN 资源
export const CDN_RESOURCES = {
  forge: 'https://cdnjs.cloudflare.com/ajax/libs/forge/1.3.1/forge.min.js',
  cryptoJs: 'https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js',
  jszip: 'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js',
  qrcode: 'https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js',
  jsbarcode: 'https://cdnjs.cloudflare.com/ajax/libs/jsbarcode/3.11.5/JsBarcode.all.min.js'
}
