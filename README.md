# 🦞 龍蝦軍團作戰手冊 (Lobster AI Warbook)

> 把訓練 AI Agent 的模式變成可複製的 SOP + 問題解決方案

## 這是什麼？

一套完整的 AI Agent（OpenClaw 龍蝦）訓練與維運手冊。從零開始養一隻龍蝦，到多龍蝦協作，到問題排除，全部有 SOP。

## 目錄

| 資料夾 | 內容 | 狀態 |
|--------|------|------|
| `01-setup/` | 環境建立 SOP | 待寫 |
| `02-training/` | 角色訓練 + 龍蝦模板 | 待寫 |
| `03-profiles/` | 龍蝦屬性卡 | 待寫 |
| `04-operations/` | 日常維運 SOP | 待寫 |
| `05-troubleshooting/` | 問題解決（按症狀分類）| ✅ 完成 |
| `incidents/` | 歷史戰報 | 待寫 |
| `scripts/` | 工具腳本 | 待寫 |

## 快速導覽

### 龍蝦掛了？
→ 看 `05-troubleshooting/`，按症狀找：
- [Agent 不回應](05-troubleshooting/agent-not-responding.md)
- [設定檔問題](05-troubleshooting/config-issues.md)
- [瀏覽器自動化](05-troubleshooting/browser-automation.md)
- [記憶與同步](05-troubleshooting/memory-issues.md)
- [Windows 專屬](05-troubleshooting/windows-specific.md)

## 系統架構

```mermaid
graph TD
    A[👑 Allison 指揮官] -->|方向 + 拍板| B[🧠 Max COO]
    A -->|方向 + 拍板| C[💼 Emily PM]
    B <-->|壓力測試 + 辯論| C
    B -->|開發| D[lobster-xxx 對外產品]
    C -->|維護| E[warbook 內部知識]
    D --> F[學員 clone + 跑起來]
    E --> G[團隊自我優化]
```

## 團隊

- **Allison** — 指揮官 🎯
- **Max** — COO（Opus 大腦）🧠
- **Emily** — 專案經理（Opus 大腦）💼

---

## 🦞 龍蝦模組商店 Lobster Store

**💎 $100 USD/月 — 全部模組通用，訂閱即開通**

| Skill | 功能 |
|-------|------|
| 🎬 **[video-analyzer](https://github.com/maxtsai01/video-analyzer)** | AI 影片情報分析引擎 |
| 🤝 **[lobster-manus](https://github.com/maxtsai01/lobster-manus)** | AI 雙引擎協作（龍蝦×Manus） |
| 🛒 **[lobster-1shop](https://github.com/maxtsai01/lobster-1shop)** | 1Shop 電商自動化 |
| 🎯 **[lobster-adspower](https://github.com/maxtsai01/lobster-adspower)** | AdsPower 多帳號自動化 |
| 🤖 **[agent-orchestrator](https://github.com/maxtsai01/agent-orchestrator)** | 多代理協作引擎 |
| 📱 **[fb-auto-register](https://github.com/maxtsai01/fb-auto-register)** | AdsPower FB 自動註冊 |
| 🐰 **[followbunny](https://github.com/maxtsai01/followbunny-public)** | FB 社團自動互動 |
| 🌈 **[rainbow-life](https://github.com/maxtsai01/rainbow-life)** | AI 彩虹人生性格測驗 |
| 🖼️ **[ai-image-studio](https://github.com/maxtsai01/ai-image-studio)** | AI 智能圖片處理 |
| 🦞 **[lobster-ai-warbook](https://github.com/maxtsai01/lobster-ai-warbook)** | 龍蝦兵法訓練手冊 |

> 📸 私訊 [@10000allison](https://www.instagram.com/10000allison/) 訂閱 → 付款 → 全部模組即刻開通

