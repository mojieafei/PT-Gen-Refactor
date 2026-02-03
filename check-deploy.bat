@echo off
REM 部署前检查脚本 - 验证所有必需文件是否存在 (Windows)

echo 🔍 检查部署文件完整性...
echo.

set ERRORS=0

REM 检查必需文件
if exist docker-compose.yml (echo ✅ docker-compose.yml) else (echo ❌ docker-compose.yml (缺失) & set /a ERRORS+=1)
if exist Dockerfile (echo ✅ Dockerfile) else (echo ❌ Dockerfile (缺失) & set /a ERRORS+=1)
if exist .dockerignore (echo ✅ .dockerignore) else (echo ❌ .dockerignore (缺失) & set /a ERRORS+=1)
if exist package.json (echo ✅ package.json) else (echo ❌ package.json (缺失) & set /a ERRORS+=1)
if exist package-lock.json (echo ✅ package-lock.json) else (echo ❌ package-lock.json (缺失) & set /a ERRORS+=1)
if exist wrangler.toml (echo ✅ wrangler.toml) else (echo ❌ wrangler.toml (缺失) & set /a ERRORS+=1)

echo.
echo 检查必需目录...

if exist worker\ (echo ✅ worker\) else (echo ❌ worker\ (缺失) & set /a ERRORS+=1)
if exist worker\lib\ (echo ✅ worker\lib\) else (echo ❌ worker\lib\ (缺失) & set /a ERRORS+=1)
if exist frontend\ (echo ✅ frontend\) else (echo ❌ frontend\ (缺失) & set /a ERRORS+=1)
if exist frontend\src\ (echo ✅ frontend\src\) else (echo ❌ frontend\src\ (缺失) & set /a ERRORS+=1)

echo.
echo 检查关键文件...

if exist worker\package.json (echo ✅ worker\package.json) else (echo ❌ worker\package.json (缺失) & set /a ERRORS+=1)
if exist worker\index.js (echo ✅ worker\index.js) else (echo ❌ worker\index.js (缺失) & set /a ERRORS+=1)
if exist frontend\package.json (echo ✅ frontend\package.json) else (echo ❌ frontend\package.json (缺失) & set /a ERRORS+=1)
if exist frontend\vite.config.js (echo ✅ frontend\vite.config.js) else (echo ❌ frontend\vite.config.js (缺失) & set /a ERRORS+=1)

echo.
if %ERRORS%==0 (
    echo ✅ 所有必需文件检查通过！可以部署了。
    echo.
    echo 下一步：
    echo 1. 创建 .env 文件: copy .docker-compose.env.example .env
    echo 2. 编辑 .env 文件，填入配置
    echo 3. 运行: docker-compose up -d
    exit /b 0
) else (
    echo ❌ 发现 %ERRORS% 个缺失的文件/目录，请先补全后再部署。
    exit /b 1
)

