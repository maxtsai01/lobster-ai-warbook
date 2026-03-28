# 🔧 Windows 特有問題

> 症狀：Emily (Windows) 端的專屬問題

## 可能原因 & 解法

### 1. OpenClaw 安裝 OOM Crash
- **症狀**: `npm install -g openclaw` 反覆失敗
- **原因**: node-llama-cpp postinstall 腳本 crash（exit code 3221225477 = GPU 不相容）
- **解法**: 
  ```bash
  D:\node-v22.14.0-win-x64\npm.cmd install -g openclaw --ignore-scripts
  ```
- **如果記憶體不夠**: 先 `taskkill /F /IM Typeless.exe`（省 ~900MB）

### 2. Cloudflare Tunnel 啟動失敗
- **原因**: 用了 Windows Service 方式（system 帳號讀不到 user config）
- **解法**: 用 schtasks，不要用 Windows Service
  ```
  schtasks /Run /TN "Cloudflared-Emily"
  ```
- **注意**: 不要用 `start /B`（SSH 斷線後 process 會死）

### 3. SSH 操作 timeout
- **症狀**: Opus 4 模型下，複雜指令超過 20-30 秒 timeout
- **解法**: SSH timeout 設 45 秒以上
- **建議**: 日常用 Sonnet 4 快，策略討論才切 Opus 4

### 4. Gateway 自動重啟干擾 token 更新
- **症狀**: 改了 auth-profiles.json 但被 schtask 自動重啟的 Gateway 覆蓋回去
- **解法**: 
  1. `schtasks /End /TN "OpenClaw Gateway"` 先停排程
  2. `taskkill /F /IM node.exe` 殺 Gateway
  3. 改 token
  4. `schtasks /Run /TN "OpenClaw Gateway"` 重啟

### 5. HEARTBEAT.md 含 bash 指令導致 crash
- **症狀**: Emily Gateway 崩潰
- **原因**: Mac 的 HEARTBEAT.md 有 `bash tools/update-max-status.sh`，Windows 無 bash
- **解法**: Emily 用自己的 HEARTBEAT.md 版本，從 GDrive pull 清單移除 HEARTBEAT.md

### 6. PowerShell 中文亂碼
- **症狀**: SSH 遠端執行 cmd/powershell 輸出全是亂碼（如 `���\: ���`）
- **原因**: Windows 預設 codepage 950（Big5），SSH 傳輸用 UTF-8
- **解法**: 
  - 在指令前加 `chcp 65001 >nul &&`
  - 或改用 `cmd /c type` 讀取檔案
- **預防**: Windows 設定 → 語言 → 管理語言設定 → 變更系統地區設定 → 勾選「Beta: 使用 Unicode UTF-8 提供全球語言支援」

### 7. auth-profiles.json BOM 格式問題
- **症狀**: token 明明換了，但 Gateway 報 "No API key found"
- **原因**: Windows 編輯器（或 scp + Python `utf-8-sig`）存檔時帶 BOM，OpenClaw 讀不到 profile
- **解法**: 
  - ❌ 不要手動改 auth-profiles.json（Gateway 重啟會蓋回去）
  - ✅ 用 `openclaw models auth paste-token --provider anthropic` 正確寫入
  - 完整流程：`taskkill /F /IM node.exe` → `echo TOKEN | openclaw models auth paste-token --provider anthropic` → `schtasks /Run`
- **預防**: 永遠用 CLI 指令換 token，不要 scp 或手動編輯

### 8. Node.js 版本衝突
- **症狀**: Gateway 起不來，stderr 顯示 `SyntaxError: Invalid or unexpected token`
- **原因**: Windows PATH 裡的 node 版本（如 v22.16.0）跟 OpenClaw 不相容
- **解法**: 
  - gateway.cmd 裡用絕對路徑 `D:\node-v22.14.0-win-x64\node.exe`
  - 確認 gateway.cmd 的 PATH 設定指向正確版本
- **預防**: 不要隨便升級 Node.js，先在測試環境驗證

### 9. 排程任務（schtasks）Session 隔離
- **症狀**: schtask 跑的腳本連不到 AdsPower CDP（port 50325 無回應）
- **原因**: schtasks 預設跑在 Session 0（系統 session），看不到使用者桌面的應用
- **解法**: 
  - schtask 設定使用 `/IT`（interactive token，只在登入時跑）
  - 或改用 user session 的 startup script
- **預防**: 需要桌面互動的 task（AdsPower、Chrome CDP）一定要用 interactive session

### 10. openclaw.json 路徑 Windows vs Mac 不同
- **症狀**: Max 的 config 複製到 Emily，skill paths / binary paths 全指向 Mac 路徑（`/Users/mmmaxtsai/...`）
- **原因**: cross-platform 同步時沒有路徑替換
- **解法**: 同步後用 PowerShell 替換所有 Mac 路徑 → Windows 路徑
- **預防**: GDrive sync 只同步不含絕對路徑的檔案（MEMORY.md、shared-memory/），config 類不要同步
