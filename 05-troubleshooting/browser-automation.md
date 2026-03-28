# 🔧 瀏覽器自動化問題

> 症狀：CDP 連不上、操作失敗、或瀏覽器行為異常

## 瀏覽器使用規則
- **Comet CDP 9333** = 所有資料爬取、網頁分析、操作網站
- **AdsPower CDP 50325** = 僅限跟單兔多帳號按讚留言
- **Chrome** = 禁用，任何情況都不開

## 可能原因 & 解法

### 1. Comet CDP 連不上
- **症狀**: `curl localhost:9333/json` 無回應
- **解法**: 確認 Comet 瀏覽器有在跑，確認 port 9333 開啟
- **注意**: 連接時需要 `suppress_origin=True`

### 2. Chrome CDP 限制（Chrome 147+）
- **症狀**: Chrome 不讓開 CDP
- **原因**: Chrome 147+ 不允許預設 data dir 開 CDP
- **解法**: 用 `--user-data-dir="$HOME/.chrome-cdp"` + `--profile-directory="Profile 84"`
- **⚠️ 但我們現在統一用 Comet，不再用 Chrome CDP**

### 3. FB 按讚失敗（合成事件被偵測）
- **症狀**: CDP click、Selenium click、JS click 都無法對 FB 按讚
- **原因**: Facebook 檢測 synthetic events
- **解法**: 用 CDP 找到按鈕的 CSS 座標，再用 cliclick 在真實螢幕座標點擊
- **關鍵**: 按讚後 aria-label 變成「移除讚」（不是「收回讚」）

### 4. AdsPower 瀏覽器無法爬 FB 社團
- **症狀**: bodyH 永遠停在 ~2195px，只載入 1 篇貼文
- **原因**: 反指紋功能干擾 FB IntersectionObserver
- **解法**: 用 Comet 瀏覽器爬貼文，AdsPower 只做按讚+留言
- **結論**: Browser Relay (Comet) 負責爬貼文，AdsPower 只做互動

### 5. FB 留言被偵測
- **症狀**: 留言看起來像機器人
- **原因**: 留言內容有引號或不自然
- **解法**: 
  - 留言不能有引號
  - 要像真人打的自然語言
  - 用 CDP `Input.insertText` 打字 + `rawKeyDown Enter` 送出

### 6. Chrome 重開後需要重新登入
- **症狀**: x.com / Google 顯示登入頁
- **解法**: 必須 Allison 手動登入，cookies 保留在 `~/.chrome-cdp`
- **注意**: 這無法自動化，不要嘗試
