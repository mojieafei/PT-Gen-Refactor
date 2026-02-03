# Docker 构建问题修复指南

## 问题 1: npm ci 错误

**错误**: `npm ci` 需要 package-lock.json 文件

**已修复**: Dockerfile 已更新，会自动检测文件是否存在

## 问题 2: 环境变量警告

**警告**: `WARNING: The "o3" variable is not set`

**原因**: Cookie 中的 `$` 符号被 shell 解析为变量

**解决方案**: 在 `.env` 文件中，Cookie 值需要用单引号包裹

### 正确的 .env 格式：

```env
# ✅ 正确 - 使用单引号
DOUBAN_COOKIE='ll="108288"; bid=kuXrYJv8FTc; _vwo_uuid_v2=...; _ga_Y4GN1R87RG=GS2.1.s1768885145$o3$g1$t1768885158$j47$l0$h0; ...'

# ❌ 错误 - 没有引号，$ 会被解析
DOUBAN_COOKIE=ll="108288"; bid=kuXrYJv8FTc; ... _ga_Y4GN1R87RG=GS2.1.s1768885145$o3$g1$...
```

### 快速修复步骤：

1. 编辑 `.env` 文件：
   ```bash
   nano .env
   ```

2. 确保 DOUBAN_COOKIE 用单引号包裹：
   ```env
   DOUBAN_COOKIE='你的完整Cookie值'
   ```

3. 保存并重新构建：
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

## 重新构建命令

```bash
# 清理并重新构建
docker compose down
docker compose build --no-cache
docker compose up -d

# 查看日志
docker compose logs -f
```

