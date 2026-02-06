#!/bin/bash

# PT-Gen-Refactor Ubuntu 安装脚本
# 使用方法: bash ubuntu-install.sh

set -e

echo "=========================================="
echo "PT-Gen-Refactor Ubuntu 安装脚本"
echo "=========================================="
echo ""

# 检查是否为 root 用户
if [ "$EUID" -eq 0 ]; then 
   echo "请不要使用 root 用户运行此脚本"
   exit 1
fi

# 选择安装方式
echo "请选择安装方式:"
echo "1) Docker 方式（推荐）"
echo "2) Node.js 直接安装"
read -p "请输入选项 (1 或 2): " install_method

if [ "$install_method" != "1" ] && [ "$install_method" != "2" ]; then
    echo "无效选项，退出"
    exit 1
fi

# 方式一：Docker 安装
if [ "$install_method" = "1" ]; then
    echo ""
    echo "开始 Docker 方式安装..."
    
    # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null; then
        echo "Docker 未安装，开始安装 Docker..."
        
        # 更新系统
        sudo apt update
        
        # 安装必要依赖
        sudo apt install -y ca-certificates curl gnupg lsb-release
        
        # 添加 Docker 官方 GPG 密钥
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        
        # 添加 Docker 仓库
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # 安装 Docker
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # 将当前用户添加到 docker 组
        sudo usermod -aG docker $USER
        
        echo ""
        echo "Docker 安装完成！"
        echo "注意: 需要重新登录或执行 'newgrp docker' 才能使 docker 组权限生效"
        echo ""
        read -p "是否现在执行 'newgrp docker'? (y/n): " exec_newgrp
        if [ "$exec_newgrp" = "y" ]; then
            newgrp docker
        fi
    else
        echo "Docker 已安装"
        docker --version
    fi
    
    # 检查 Docker Compose
    if ! docker compose version &> /dev/null; then
        echo "Docker Compose 未安装，正在安装..."
        sudo apt install -y docker-compose-plugin
    fi
    
    # 创建 .env 文件（如果不存在）
    if [ ! -f .env ]; then
        echo ""
        echo "创建 .env 文件..."
        cat > .env << 'EOF'
AUTHOR=Hares
TMDB_API_KEY=
DOUBAN_COOKIE=
QQ_COOKIE=
API_KEY=
ENABLED_CACHE=true
EOF
        echo ".env 文件已创建，请编辑它并填入你的配置（特别是 DOUBAN_COOKIE）"
        read -p "按 Enter 继续..."
    fi
    
    # 启动服务
    echo ""
    echo "启动 Docker 服务..."
    docker compose up -d
    
    echo ""
    echo "=========================================="
    echo "安装完成！"
    echo "=========================================="
    echo "服务地址: http://localhost:8787"
    echo ""
    echo "常用命令:"
    echo "  查看日志: docker compose logs -f"
    echo "  停止服务: docker compose down"
    echo "  重启服务: docker compose restart"
    echo "=========================================="
fi

# 方式二：Node.js 安装
if [ "$install_method" = "2" ]; then
    echo ""
    echo "开始 Node.js 方式安装..."
    
    # 检查 Node.js 是否已安装
    if ! command -v node &> /dev/null; then
        echo "Node.js 未安装，开始安装 Node.js 20..."
        
        # 更新系统
        sudo apt update
        sudo apt install -y curl
        
        # 添加 NodeSource 仓库
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        
        # 安装 Node.js
        sudo apt install -y nodejs
        
        echo "Node.js 安装完成"
    else
        echo "Node.js 已安装"
        node --version
        npm --version
        
        # 检查版本
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -lt 20 ]; then
            echo "警告: Node.js 版本低于 20，建议升级到 20 或更高版本"
            read -p "是否使用 NVM 安装 Node.js 20? (y/n): " install_nvm
            if [ "$install_nvm" = "y" ]; then
                # 安装 NVM
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                nvm install 20
                nvm use 20
                nvm alias default 20
            fi
        fi
    fi
    
    # 安装项目依赖
    echo ""
    echo "安装项目依赖..."
    
    # 根目录依赖
    echo "安装根目录依赖..."
    npm install
    
    # Worker 依赖
    echo "安装 Worker 依赖..."
    cd worker
    npm install
    cd ..
    
    # 前端依赖和构建
    echo "安装前端依赖并构建..."
    cd frontend
    npm install
    npm run build
    cd ..
    
    # 检查 wrangler.toml 配置
    echo ""
    echo "请确保已配置 wrangler.toml 文件中的环境变量"
    echo "特别是 DOUBAN_COOKIE 配置"
    read -p "按 Enter 继续..."
    
    # 询问是否安装 PM2
    read -p "是否安装 PM2 用于后台运行? (y/n): " install_pm2
    if [ "$install_pm2" = "y" ]; then
        sudo npm install -g pm2
        
        # 创建 PM2 启动脚本
        cat > pm2-start.sh << 'PM2EOF'
#!/bin/bash
cd "$(dirname "$0")"
npm run dev
PM2EOF
        chmod +x pm2-start.sh
        
        echo ""
        echo "使用 PM2 启动服务..."
        pm2 start pm2-start.sh --name pt-gen
        
        echo ""
        echo "=========================================="
        echo "安装完成！"
        echo "=========================================="
        echo "服务已使用 PM2 启动"
        echo "服务地址: http://localhost:8787"
        echo ""
        echo "常用命令:"
        echo "  查看状态: pm2 status"
        echo "  查看日志: pm2 logs pt-gen"
        echo "  停止服务: pm2 stop pt-gen"
        echo "  重启服务: pm2 restart pt-gen"
        echo "  设置开机自启: pm2 startup && pm2 save"
        echo "=========================================="
    else
        echo ""
        echo "=========================================="
        echo "依赖安装完成！"
        echo "=========================================="
        echo "使用以下命令启动服务:"
        echo "  npm run dev"
        echo ""
        echo "服务将运行在: http://localhost:8787"
        echo "=========================================="
    fi
fi

echo ""
echo "安装脚本执行完成！"

