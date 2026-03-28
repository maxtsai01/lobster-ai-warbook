# 01-setup — 環境建立 SOP

> 龍蝦從零啟動的完整流程。照這份做完，龍蝦就能跑起來。
> 最後更新：2026-03-28

---

## 🖥️ 環境選擇

| 場景 | 推薦環境 |
|------|---------|
| 主控 agent（策略型） | macOS |
| 執行 agent（爬蟲/自動化） | Windows |
| 24h 長跑服務（LINE@/webhook） | Windows + Cloudflare tunnel |

---

## 📦 Step 1：安裝 OpenClaw

```bash
# Node.js 22+ 必要
node -v  # 確認版本

# 安裝
npm install -g openclaw

# 確認
openclaw --version
```

---

## 🔑 Step 2：設定 API Token

```bash
# 互動式設定（建議用這個）
echo "sk-ant-oat01-..." | openclaw models auth paste-token --provider anthropic

# 確認設定
openclaw models list
```

**注意：**
- 每隻 agent 要用**不同帳號的 token**，避免額度互搶
- Token 存放位置：`~/.openclaw/agents/main/agent/auth-profiles.json`
- 換 token 後必須重啟 Gateway

---

## ⚙️ Step 3：設定 openclaw.json

設定路徑：`~/.openclaw/openclaw.json`

**最小可用設定：**
```json
{
  "agent": {
    "model": {
      "primary": "anthropic/claude-opus-4-6",
      "fallback": "anthropic/claude-sonnet-4-6"
    }
  },
  "plugins": {
    "discord": {
      "enabled": true,
      "token": "YOUR_BOT_TOKEN",
      "allowBots": true
    }
  }
}
```

**模型名稱正確寫法：**
- ✅ `anthropic/claude-opus-4-6`
- ✅ `anthropic/claude-sonnet-4-6`
- ❌ `claude-haiku-3-5`（會報 model_not_found）

---

## 🚀 Step 4：啟動 Gateway

```bash
# 啟動
openclaw gateway start

# 確認狀態
openclaw gateway status

# 重啟（換 token 或改設定後）
openclaw gateway restart
```

**Windows 注意：** 用 PowerShell，不能用 bash

---

## 📁 Step 5：設定 Workspace

```
~/.openclaw/workspace/
├── SOUL.md          # 龍蝦的個性定義
├── AGENTS.md        # 行為規則（最重要！）
├── USER.md          # 服務對象資訊
├── MEMORY.md        # 長期記憶（主 session 才讀）
├── HEARTBEAT.md     # 定時任務清單
├── memory/          # 日常日誌
│   └── YYYY-MM-DD.md
└── shared-memory/   # 多 agent 共享狀態
```

---

## 🔗 Step 6：Discord Bot 設定

1. Discord Developer Portal → 建立 Application → Bot
2. 複製 Bot Token 放進 openclaw.json
3. OAuth2 授權（需要 Administrator 權限）：
   ```
   https://discord.com/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=8&scope=bot
   ```
4. Gateway 重啟後 bot 出現在伺服器

---

## ✅ 確認清單

- [ ] `openclaw gateway status` 顯示 running
- [ ] Discord bot 出現在伺服器
- [ ] 在頻道發訊息 bot 有回應
- [ ] `SOUL.md` 已寫好（龍蝦知道自己是誰）
- [ ] `AGENTS.md` 已設定行為規則

---

## 常見問題

→ 見 `05-troubleshooting/agent-not-responding.md`
→ 見 `05-troubleshooting/config-issues.md`
