#!/bin/bash

# Docker 容器诊断脚本

echo "=========================================="
echo "PT-Gen-Refactor Docker 诊断脚本"
echo "=========================================="
echo ""

CONTAINER_NAME="pt-gen-refactor"

# 检查容器是否存在
if ! docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "❌ 容器 $CONTAINER_NAME 不存在"
    exit 1
fi

echo "1. 检查容器状态"
echo "----------------------------------------"
docker ps -a | grep "$CONTAINER_NAME"
echo ""

echo "2. 检查容器健康状态"
echo "----------------------------------------"
docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "未配置健康检查"
echo ""

echo "3. 检查端口映射"
echo "----------------------------------------"
docker port "$CONTAINER_NAME"
echo ""

echo "4. 检查最近 50 行日志"
echo "----------------------------------------"
docker logs --tail=50 "$CONTAINER_NAME"
echo ""

echo "5. 检查容器内端口监听"
echo "----------------------------------------"
docker exec "$CONTAINER_NAME" netstat -tlnp 2>/dev/null | grep 8787 || \
docker exec "$CONTAINER_NAME" ss -tlnp 2>/dev/null | grep 8787 || \
echo "无法检查端口监听（可能需要安装 netstat/ss）"
echo ""

echo "6. 检查容器内进程"
echo "----------------------------------------"
docker exec "$CONTAINER_NAME" ps aux | grep -E "(wrangler|node)" | head -5
echo ""

echo "7. 测试容器内连接"
echo "----------------------------------------"
echo "测试 localhost:8787"
docker exec "$CONTAINER_NAME" curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n" http://localhost:8787/ 2>&1 || echo "连接失败"
echo ""

echo "8. 测试宿主机连接"
echo "----------------------------------------"
echo "测试 localhost:8787"
curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n" http://localhost:8787/ 2>&1 || echo "连接失败"
echo ""

echo "9. 检查网络配置"
echo "----------------------------------------"
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME"
echo ""

echo "10. 检查环境变量"
echo "----------------------------------------"
docker exec "$CONTAINER_NAME" env | grep -E "(AUTHOR|TMDB|DOUBAN|WRANGLER)" | head -10
echo ""

echo "=========================================="
echo "诊断完成"
echo "=========================================="
echo ""
echo "如果发现问题，请："
echo "1. 查看完整日志: docker logs -f $CONTAINER_NAME"
echo "2. 进入容器调试: docker exec -it $CONTAINER_NAME bash"
echo "3. 重启容器: docker compose restart"
echo "4. 重新构建: docker compose down && docker compose build --no-cache && docker compose up -d"

