# Linux 服务器安装 Node.js 和 npm

## 方法一：使用 NodeSource 仓库（推荐）

### Ubuntu/Debian

```bash
# 更新系统
sudo apt update

# 安装 curl（如果没有）
sudo apt install -y curl

# 添加 NodeSource 仓库（Node.js 20 LTS）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 安装 Node.js 和 npm
sudo apt install -y nodejs

# 验证安装
node --version
npm --version
```

### CentOS/RHEL

```bash
# 更新系统
sudo yum update -y

# 安装 curl（如果没有）
sudo yum install -y curl

# 添加 NodeSource 仓库（Node.js 20 LTS）
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -

# 安装 Node.js 和 npm
sudo yum install -y nodejs

# 验证安装
node --version
npm --version
```

## 方法二：使用 NVM（Node Version Manager，推荐用于开发环境）

```bash
# 安装 NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 重新加载 shell 配置
source ~/.bashrc

# 或者
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装 Node.js 20 LTS
nvm install 20

# 使用 Node.js 20
nvm use 20

# 设置为默认版本
nvm alias default 20

# 验证安装
node --version
npm --version
```

## 方法三：使用包管理器（简单但不一定是最新版本）

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y nodejs npm
```

### CentOS/RHEL

```bash
sudo yum install -y nodejs npm
```

## 验证安装

```bash
# 检查 Node.js 版本（需要 >= 20.19 或 >= 22.12，因为 Vite 7 需要）
node --version

# 检查 npm 版本
npm --version

# 如果版本不够，使用 NVM 安装更新版本
```

## 安装完成后

```bash
# 进入项目目录
cd ~/PT-Gen-Refactor

# 安装依赖
npm install
cd worker && npm install && cd ..
cd frontend && npm install && npm run build && cd ..

# 启动服务
npm run dev
```

