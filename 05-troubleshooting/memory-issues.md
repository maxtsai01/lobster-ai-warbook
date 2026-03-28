# 🔧 記憶與同步問題

> 症狀：龍蝦忘記之前的對話、記憶過時、或同步失敗

## 可能原因 & 解法

### 1. Session 爆掉記憶斷片
- **症狀**: 龍蝦問你之前講過的事、重複相同錯誤
- **原因**: Context 到 100% 後 session 重啟，失去所有上下文
- **解法**: 
  - 重要決策立刻寫 MEMORY.md（不等 session 結束）
  - 用向量記憶（memory_store）儲存關鍵資訊
  - Context 40% 時主動提醒開新 session
- **預防**: AGENTS.md 加「記憶覆寫檢查點」規則

### 2. MEMORY.md 資訊過時
- **症狀**: 龍蝦基於過時資訊做出錯誤判斷
- **案例**: 跟單兔架構已從 Automa 換成 AdsPower，但 MEMORY.md 還寫 Automa
- **解法**: 每次結構性變更，必須回去覆寫 MEMORY.md 的舊段落
- **原則**: 「加新的」和「改舊的」是兩件事。結構性變更必須改舊的

### 3. Google Drive 同步失敗
- **症狀**: Mac 和 Windows 的檔案不一致
- **確認**: 看 `tools/gdrive-sync.log` 最後更新時間
- **解法**: 手動觸發同步 `bash tools/gdrive-sync.sh`
- **注意**: SOUL.md 和 IDENTITY.md 不同步（各 agent 各自有自己的）

### 4. 向量記憶搜不到
- **症狀**: memory_recall 找不到之前存的資訊
- **原因**: 搜尋關鍵字不對、或記憶過期被清理
- **解法**: 用不同關鍵字搜、或直接讀 MEMORY.md
