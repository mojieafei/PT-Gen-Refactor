#!/bin/bash
# 检查服务状态和网络配置

echo "=== 检查服务监听端口 ==="
netstat -tlnp | grep 8787 || ss -tlnp | grep 8787

echo ""
echo "=== 检查防火墙状态 ==="
# Ubuntu/Debian
if command -v ufw &> /dev/null; then
    echo "UFW 状态:"
    sudo ufw status
fi

# CentOS/RHEL
if command -v firewall-cmd &> /dev/null; then
    echo "Firewalld 状态:"
    sudo firewall-cmd --list-ports
fi

echo ""
echo "=== 检查 wrangler 版本 ==="
cd worker && npx wrangler --version

echo ""
echo "=== 测试本地连接 ==="
curl -s http://localhost:8787/ | head -n 5

echo ""
echo "=== 测试外部连接 ==="
curl -s http://192.168.2.13:8787/ | head -n 5 || echo "外部连接失败"

