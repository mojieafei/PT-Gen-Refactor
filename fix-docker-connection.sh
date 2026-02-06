#!/bin/bash

# 修复 Docker 连接问题的脚本

echo "=========================================="
echo "诊断和修复 Docker 连接问题"
echo "=========================================="
echo ""

CONTAINER_NAME="pt-gen-refactor"

echo "1. 检查容器内端口监听情况"
echo "----------------------------------------"
echo "尝试使用 netstat:"
docker exec $CONTAINER_NAME netstat -tlnp 2>&1 | grep 8787 || echo "netstat 不可用"

echo ""
echo "尝试使用 ss:"
docker exec $CONTAINER_NAME ss -tlnp 2>&1 | grep 8787 || echo "ss 不可用"

echo ""
echo "尝试使用 lsof:"
docker exec $CONTAINER_NAME lsof -i :8787 2>&1 || echo "lsof 不可用"

echo ""
echo "2. 检查容器内进程"
echo "----------------------------------------"
docker exec $CONTAINER_NAME ps aux | grep -E "(wrangler|node|workerd)" | head -10

echo ""
echo "3. 在容器内测试连接"
echo "----------------------------------------"
echo "测试 localhost:"
docker exec $CONTAINER_NAME curl -v http://localhost:8787/ 2>&1 | head -20 || echo "连接失败"

echo ""
echo "测试 127.0.0.1:"
docker exec $CONTAINER_NAME curl -v http://127.0.0.1:8787/ 2>&1 | head -20 || echo "连接失败"

echo ""
echo "4. 检查 wrangler 配置"
echo "----------------------------------------"
docker exec $CONTAINER_NAME cat /app/wrangler.toml | head -20

echo ""
echo "=========================================="
echo "诊断完成"
echo "=========================================="

