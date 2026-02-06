# 修复 Ubuntu 软件源 404 错误

## 问题
安装包时遇到 404 错误，说明软件源中的某些包版本不存在或已更新。

## 解决方案

### 方法一：更新软件源并重试

```bash
# 1. 更新软件源列表
sudo apt update

# 2. 清理缓存
sudo apt clean

# 3. 重新尝试安装
sudo apt install -f  # 修复依赖
sudo apt upgrade     # 更新系统
```

### 方法二：更换软件源镜像（如果方法一不行）

```bash
# 1. 备份原始源列表
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 2. 编辑源列表
sudo nano /etc/apt/sources.list
```

对于 Ubuntu 24.04 (Noble)，使用阿里云镜像：

```bash
# 替换为阿里云镜像
sudo sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://mirrors.aliyun.com/ubuntu-ports|g' /etc/apt/sources.list

# 或使用清华镜像
sudo sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports|g' /etc/apt/sources.list
```

然后：

```bash
# 3. 更新软件源
sudo apt update

# 4. 重新尝试安装
```

### 方法三：使用 --fix-missing 参数

```bash
sudo apt update
sudo apt install --fix-missing <package-name>
```

## 针对当前错误

```bash
# 1. 更新软件源
sudo apt update

# 2. 尝试修复
sudo apt install --fix-missing binutils

# 3. 如果还不行，清理并重新安装
sudo apt clean
sudo apt update
sudo apt upgrade
```

