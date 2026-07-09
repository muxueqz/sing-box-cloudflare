#!/bin/sh

# 检查必要变量
if [ -z "$UUID" ]; then
  echo "Error: UUID environment variable is required."
  exit 1
fi

if [ -z "$TUNNEL_TOKEN" ]; then
  echo "Error: TUNNEL_TOKEN environment variable is required for cloudflared."
  exit 1
fi

echo "--- Generating configurations ---"
# 替换环境变量并生成最终配置文件
envsubst '$UUID' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
envsubst '$UUID' < /etc/sing-box/config.json.template > /etc/sing-box/config.json

echo "--- Starting sing-box ---"
sing-box run -c /etc/sing-box/config.json &

echo "--- Starting nginx ---"
nginx &

echo "--- Starting cloudflared tunnel ---"
# cloudflared 会在后台运行，并保持前台以便让容器不退出
exec cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN"
