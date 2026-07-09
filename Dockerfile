# 阶段 1: 获取 sing-box 二进制
FROM ghcr.io/sagernet/sing-box:latest AS singbox-src

# 阶段 2: 获取 cloudflared 二进制
FROM cloudflare/cloudflared:latest AS cloudflared-src

# 阶段 3: 主镜像（基于 alpine/nginx，自带 nginx 和 gettext 转换工具）
FROM nginx:alpine

# 安装 envsubst (在 gettext 包中) 和 bash/libc6-compat（部分二进制依赖）
RUN apk add --no-cache gettext libc6-compat ca-certificates

# 从前序阶段复制二进制文件
COPY --from=singbox-src /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=cloudflared-src /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 复制配置模板和启动脚本
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY sing-box.json.template /etc/sing-box/config.json.template
COPY entrypoint.sh /entrypoint.sh

# 赋予执行权限
RUN chmod +x /entrypoint.sh

# 默认环境变量（可以在运行时覆盖）
ENV UUID=""
ENV TUNNEL_TOKEN=""

ENTRYPOINT ["/entrypoint.sh"]
