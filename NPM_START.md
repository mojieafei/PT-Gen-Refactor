# 使用 npm 直接启动服务

## 快速启动步骤

### 1. 确保已安装 Node.js

```bash
# 检查 Node.js 版本（需要 >= 20.19 或 >= 22.12）
node --version
npm --version
```

如果未安装或版本不够，参考 `INSTALL_NODE.md` 安装。

### 2. 安装依赖

```bash
# 进入项目目录
cd PT-Gen-Refactor

# 安装根目录依赖
npm install

# 安装 Worker 依赖
cd worker
npm install
cd ..

# 安装前端依赖并构建（如果需要前端界面）
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

服务将运行在 `http://localhost:8787` 或 `http://0.0.0.0:8787`

### 5. 访问服务

- 前端界面: http://你的服务器IP:8787
- API 接口: http://你的服务器IP:8787/api

## 后台运行（推荐使用 PM2）

### 安装 PM2

```bash
sudo npm install -g pm2
```

### 使用 PM2 启动

```bash
# 在项目根目录下
pm2 start npm --name "pt-gen" -- run dev

# 查看状态
pm2 status

# 查看日志
pm2 logs pt-gen

# 停止服务
pm2 stop pt-gen

# 重启服务
pm2 restart pt-gen

# 设置开机自启
pm2 startup
pm2 save
```

## 或者使用 nohup（简单方式）

```bash
# 后台运行
nohup npm run dev > pt-gen.log 2>&1 &

# 查看日志
tail -f pt-gen.log

# 停止服务（需要找到进程ID）
ps aux | grep "npm run dev"
kill <进程ID>
```

## 测试服务

```bash
# 测试前端
curl http://localhost:8787/

# 测试 API
curl -X POST "http://localhost:8787/api?url=https://movie.douban.com/subject/36749573/"
```

## 常见问题

### 1. 端口被占用

如果 8787 端口被占用，可以修改 `package.json` 中的端口：

```json
"dev": "cd worker && npx wrangler dev --host 0.0.0.0 --port 8788"
```

### 2. 无法外网访问

确保防火墙开放端口：

```bash
# UFW
sudo ufw allow 8787/tcp

# firewalld
sudo firewall-cmd --permanent --add-port=8787/tcp
sudo firewall-cmd --reload
```

### 3. 服务启动失败

检查依赖是否完整安装：

```bash
# 重新安装依赖
rm -rf node_modules package-lock.json
rm -rf worker/node_modules worker/package-lock.json
npm install
cd worker && npm install && cd ..
```

