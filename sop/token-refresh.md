# Emily Token 更新 SOP

> 當 Emily 出現 `OAuth token has expired` 或 `No API key found` 錯誤時，按以下步驟修復。

## 前提

- Emily 跑在 Windows（IP: 100.76.217.87）
- Mac 可以 SSH 到 Emily：`sshpass -p 'Ct#Max2026!' ssh max@100.76.217.87`
- Token 是 Anthropic OAuth token（`sk-ant-oat01-...` 開頭）

## 方法一：Max 透過 SSH 幫 Emily 安裝（推薦）

### 步驟 1：在 Mac 取得新 Token

```bash
# 在 Mac 終端機跑
openclaw models auth paste-token --provider anthropic
```

它會打開瀏覽器讓你登入 Claude，取得新 token 後貼上，按 Enter。

### 步驟 2：確認 Mac 上的 Token 有效

```bash
openclaw gateway restart
```

確認 Max 能正常回應。

### 步驟 3：Max SSH 到 Emily 安裝同一組 Token

```bash
# 從 Mac 的鑰匙圈讀取新 token
NEW_TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['claudeAiOauth']['accessToken'])")

# SSH 到 Emily，用 echo pipe 方式執行 paste-token
echo $NEW_TOKEN | sshpass -p 'Ct#Max2026!' ssh max@100.76.217.87 "D:\node-v22.14.0-win-x64\node.exe D:\node-v22.14.0-win-x64\node_modules\openclaw\dist\index.js models auth paste-token --provider anthropic"
```

### 步驟 4：重啟 Emily Gateway

```bash
sshpass -p 'Ct#Max2026!' ssh max@100.76.217.87 "schtasks /run /tn \"OpenClaw Gateway\""
```

### 步驟 5：驗證

```bash
# 等 8 秒讓 gateway 啟動
sleep 8
sshpass -p 'Ct#Max2026!' ssh max@100.76.217.87 "curl -s http://localhost:18789/health"
# 應該回 {"ok":true,"status":"live"}
```

## 方法二：Allison 在 Windows 直接操作

### 步驟 1：打開 Windows 終端機（PowerShell 或 CMD）

### 步驟 2：執行

```cmd
openclaw models auth paste-token --provider anthropic
```

貼上新的 `sk-ant-oat01-...` token，按 Enter。

### 步驟 3：重啟

```cmd
openclaw gateway restart
```

## ⚠️ 重要注意事項

1. **不要直接改 auth-profiles.json！** OpenClaw 重啟會從 openclaw.json 蓋回去。一定要用 `openclaw models auth paste-token` CLI 指令。
2. **Token 會過期！** Claude Max 的 OAuth token 有效期大約 24-48 小時，過期後需要重新安裝。
3. **停 Emily 再換 Token！** 如果 Emily 一直在刷錯誤，先停她：
   ```bash
   sshpass -p 'Ct#Max2026!' ssh max@100.76.217.87 "sc stop openclaw-gateway & taskkill /F /IM node.exe"
   ```
4. **Mac 和 Emily 可以用同一組 Token**（同一個 Anthropic 帳號），不衝突。

## 快速一鍵腳本（放在 Mac 上）

```bash
#!/bin/bash
# tools/refresh-emily-token.sh
# 用法：bash tools/refresh-emily-token.sh

TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['claudeAiOauth']['accessToken'])")

echo "Token tail: ${TOKEN: -12}"
echo "正在停止 Emily gateway..."
sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "taskkill /F /IM node.exe 2>&1" > /dev/null

echo "正在安裝 token..."
echo $TOKEN | sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "D:\node-v22.14.0-win-x64\node.exe D:\node-v22.14.0-win-x64\node_modules\openclaw\dist\index.js models auth paste-token --provider anthropic" 2>&1 | tail -3

echo "正在重啟 gateway..."
sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "schtasks /run /tn \"OpenClaw Gateway\"" > /dev/null 2>&1

sleep 8
HEALTH=$(sshpass -p 'Ct#Max2026!' ssh -o StrictHostKeyChecking=no max@100.76.217.87 "curl -s http://localhost:18789/health" 2>&1)
echo "Health: $HEALTH"

if echo "$HEALTH" | grep -q '"ok":true'; then
    echo "✅ Emily 恢復成功！"
else
    echo "❌ Emily 啟動失敗，請檢查"
fi
```

## 歷史紀錄

- 2026-03-28：首次建立此 SOP。問題從 3/27 晚開始，原因是 Anthropic overload + token 過期 + auth-profiles.json 直接改無效。
