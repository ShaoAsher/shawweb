# Shaw Web Tools - Vue 版本

一个基于 Vue 3 + Vite 的移动开发工具集合，包含 Android 签名生成、APK 分析、图片处理、加解密、颜色转换、时间戳转换等实用工具。

## 🚀 快速开始

### 本地开发

1. **安装依赖**
   ```bash
   npm install
   ```

2. **启动开发服务器**
   ```bash
   npm run dev
   ```
   访问 http://localhost:3000

3. **构建生产版本**
   ```bash
   npm run build
   ```

4. **预览生产构建**
   ```bash
   npm run preview
   ```

## 📦 项目结构

项目采用 Vue 3 + Vite 架构，工具组件按功能分类组织在 `src/views/tools/` 目录下，文件夹结构与原始 HTML 文件结构保持一致。

## 🌐 GitHub Pages 部署

项目已配置 GitHub Actions，推送到 `main` 分支后会自动部署到 GitHub Pages。

### 部署流程

1. 推送代码到 `main` 分支
2. GitHub Actions 自动触发构建
3. 构建完成后自动部署到 GitHub Pages

### 访问地址

部署完成后，访问：`https://你的用户名.github.io/仓库名/`

## 🎨 特性

- ✅ Vue 3 + Vite 现代化开发体验
- ✅ 响应式设计，支持移动端和桌面端
- ✅ 多主题切换系统
- ✅ 工具搜索和分类
- ✅ GitHub Pages 自动部署
- ✅ 本地开发热重载

## 📝 开发说明

### 添加新工具

1. 在 `src/views/tools/` 对应分类目录下创建 Vue 组件
2. 在 `src/router/index.js` 中添加路由映射
3. 在 `src/data/tools.js` 中添加工具配置

### 修改主题

主题配置在 `src/utils/themes.js` 中，支持多种主题切换。

## 📄 License

MIT License
