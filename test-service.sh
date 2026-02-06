#!/bin/bash

# 快速测试脚本

echo "=========================================="
echo "测试 PT-Gen 服务"
echo "=========================================="
echo ""

echo "1. 等待服务启动（10秒）..."
sleep 10

echo ""
echo "2. 测试容器内连接"
echo "----------------------------------------"
docker exec pt-gen-refactor curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n" http://localhost:8787/ 2>&1 || echo "❌ 容器内连接失败"

echo ""
echo "3. 测试宿主机连接"
echo "----------------------------------------"
curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n" http://localhost:8787/ 2>&1 || echo "❌ 宿主机连接失败"

echo ""
echo "4. 测试 API 接口"
echo "----------------------------------------"
curl -s -X POST "http://localhost:8787/api?url=https://movie.douban.com/subject/36749573/" | head -20 || echo "❌ API 请求失败"

echo ""
echo "5. 检查端口监听"
echo "----------------------------------------"
docker exec pt-gen-refactor netstat -tlnp 2>/dev/null | grep 8787 || \
docker exec pt-gen-refactor ss -tlnp 2>/dev/null | grep 8787 || \
echo "无法检查（可能需要安装 netstat/ss）"

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="

