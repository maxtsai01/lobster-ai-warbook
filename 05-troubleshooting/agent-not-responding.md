# 🔧 Agent 不回應

> 症狀：在 Discord / LINE 傳訊息給龍蝦，但沒有回應

## 可能原因 & 解法

### 1. API 額度用完（Rate Limit）
- **錯誤訊息**: `⚠️ API rate limit reached`
- **原因**: Claude Max 訂閱的週額度用完
- **解法**: 
  - 等週五 12:00 PM 自動重置
  - 或在 claude.ai → Settings → 開啟 Extra Usage
  - 暫時切換到 Sonnet（Sonnet 有獨立額度池）
- **預防**: 兩隻龍蝦不要共用同一個 token，分開帳號各自有額度

### 2. API 服務過載（Overloaded）
- **錯誤訊息**: `The AI service is temporarily overloaded`
- **原因**: Anthropic 伺服器端問題，不是我們的設定
- **解法**: 等待自動恢復（通常幾分鐘到幾小時）
- **預防**: 無法預防，是 Anthropic 端的問題

### 3. Gateway 掛了
- **症狀**: 所有頻道都沒回應，不只一個
- **確認**: `openclaw status` 或 `curl localhost:18789/health`
- **解法**: 
  - Mac: `openclaw gateway restart`
  - Windows: `schtasks /Run /TN "OpenClaw Gateway"`
- **根因**: 可能是 active sessions 過多、context 過長、或記憶體不足

### 4. Token 過期或無效
- **錯誤訊息**: `No API key found for provider "anthropic"`
- **原因**: auth-profiles.json 的 token 無效或格式錯
- **解法**: 
  ```bash
  # 先停 Gateway
  taskkill /F /IM node.exe  # Windows
  pkill node                # Mac
  
  # 用官方工具寫入 token（不要手動改 JSON！）
  openclaw models auth paste-token --provider anthropic
  # 貼上 token → Enter
  
  # 重啟 Gateway
  ```
- **⚠️ 重要**: 不要手動編輯 auth-profiles.json，Windows 上有 BOM 編碼問題

### 5. Discord allowBots 沒開
- **症狀**: 人類的訊息有回，bot 的訊息沒回
- **原因**: openclaw.json 的 `channels.discord` 沒有 `allowBots: true`
- **解法**: 在 `channels.discord` 頂層加 `"allowBots": true`，重啟 Gateway
- **注意**: 必須在頂層，不是在 guilds 裡面

### 6. Discord WebSocket 斷線
- **症狀**: Discord 收不到訊息，但能用 API 發訊息
- **Log 特徵**: `gatewayConnected=false`、`fetch-bot-identity:error`
- **解法**: `openclaw gateway restart`（可能需要多次）
- **版本**: OpenClaw 2026.3.22 已知 bug

### 7. LINE Webhook 斷了
- **症狀**: LINE 訊息沒回應，log 裡沒有 inbound
- **原因**: Cloudflare Tunnel 沒在跑
- **解法**: 
  ```bash
  # Mac
  launchctl kickstart gui/$(id -u)/com.cloudflare.cloudflared
  
  # Windows
  schtasks /Run /TN "Cloudflared-Emily"
  ```
