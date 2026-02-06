# Nginx 反向代理配置指南

## 快速配置步骤

### 1. 复制配置文件

```bash
# 方式一：使用 sites-available/sites-enabled（推荐）
sudo cp nginx-pt-gen.conf /etc/nginx/sites-available/pt-gen
sudo ln -s /etc/nginx/sites-available/pt-gen /etc/nginx/sites-enabled/

# 方式二：直接放到 conf.d（如果使用这种方式）
sudo cp nginx-pt-gen.conf /etc/nginx/conf.d/pt-gen.conf
```

### 2. 编辑配置文件

```bash
# 编辑配置文件
sudo nano /etc/nginx/sites-available/pt-gen
# 或
sudo nano /etc/nginx/conf.d/pt-gen.conf
```

**重要配置项：**
- 如果有域名，取消 `server_name` 的注释并填入你的域名
- 如果需要 HTTPS，配置 SSL 证书路径
- 确认 `proxy_pass` 指向 `http://127.0.0.1:8787`（如果服务在其他端口，请修改）

### 3. 测试配置

```bash
# 测试 Nginx 配置是否正确
sudo nginx -t
```

如果显示 `syntax is ok` 和 `test is successful`，说明配置正确。

### 4. 重载 Nginx

```bash
# 重载 Nginx 配置（不中断服务）
sudo systemctl reload nginx

# 或者重启 Nginx
sudo systemctl restart nginx
```

### 5. 验证

```bash
# 测试访问
curl http://localhost/
# 或使用域名
curl http://your-domain.com/

# 测试 API
curl -X POST "http://localhost/api?url=https://movie.douban.com/subject/36749573/"
```

## 配置说明

### 基本配置

- **监听端口**: 默认 80（HTTP），如需 HTTPS 配置 443
- **代理地址**: `http://127.0.0.1:8787`（本地服务）
- **日志文件**: `/var/log/nginx/pt-gen-*.log`

### 域名配置

如果有域名，修改配置文件：

```nginx
server_name your-domain.com www.your-domain.com;
```

### HTTPS 配置（使用 Let's Encrypt）

```bash
# 安装 Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# 获取 SSL 证书（自动配置）
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 或者手动配置，在 nginx 配置文件中添加：
# listen 443 ssl http2;
# ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
```

### 自定义端口

如果不想使用 80 端口，修改配置：

```nginx
listen 8080;  # 或其他端口
```

### 超时设置

如果 API 请求时间较长，可以增加超时时间：

```nginx
proxy_connect_timeout 300s;
proxy_send_timeout 300s;
proxy_read_timeout 300s;
```

## 常见问题

### 1. 502 Bad Gateway

**原因**: 后端服务未启动或无法连接

**解决**:
```bash
# 检查服务是否运行
curl http://127.0.0.1:8787/

# 检查服务状态
ps aux | grep "npm run dev"
# 或
pm2 status
```

### 2. 504 Gateway Timeout

**原因**: 后端响应超时

**解决**: 增加超时时间（见上面的超时设置）

### 3. 403 Forbidden

**原因**: 权限问题

**解决**:
```bash
# 检查 Nginx 日志
sudo tail -f /var/log/nginx/pt-gen-error.log

# 检查文件权限
sudo chown -R www-data:www-data /var/log/nginx/
```

### 4. 无法访问

**原因**: 防火墙未开放端口

**解决**:
```bash
# UFW
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 查看日志

```bash
# 访问日志
sudo tail -f /var/log/nginx/pt-gen-access.log

# 错误日志
sudo tail -f /var/log/nginx/pt-gen-error.log

# Nginx 主错误日志
sudo tail -f /var/log/nginx/error.log
```

## 完整示例（带域名和 HTTPS）

```nginx
server {
    listen 80;
    server_name pt-gen.example.com;
    
    # 重定向到 HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name pt-gen.example.com;
    
    ssl_certificate /etc/letsencrypt/live/pt-gen.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pt-gen.example.com/privkey.pem;
    
    access_log /var/log/nginx/pt-gen-access.log;
    error_log /var/log/nginx/pt-gen-error.log;

    location / {
        proxy_pass http://127.0.0.1:8787;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
    }
}
```

