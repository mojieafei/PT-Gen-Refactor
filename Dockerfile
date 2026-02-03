# 使用 Node.js 20 作为基础镜像（Vite 7 需要 Node.js 20.19+）
FROM node:20-alpine

# 安装必要的系统依赖
RUN apk add --no-cache git

# 设置工作目录
WORKDIR /app

# 复制 package 文件（利用 Docker 缓存层）
COPY package*.json ./
COPY worker/package*.json ./worker/
COPY frontend/package*.json ./frontend/

# 安装根目录依赖（包含 devDependencies，因为需要 wrangler）
# 使用 npm install 而不是 npm ci，更兼容
RUN npm install --ignore-scripts

# 安装 worker 依赖
WORKDIR /app/worker
RUN npm install --ignore-scripts

# 安装前端依赖
WORKDIR /app/frontend
RUN npm install --ignore-scripts

# 复制前端源码文件（构建需要）
COPY frontend/index.html ./frontend/
COPY frontend/src ./frontend/src/
COPY frontend/vite.config.js ./frontend/
COPY frontend/tailwind.config.js ./frontend/
COPY frontend/postcss.config.js ./frontend/

# 构建前端
WORKDIR /app/frontend
RUN npm run build

# 返回根目录
WORKDIR /app

# 复制剩余项目文件
COPY . .

# 暴露端口（wrangler dev 默认使用 8787）
EXPOSE 8787

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8787/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 启动开发服务器
CMD ["npm", "run", "dev"]

