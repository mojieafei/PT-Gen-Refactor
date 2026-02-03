@echo off
REM Docker 快速启动脚本 (Windows)

echo 🚀 PT-Gen Refactor Docker 启动脚本
echo.

REM 检查 .env 文件
if not exist .env (
    echo ⚠️  未找到 .env 文件
    echo 📝 正在从示例文件创建 .env...
    copy .docker-compose.env.example .env
    echo ✅ 已创建 .env 文件，请编辑后填入你的配置
    echo.
    pause
)

REM 检查 Docker 是否运行
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker 未运行，请先启动 Docker Desktop
    pause
    exit /b 1
)

REM 构建并启动
echo 🔨 构建 Docker 镜像...
docker-compose build

echo.
echo 🚀 启动容器...
docker-compose up -d

echo.
echo ✅ 服务已启动！
echo 📊 查看日志: docker-compose logs -f
echo 🌐 访问地址: http://localhost:8787
echo 🛑 停止服务: docker-compose down
echo.
pause

