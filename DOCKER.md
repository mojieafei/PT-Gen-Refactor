# Docker 部署指南

## 快速开始

### 1. 使用 Docker Compose（推荐）

```bash
# 复制环境变量文件
cp .docker-compose.env.example .env

# 编辑 .env 文件，填入你的配置
# 特别是 DOUBAN_COOKIE 等敏感信息

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 2. 使用 Docker 直接运行

```bash
# 构建镜像
docker build -t pt-gen-refactor .

# 运行容器
docker run -d \
  --name pt-gen-refactor \
  -p 8787:8787 \
  -e AUTHOR="Hares" \
  -e DOUBAN_COOKIE="your_cookie_here" \
  pt-gen-refactor

# 查看日志
docker logs -f pt-gen-refactor
```

## 环境变量

可以通过环境变量或 `.env` 文件配置：

- `AUTHOR`: 作者名称（默认: Hares）
- `TMDB_API_KEY`: TMDB API 密钥
- `DOUBAN_COOKIE`: 豆瓣 Cookie（重要！）
- `QQ_COOKIE`: QQ 音乐 Cookie
- `API_KEY`: API 访问密钥
- `ENABLED_CACHE`: 是否启用缓存（默认: true）

## 端口

- 8787: Worker 开发服务器端口

## 注意事项

1. **Cookie 安全**: 不要将包含 Cookie 的 `.env` 文件提交到 Git
2. **开发模式**: 当前配置为开发模式，生产环境建议使用 Cloudflare Workers 部署
3. **热更新**: 如果使用 volumes 挂载，代码修改会自动生效（需要重启容器）

## 生产部署

对于生产环境，建议：
1. 使用 Cloudflare Workers 平台部署（`npm run deploy`）
2. 或者构建生产镜像并配置反向代理（Nginx/Caddy）

