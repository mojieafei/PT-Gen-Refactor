#!/bin/bash
# 修复 wrangler 绑定地址问题

echo "=== 检查 wrangler 版本 ==="
cd ~/PT-Gen-Refactor/worker
npx wrangler --version

echo ""
echo "=== 检查 --host 参数支持 ==="
npx wrangler dev --help 2>&1 | grep -i host || echo "未找到 --host 参数"

echo ""
echo "=== 尝试其他方法 ==="
echo "方法1: 使用 --ip 参数"
echo "方法2: 使用环境变量"
echo "方法3: 使用 Nginx 反向代理"

