# 🦞 Lobster Repo 標準規格

> 每個 lobster-xxx GitHub 專案都必須遵守這個規格

## 必備元素

### 1. 防呆引導精靈（setup-wizard.js）
- 位置：`scripts/setup-wizard.js`
- 功能：一步步帶使用者完成所有設定
- 每步都有驗證，沒完成不讓進下一步
- 卡住了自動給解決方案

### 2. 環境變數範本（.env.example）
- 列出所有需要填的 key
- 值全部用 `YOUR_XXX` 佔位

### 3. 設定檔範本（config/config.example.json）
- 完整的設定結構
- 所有敏感值脫敏

### 4. README.md
- 3 行指令跑起來（clone → npm install → node setup-wizard）
- 功能清單
- 架構圖
- 需要準備的東西

### 5. 文件（docs/）
- setup.md — 詳細安裝說明
- daily-run.md — 每日運作
- troubleshooting.md — 問題排除

## setup-wizard 標準流程

```
Step 1: 確認必要帳號（含聯盟行銷連結）
  → 沒有 → 引導去註冊 → 等確認
  → 有了 → 下一步

Step 2: 輸入 API Key / 帳號資訊
  → 自動驗證是否有效
  → 無效 → 給截圖說明哪裡找
  → 有效 → 下一步

Step 3-N: 其他設定（依專案而異）
  → 每步都驗證

最後: 自動儲存 config.json + .env
  → 「你的龍蝦準備好了！」
```

## 脫敏原則

- ✅ 可公開：流程邏輯、程式碼、SOP
- ❌ 不公開：真實帳密、API Key、客戶資料
- 所有敏感值用環境變數（`process.env.XXX`）
- 附範例表單（空白版，結構對，資料清空）
