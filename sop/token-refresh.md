# Token 更換 SOP（正規流程）

> ⚠️ 必須按順序執行，不能跳步！

## 正規四步流程

### 步驟 1：停止 Gateway
```bash
# Mac
openclaw gateway stop

# Windows（Emily）
D:\node-v22.14.0-win-x64\node.exe D:\node-v22.14.0-win-x64\node_modules\openclaw\dist\index.js gateway stop
```

### 步驟 2：更換 Token
打開 `auth-profiles.json`，把 `"token": "sk-ant-oat01-..."` 換成新的。

**檔案位置：**
- Mac：`/Users/mmmaxtsai/.openclaw/agents/main/agent/auth-profiles.json`
- Windows：`C:\Users\max\.openclaw\agents\main\agent\auth-profiles.json`

### 步驟 3：Doctor Fix（關鍵！不能跳！）
```bash
# Mac
openclaw doctor --fix

# Windows（Emily）
D:\node-v22.14.0-win-x64\node.exe D:\node-v22.14.0-win-x64\node_modules\openclaw\dist\index.js doctor --fix
```

> ⚠️ 這步會同步 auth-profiles.json 到 openclaw.json，防止 gateway restart 時被舊設定覆蓋。

### 步驟 4：重啟 Gateway
```bash
# Mac
openclaw gateway restart

# Windows（Emily）
D:\node-v22.14.0-win-x64\node.exe D:\node-v22.14.0-win-x64\node_modules\openclaw\dist\index.js gateway restart
```

## 為什麼不能跳步？

- **不 stop 就改 token** → Gateway 記憶體裡還是舊 token，改了也沒用
- **不跑 doctor --fix** → gateway restart 會從 openclaw.json 重新產生 auth-profiles.json，把你改的蓋回舊的
- **直接 restart** → 等於 stop + start，但中間沒機會改 token

## 常見問題

### Q: 改了 token 但被蓋回去？
A: 你漏了 `doctor --fix`。重新走四步。

### Q: Gateway restart 後斷線？
A: 正常！restart = 停 + 重啟，中間會短暫斷線。

### Q: Rate limit 怎麼辦？
A: 換一組不同帳號的 token，或等額度恢復（通常幾小時）。

## 歷史紀錄
- 2026-03-30：發現 `doctor --fix` 是防止覆蓋的關鍵步驟（Allison 實測）
- 2026-03-28：首次建立 SOP
