#!/bin/bash
# Docker 快速启动脚本

echo "🚀 PT-Gen Refactor Docker 启动脚本"
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "⚠️  未找到 .env 文件"
    echo "📝 正在从示例文件创建 .env..."
    cp .docker-compose.env.example .env
    echo "✅ 已创建 .env 文件，请编辑后填入你的配置"
    echo ""
    read -p "按 Enter 继续启动，或 Ctrl+C 退出编辑 .env 文件..."
fi

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 构建并启动
echo "🔨 构建 Docker 镜像..."
docker-compose build

echo ""
echo "🚀 启动容器..."
docker-compose up -d

echo ""
echo "✅ 服务已启动！"
echo "📊 查看日志: docker-compose logs -f"
echo "🌐 访问地址: http://localhost:8787"
echo "🛑 停止服务: docker-compose down"

