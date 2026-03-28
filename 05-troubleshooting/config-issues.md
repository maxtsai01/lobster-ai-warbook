# 🔧 設定檔問題

> 症狀：改了設定後 Gateway 啟動失敗或行為異常

## 可能原因 & 解法

### 1. 加了不認識的 key
- **錯誤訊息**: `Config invalid; Unrecognized key: "xxx"`
- **解法**: `openclaw doctor --fix`（自動移除不認識的 key，備份到 .json.bak）
- **教訓**: 不要隨便加 unrecognized key，先查文檔確認

### 2. Windows BOM 編碼問題
- **症狀**: 手動改 JSON 後 Gateway 讀不到 token
- **原因**: Windows 的 JSON 需要 UTF-8 BOM（`EF BB BF`）
- **解法**: 
  - 不要手動改 auth-profiles.json
  - 用 `openclaw models auth paste-token --provider anthropic` 寫入
  - 如果必須手動改，用 `encoding='utf-8-sig'`
- **重要**: 改 JSON 必須用 `encoding='utf-8-sig'` 保留 BOM，否則 Gateway 啟動失敗

### 3. 改 token 但 Gateway 沒停
- **症狀**: 改了 auth-profiles.json 但 token 沒生效
- **原因**: Gateway 記憶體中的舊值會覆蓋回磁碟
- **解法**: 
  1. **先停 Gateway**（`pkill node` 或 `taskkill /F /IM node.exe`）
  2. 改 auth-profiles.json
  3. **再啟動 Gateway**
  - 不停就改會被覆蓋回去

### 4. Config 版本不相容
- **症狀**: `Config was last written by a newer OpenClaw (2026.3.13); current version is 2026.3.11`
- **原因**: Mac 和 Windows 的 OpenClaw 版本不同
- **解法**: 升級落後的那台：`npm install -g openclaw`
- **注意**: Windows 要加 `--ignore-scripts`（node-llama-cpp 會 crash）

### 5. SSH 改 macOS 的 authorized_keys 不生效
- **症狀**: SSH key 認證失敗
- **原因**: macOS 把 authorized_keys 路徑改到 `/etc/ssh/authorized_keys_%u`
- **解法**: 
  ```bash
  # 把 key 複製到正確位置
  sudo cp ~/.ssh/authorized_keys /etc/ssh/authorized_keys_$(whoami)
  
  # 或覆蓋設定
  echo 'AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys_%u' | sudo tee /etc/ssh/sshd_config.d/200-pubkey.conf
  sudo launchctl kickstart -k system/com.openssh.sshd
  ```
- **必要權限**: Home 目錄 755、.ssh 目錄 700、authorized_keys 600
