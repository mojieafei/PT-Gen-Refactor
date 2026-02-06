# 修复 Wrangler 绑定地址问题

## 问题
wrangler dev 只监听 `127.0.0.1:8787`，无法从外部访问。

## 原因
wrangler 的 `--host` 参数是用于转发请求的主机名，不是绑定地址。wrangler dev 默认只监听 localhost。

## 解决方案

### 方案一：使用 Nginx 反向代理（推荐，最简单）

```bash
# 1. 安装 Nginx
sudo apt install nginx  # Ubuntu/Debian
# 或
sudo yum install nginx  # CentOS/RHEL

# 2. 创建配置文件
sudo nano /etc/nginx/sites-available/pt-gen
```

添加配置：
```nginx
server {
    listen 8787;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8787;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# 3. 启用配置
sudo ln -s /etc/nginx/sites-available/pt-gen /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 4. 测试
curl http://192.168.2.13:8787
```

### 方案二：使用 socat 端口转发

```bash
# 安装 socat
sudo apt install socat  # Ubuntu/Debian
# 或
sudo yum install socat  # CentOS/RHEL

# 停止当前服务
pkill -f wrangler

# 启动服务（后台）
cd ~/PT-Gen-Refactor
npm run dev &

# 使用 socat 转发（监听 0.0.0.0:8787，转发到 127.0.0.1:8787）
socat TCP-LISTEN:8787,fork,reuseaddr TCP:127.0.0.1:8787 &
```

### 方案三：使用 iptables 端口转发

```bash
# 启用 IP 转发
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# 添加端口转发规则
sudo iptables -t nat -A PREROUTING -p tcp --dport 8787 -j DNAT --to-destination 127.0.0.1:8787
sudo iptables -t nat -A OUTPUT -p tcp --dport 8787 -d 127.0.0.1 -j DNAT --to-destination 127.0.0.1:8787

# 保存规则（Ubuntu/Debian）
sudo apt install iptables-persistent
sudo netfilter-persistent save

# 或（CentOS/RHEL）
sudo service iptables save
```

### 方案四：检查 wrangler 是否有其他参数

```bash
cd ~/PT-Gen-Refactor/worker
npx wrangler dev --help | grep -E "port|bind|listen|ip"
```

## 推荐方案
**使用 Nginx 反向代理**，这是最稳定和常用的方式。

