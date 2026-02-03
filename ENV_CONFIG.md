# 环境变量配置说明

## 📝 配置项详解

### 1. `AUTHOR` - 作者名称
```env
AUTHOR=Hares
```
- **作用**: 显示在 API 响应和页面中的作者信息
- **是否必需**: 否（默认值: Hares）
- **说明**: 可以改成你自己的名字

---

### 2. `TMDB_API_KEY` - TMDB API 密钥
```env
TMDB_API_KEY=your_tmdb_api_key_here
```
- **作用**: 用于访问 The Movie Database (TMDB) API，获取电影/电视剧信息
- **是否必需**: 否（如果不配置，TMDB 相关功能不可用）
- **如何获取**:
  1. 访问 https://www.themoviedb.org/
  2. 注册/登录账号
  3. 进入 Settings → API
  4. 申请 API Key
  5. 复制 API Key 填入此处
- **说明**: 如果不需要 TMDB 功能，可以留空

---

### 3. `DOUBAN_COOKIE` - 豆瓣 Cookie ⚠️ **重要**
```env
DOUBAN_COOKIE='ll="108288"; bid=kuXrYJv8FTc; ...'
```
- **作用**: 用于访问豆瓣网站，避免反爬虫限制
- **是否必需**: **强烈建议配置**（不配置可能遇到反爬虫限制）
- **如何获取**:
  1. 打开浏览器，访问 https://www.douban.com/
  2. 登录你的豆瓣账号
  3. 按 `F12` 打开开发者工具
  4. 切换到 `Network`（网络）标签
  5. 刷新页面或访问任意页面
  6. 点击任意请求，在 `Request Headers` 中找到 `Cookie`
  7. 复制整个 Cookie 值（很长的一串）
  8. 粘贴到配置中，用单引号包裹
- **格式示例**:
  ```env
  DOUBAN_COOKIE='ll="108288"; bid=kuXrYJv8FTc; _vwo_uuid_v2=...; ck=mbRC; ...'
  ```
- **安全提示**: 
  - Cookie 包含登录信息，请妥善保管
  - 不要将包含 Cookie 的 `.env` 文件提交到 Git
  - Cookie 可能会过期，过期后需要重新获取

---

### 4. `QQ_COOKIE` - QQ 音乐 Cookie
```env
QQ_COOKIE='your_qq_music_cookie'
```
- **作用**: 用于访问 QQ 音乐，获取专辑信息
- **是否必需**: 否（如果不需要 QQ 音乐功能，可以留空）
- **如何获取**: 类似豆瓣 Cookie 的获取方式
  1. 访问 https://y.qq.com/
  2. 登录账号
  3. 打开开发者工具，获取 Cookie
- **说明**: 仅在使用 QQ 音乐相关功能时需要

---

### 5. `API_KEY` - API 访问密钥
```env
API_KEY=your_secret_api_key
```
- **作用**: 保护你的 API，只有提供正确密钥才能访问
- **是否必需**: 否（不配置则 API 公开访问）
- **说明**: 
  - 如果配置了，所有 API 请求都需要在 URL 中添加 `?key=your_secret_api_key`
  - 例如: `http://localhost:8787/api?key=your_secret_api_key&url=...`
  - 建议在生产环境配置，防止滥用
- **生成建议**: 使用随机字符串，例如: `openssl rand -hex 32`

---

### 6. `ENABLED_CACHE` - 是否启用缓存
```env
ENABLED_CACHE=true
```
- **作用**: 控制是否使用缓存机制
- **是否必需**: 否（默认值: true）
- **可选值**:
  - `true` - 启用缓存（推荐）
  - `false` - 禁用缓存，每次都从源站获取最新数据
- **说明**: 
  - 启用缓存可以提高响应速度
  - 禁用缓存可以获取最新数据，但可能更慢

---

## 📋 完整配置示例

```env
# 作者名称
AUTHOR=Hares

# TMDB API 密钥（可选）
TMDB_API_KEY=your_tmdb_api_key_here

# 豆瓣 Cookie（强烈建议配置）
DOUBAN_COOKIE='ll="108288"; bid=kuXrYJv8FTc; _vwo_uuid_v2=DDAE89FAEEEF9F46F7692FB02B09D3101|a0f9dd17161826d2aa313b9f28bfc14e; ...'

# QQ 音乐 Cookie（可选）
QQ_COOKIE=''

# API 访问密钥（可选，生产环境建议配置）
API_KEY=your_secret_api_key_here

# 是否启用缓存
ENABLED_CACHE=true
```

---

## 🚀 快速配置

### 最小配置（仅必需项）
```env
AUTHOR=Hares
DOUBAN_COOKIE='your_douban_cookie_here'
ENABLED_CACHE=true
```

### 完整配置（所有功能）
```env
AUTHOR=Hares
TMDB_API_KEY=your_tmdb_api_key
DOUBAN_COOKIE='your_douban_cookie'
QQ_COOKIE='your_qq_cookie'
API_KEY=your_secret_key
ENABLED_CACHE=true
```

---

## ⚠️ 注意事项

1. **Cookie 安全**: Cookie 包含登录信息，请妥善保管，不要泄露
2. **文件位置**: `.env` 文件应该在项目根目录
3. **Git 忽略**: `.env` 文件已在 `.gitignore` 中，不会被提交到 Git
4. **格式要求**: 
   - Cookie 值如果包含特殊字符，需要用单引号包裹
   - 每行一个配置项
   - 等号两边可以有空格，但建议不加

---

## 🔧 如何更新配置

修改 `.env` 文件后：
- **Docker 方式**: 需要重启容器 `docker compose restart`
- **本地方式**: 需要重启服务

