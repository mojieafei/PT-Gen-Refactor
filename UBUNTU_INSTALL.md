# Ubuntu 服务器安装和启动指南

## 前提条件

- Ubuntu 系统（已通过 git clone 获取代码）
- 具有 sudo 权限的用户

## 方式一：使用 Docker（推荐，最简单）

### 1. 安装 Docker 和 Docker Compose

```bash
# 更新系统包
sudo apt update

# 安装必要的依赖
sudo apt install -y ca-certificates curl gnupg lsb-release

# 添加 Docker 官方 GPG 密钥
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 添加 Docker 仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker Engine 和 Docker Compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 将当前用户添加到 docker 组（避免每次使用 sudo）
sudo usermod -aG docker $USER

# 重新登录或执行以下命令使组权限生效
newgrp docker

# 验证安装
docker --version
docker compose version
```

### 2. 配置环境变量（可选）

```bash
# 进入项目目录
cd PT-Gen-Refactor

# 如果有 .docker-compose.env.example，复制它
# 如果没有，可以直接创建 .env 文件
cat > .env << 'EOF'
AUTHOR=Hares
TMDB_API_KEY=
DOUBAN_COOKIE=
QQ_COOKIE=
API_KEY=
ENABLED_CACHE=true
EOF

# 编辑 .env 文件，填入你的配置（特别是 DOUBAN_COOKIE）
nano .env
# 或使用 vi
# vi .env
```

### 3. 启动服务

```bash
# 在项目根目录下执行
docker compose up -d

# 查看日志
docker compose logs -f

# 检查服务状态
docker compose ps
```

### 4. 访问服务

服务启动后，访问：
- 前端界面: http://你的服务器IP:8787
- API 接口: http://你的服务器IP:8787/api

### 5. 常用命令

```bash
# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f

# 更新代码后重新构建
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## 方式二：直接使用 Node.js（不使用 Docker）

### 1. 安装 Node.js

```bash
# 更新系统
sudo apt update

# 安装 curl（如果没有）
sudo apt install -y curl

# 添加 NodeSource 仓库（Node.js 20 LTS）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 安装 Node.js 和 npm
sudo apt install -y nodejs

# 验证安装（需要 >= 20.19 或 >= 22.12，因为 Vite 7 需要）
node --version
npm --version
```

如果版本不够，可以使用 NVM：

```bash
# 安装 NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 重新加载 shell 配置
source ~/.bashrc

# 安装 Node.js 20 LTS
nvm install 20
nvm use 20
nvm alias default 20

# 验证安装
node --version
npm --version
```

### 2. 安装项目依赖

```bash
# 进入项目目录
cd PT-Gen-Refactor

# 安装根目录依赖
npm install

# 安装 Worker 依赖
cd worker
npm install
cd ..

# 安装前端依赖并构建
cd frontend
npm install
npm run build
cd ..
```

### 3. 配置环境变量

编辑 `wrangler.toml` 文件，配置必要的环境变量：

```bash
nano wrangler.toml
# 或使用 vi
# vi wrangler.toml
```

在 `[vars]` 部分配置：
- `AUTHOR`: 作者名称
- `TMDB_API_KEY`: TMDB API 密钥（可选）
- `DOUBAN_COOKIE`: 豆瓣 Cookie（重要！）
- `QQ_COOKIE`: QQ 音乐 Cookie（可选）
- `API_KEY`: API 访问密钥（可选）
- `ENABLED_CACHE`: 是否启用缓存（默认: true）

### 4. 启动服务

```bash
# 在项目根目录下执行
npm run dev
```

服务将运行在 `http://localhost:8787`

### 5. 后台运行（使用 PM2，推荐）

```bash
# 安装 PM2
sudo npm install -g pm2

# 创建启动脚本
cat > start.sh << 'EOF'
#!/bin/bash
cd /path/to/PT-Gen-Refactor
npm run dev
EOF

chmod +x start.sh

# 使用 PM2 启动
pm2 start start.sh --name pt-gen

# 查看状态
pm2 status

# 查看日志
pm2 logs pt-gen

# 设置开机自启
pm2 startup
pm2 save
```

### 6. 配置防火墙（如果需要）

```bash
# 如果使用 UFW
sudo ufw allow 8787/tcp
sudo ufw reload

# 如果使用 firewalld
sudo firewall-cmd --permanent --add-port=8787/tcp
sudo firewall-cmd --reload
```

---

## 验证安装

### 测试 API

```bash
# 测试豆瓣 API
curl -X POST "http://localhost:8787/api?url=https://movie.douban.com/subject/36749573/"

# 或在浏览器访问
# http://你的服务器IP:8787
```

### 检查服务状态

```bash
# Docker 方式
docker compose ps
docker compose logs -f

# Node.js 方式（使用 PM2）
pm2 status
pm2 logs pt-gen

# Node.js 方式（直接运行）
# 查看终端输出
```

---

## 常见问题

### 1. 端口被占用

如果 8787 端口被占用，可以修改：

**Docker 方式**: 修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - "8788:8787"  # 改为其他端口
```

**Node.js 方式**: 修改 `wrangler.toml` 或使用环境变量指定端口。

### 2. 权限问题

```bash
# 确保当前用户有 Docker 权限
sudo usermod -aG docker $USER
# 然后重新登录或执行 newgrp docker
```

### 3. Node.js 版本不够

使用 NVM 安装更新的版本（见方式二的步骤 1）。

### 4. 构建失败

```bash
# 清理并重新安装依赖
rm -rf node_modules package-lock.json
rm -rf worker/node_modules worker/package-lock.json
rm -rf frontend/node_modules frontend/package-lock.json
npm install
cd worker && npm install && cd ..
cd frontend && npm install && npm run build && cd ..
```

### 5. 豆瓣 Cookie 配置

豆瓣 Cookie 很重要，如果不配置可能无法获取信息。获取方法：
1. 登录豆瓣网站
2. 打开浏览器开发者工具（F12）
3. 在 Network 标签中找到任意请求
4. 复制请求头中的 Cookie 值
5. 粘贴到 `wrangler.toml` 的 `DOUBAN_COOKIE` 配置中

---

## 推荐方式

- **生产环境**: 推荐使用 Docker 方式，更稳定、易于管理
- **开发环境**: 可以使用 Node.js 直接运行，便于调试

---

## 下一步

安装完成后，你可以：
1. 访问前端界面进行测试
2. 配置反向代理（Nginx/Caddy）以使用域名访问
3. 配置 SSL 证书（Let's Encrypt）启用 HTTPS
4. 设置监控和日志收集

