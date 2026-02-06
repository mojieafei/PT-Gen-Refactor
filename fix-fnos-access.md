# FNOS 系统恢复访问指南

## FNOS 使用的代理方式

FNOS 通常使用：
- **Caddy** - 轻量级 Web 服务器
- **Traefik** - 反向代理
- **自带的 Web 服务器** - 基于 Go 或其他技术

## 问题诊断

安装 nginx 可能导致：
1. 端口冲突（nginx 占用了 5666 或其他端口）
2. 服务冲突（nginx 和 FNOS 的代理冲突）
3. 防火墙规则被修改

## 恢复步骤

### 1. 检查 FNOS 使用的代理

```bash
# 检查运行的服务
ps aux | grep -E "caddy|traefik|fnos|web"

# 检查监听端口
netstat -tlnp | grep -E "5666|80|443"

# 检查 FNOS 服务
systemctl list-units | grep -i fnos
systemctl status fnos
```

### 2. 停止并卸载 nginx

```bash
# 停止 nginx
sudo systemctl stop nginx
sudo systemctl disable nginx

# 卸载 nginx（如果不需要）
sudo apt remove nginx nginx-common  # Ubuntu/Debian
# 或
sudo yum remove nginx  # CentOS/RHEL

# 删除 nginx 配置
sudo rm -rf /etc/nginx/sites-enabled/pt-gen
sudo rm -rf /etc/nginx/sites-available/pt-gen
```

### 3. 恢复 FNOS 服务

```bash
# 重启 FNOS 服务
sudo systemctl restart fnos
# 或根据实际服务名
sudo systemctl restart fnos-web
sudo systemctl restart fnos-proxy

# 检查服务状态
sudo systemctl status fnos
```

### 4. 恢复 SSH 访问

```bash
# 检查 SSH 服务
sudo systemctl status ssh || sudo systemctl status sshd

# 重启 SSH
sudo systemctl restart ssh || sudo systemctl restart sshd
sudo systemctl enable ssh || sudo systemctl enable sshd

# 检查端口
netstat -tlnp | grep :22
```

### 5. 检查防火墙

```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw allow 5666/tcp

# CentOS/RHEL
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=5666/tcp
sudo firewall-cmd --reload
```

## 使用 FNOS 的代理方式（推荐）

如果 FNOS 使用 Caddy 或 Traefik，应该通过 FNOS 的配置界面添加反向代理规则，而不是安装 nginx。

