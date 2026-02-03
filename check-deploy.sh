#!/bin/bash
# 部署前检查脚本 - 验证所有必需文件是否存在

echo "🔍 检查部署文件完整性..."
echo ""

ERRORS=0

# 检查必需文件
REQUIRED_FILES=(
    "docker-compose.yml"
    "Dockerfile"
    ".dockerignore"
    "package.json"
    "package-lock.json"
    "wrangler.toml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (缺失)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "检查必需目录..."

# 检查必需目录
REQUIRED_DIRS=(
    "worker"
    "worker/lib"
    "frontend"
    "frontend/src"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/"
    else
        echo "❌ $dir/ (缺失)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "检查关键文件..."

# 检查关键文件
KEY_FILES=(
    "worker/package.json"
    "worker/index.js"
    "frontend/package.json"
    "frontend/vite.config.js"
)

for file in "${KEY_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (缺失)"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ 所有必需文件检查通过！可以部署了。"
    echo ""
    echo "下一步："
    echo "1. 创建 .env 文件: cp .docker-compose.env.example .env"
    echo "2. 编辑 .env 文件，填入配置"
    echo "3. 运行: docker-compose up -d"
    exit 0
else
    echo "❌ 发现 $ERRORS 个缺失的文件/目录，请先补全后再部署。"
    exit 1
fi

