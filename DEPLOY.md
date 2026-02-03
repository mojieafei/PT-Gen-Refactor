# 跨机器部署指南

## 📦 需要复制的文件

将以下文件/目录复制到目标机器：

### 必需文件
```
├── docker-compose.yml          # Docker Compose 配置
├── Dockerfile                  # Docker 镜像构建文件
├── .dockerignore              # Docker 构建忽略文件
├── package.json               # 根目录依赖
├── package-lock.json          # 锁定版本
├── wrangler.toml              # Worker 配置
│
├── worker/                    # Worker 目录（整个目录）
│   ├── package.json
│   ├── package-lock.json
│   ├── index.js
│   ├── rollup.config.js
│   └── lib/                   # 所有 lib 文件
│
└── frontend/                  # 前端目录（整个目录）
    ├── package.json
    ├── package-lock.json
    ├── vite.config.js
    ├── tailwind.config.js
    ├── postcss.config.js
    └── src/                   # 所有源码文件
```

### 可选文件
```
├── .docker-compose.env.example  # 环境变量示例
├── .env                        # 环境变量（如果已有配置）
└── README.md                   # 说明文档
```

## 🚀 快速部署步骤

### 1. 复制文件到目标机器

```bash
# 方式1: 使用 scp (Linux/Mac)
scp -r . user@target-machine:/path/to/pt-gen-refactor/

# 方式2: 使用 rsync (推荐，支持断点续传)
rsync -avz --exclude 'node_modules' --exclude '.git' \
  ./ user@target-machine:/path/to/pt-gen-refactor/

# 方式3: 打包传输
tar -czf pt-gen-refactor.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='dist' \
  .
# 然后传输 tar.gz 文件到目标机器并解压
```

### 2. 在目标机器上配置

```bash
# 进入项目目录
cd /path/to/pt-gen-refactor

# 创建 .env 文件（如果还没有）
cp .docker-compose.env.example .env

# 编辑 .env 文件，填入你的配置
nano .env  # 或 vi .env
```

### 3. 启动服务

```bash
# 确保 Docker 和 Docker Compose 已安装
docker --version
docker-compose --version

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 检查服务状态
docker-compose ps
```

## ✅ 验证部署

```bash
# 检查容器是否运行
docker ps | grep pt-gen

# 测试 API
curl http://localhost:8787/api?url=https://movie.douban.com/subject/36749573/

# 或在浏览器访问
# http://localhost:8787
```

## 🔧 常见问题

### 1. 端口被占用

如果 8787 端口被占用，修改 `docker-compose.yml`：

```yaml
ports:
  - "8788:8787"  # 改为其他端口
```

### 2. .env 文件不存在

`.env` 文件是可选的，如果不存在会使用默认值。但建议创建并配置：

```bash
cp .docker-compose.env.example .env
# 然后编辑 .env 填入实际配置
```

### 3. 构建失败

```bash
# 清理并重新构建
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 4. 权限问题（Linux）

```bash
# 确保当前用户有 Docker 权限
sudo usermod -aG docker $USER
# 然后重新登录
```

## 📝 环境变量说明

在 `.env` 文件中配置：

```env
AUTHOR=Hares                    # 作者名称
TMDB_API_KEY=your_key_here      # TMDB API 密钥（可选）
DOUBAN_COOKIE=your_cookie       # 豆瓣 Cookie（重要！）
QQ_COOKIE=your_cookie           # QQ 音乐 Cookie（可选）
API_KEY=your_api_key            # API 访问密钥（可选）
ENABLED_CACHE=true              # 是否启用缓存
```

## 🔄 更新部署

```bash
# 1. 停止服务
docker-compose down

# 2. 更新代码文件

# 3. 重新构建并启动
docker-compose build --no-cache
docker-compose up -d
```

## 📊 监控和维护

```bash
# 查看日志
docker-compose logs -f pt-gen

# 查看资源使用
docker stats pt-gen-refactor

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 完全清理（包括数据）
docker-compose down -v
```

