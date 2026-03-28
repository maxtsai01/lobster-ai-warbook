#!/bin/bash
# refresh-emily-token.sh — 一鍵更新 Emily 的 Anthropic Token
# 用法：bash tools/refresh-emily-token.sh
# 前提：Mac 上已經裝好新 token（openclaw models auth paste-token）

TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['claudeAiOauth']['accessToken'])")

if [ -z "$TOKEN" ]; then
    echo "❌ 無法讀取 token，請先在 Mac 上跑 openclaw models auth paste-token"
    exit 1
fi

echo "Token tail: ${TOKEN: -12}"
echo "正在停止 Emily gateway..."
sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "taskkill /F /IM node.exe 2>&1" > /dev/null 2>&1

echo "正在安裝 token..."
echo $TOKEN | sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "D:\node-v22.14.0-win-x64\node.exe D:\node-v22.14.0-win-x64\node_modules\openclaw\dist\index.js models auth paste-token --provider anthropic" 2>&1 | tail -3

echo "正在重啟 gateway..."
sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "schtasks /run /tn \"OpenClaw Gateway\"" > /dev/null 2>&1

echo "等待 8 秒..."
sleep 8

HEALTH=$(sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "curl -s http://localhost:18789/health" 2>&1)
echo "Health: $HEALTH"

if echo "$HEALTH" | grep -q '"ok":true'; then
    echo "✅ Emily 恢復成功！"
else
    echo "❌ Emily 啟動失敗，請檢查"
fi
