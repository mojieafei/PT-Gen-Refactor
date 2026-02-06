# Docker 容器故障排除指南

## 问题：容器状态为 unhealthy，curl 连接被重置

### 症状
- 容器状态显示 `unhealthy`
- `curl localhost:8787` 返回 "Connection reset by peer"
- 日志显示服务已启动在 `http://localhost:8787`

### 可能的原因

1. **wrangler dev 监听地址问题**：虽然使用了 `--host 0.0.0.0`，但可能在某些版本中仍有问题
2. **健康检查过于严格**：启动时间不够
3. **端口绑定问题**：服务可能没有正确绑定到 0.0.0.0

### 解决方案

#### 方案 1：检查容器内服务状态（推荐先执行）

```bash
# 进入容器检查
docker exec -it pt-gen-refactor bash

# 在容器内检查端口监听
netstat -tlnp | grep 8787
# 或
ss -tlnp | grep 8787

# 在容器内测试
curl localhost:8787
curl 127.0.0.1:8787
curl 0.0.0.0:8787

# 检查进程
ps aux | grep wrangler

# 退出容器
exit
```

#### 方案 2：更新配置并重启

```bash
# 1. 停止当前容器
docker compose down

# 2. 重新构建（如果修改了 Dockerfile 或 package.json）
docker compose build --no-cache

# 3. 启动服务
docker compose up -d

# 4. 查看详细日志
docker compose logs -f
```

#### 方案 3：修改启动命令（如果方案 2 不行）

如果问题仍然存在，可能需要修改 `package.json` 中的启动命令。已经更新为：

```json
"dev": "cd worker && npx wrangler dev --host 0.0.0.0 --port 8787"
```

然后重新构建：

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

#### 方案 4：使用环境变量配置 wrangler

创建或修改 `.env` 文件，添加：

```env
WRANGLER_HOST=0.0.0.0
WRANGLER_PORT=8787
```

然后修改 `docker-compose.yml` 添加这些环境变量。

#### 方案 5：检查 wrangler 版本

```bash
# 进入容器
docker exec -it pt-gen-refactor bash

# 检查 wrangler 版本
cd worker
npx wrangler --version

# 如果需要更新
npm install wrangler@latest

# 退出并重启
exit
docker compose restart
```

#### 方案 6：临时禁用健康检查（用于调试）

修改 `docker-compose.yml`，临时注释掉健康检查：

```yaml
# healthcheck:
#   test: ["CMD", "node", "-e", "require('http').get('http://localhost:8787/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))"]
#   interval: 30s
#   timeout: 10s
#   retries: 3
#   start_period: 30s
```

然后重启：

```bash
docker compose down
docker compose up -d
```

### 诊断命令

```bash
# 1. 检查容器状态
docker ps -a

# 2. 查看容器日志
docker logs pt-gen-refactor
docker logs -f pt-gen-refactor  # 实时日志

# 3. 检查端口映射
docker port pt-gen-refactor

# 4. 检查容器网络
docker inspect pt-gen-refactor | grep -A 20 "NetworkSettings"

# 5. 从宿主机测试
curl -v http://localhost:8787
curl -v http://127.0.0.1:8787

# 6. 检查防火墙
sudo ufw status
sudo iptables -L -n | grep 8787

# 7. 检查是否有其他服务占用端口
sudo netstat -tlnp | grep 8787
sudo ss -tlnp | grep 8787
```

### 验证修复

修复后，执行以下命令验证：

```bash
# 1. 检查容器状态（应该是 healthy）
docker ps

# 2. 测试 API
curl http://localhost:8787/
curl http://localhost:8787/api?url=https://movie.douban.com/subject/36749573/

# 3. 在浏览器访问
# http://你的服务器IP:8787
```

### 如果仍然无法解决

1. **查看完整日志**：
   ```bash
   docker compose logs --tail=100 pt-gen
   ```

2. **检查 wrangler.toml 配置**：
   确保 `wrangler.toml` 文件正确挂载且配置无误

3. **尝试直接运行 wrangler**：
   ```bash
   docker exec -it pt-gen-refactor bash
   cd /app/worker
   npx wrangler dev --host 0.0.0.0 --port 8787
   ```

4. **检查系统资源**：
   ```bash
   docker stats pt-gen-refactor
   ```

5. **查看 wrangler 官方文档**：
   检查是否有已知问题或更新

### 常见错误信息

- **"Connection reset by peer"**: 服务可能没有正确监听或端口被拒绝
- **"unhealthy"**: 健康检查失败，可能是启动时间不够或服务未正确响应
- **"Ready on http://localhost:8787"**: 日志显示正常，但实际可能只监听 localhost 而不是 0.0.0.0

### 联系支持

如果以上方案都无法解决问题，请提供：
1. `docker compose logs` 的完整输出
2. `docker exec -it pt-gen-refactor netstat -tlnp` 的输出
3. `docker inspect pt-gen-refactor` 的输出
4. wrangler 版本信息

