========================================
Emily 修復完整紀錄
2026-03-27 15:00 ~ 2026-03-28 11:06
========================================

【事件起因】
Emily 從 3/26 晚上 22:15 開始無法回應 Discord 訊息
持續報錯約 20 小時

【錯誤演變過程】
1. 一開始：「API rate limit reached」
2. 接著：「overloaded（服務過載）」
3. 再來：「Provider anthropic is in cooldown」
4. 最後：「OAuth token has expired（Token 過期）」
5. 中間還出現：「No API key found」
6. 還有：「Invalid authentication credentials」

========================================
【排查過程 — 依時間順序】
========================================

--- 3/27 15:43 開始排查 ---

步驟 1：查看 Mac (Max) 的 log
- 指令：openclaw logs | tail -30
- 發現：Anthropic API 回傳 529 overloaded_error
- 結論：Anthropic 服務全球過載

步驟 2：SSH 進 Emily Windows 查看狀態
- 指令：sshpass -p 'Ct#Max2026!' ssh max@100.76.217.87
- Emily 的 gateway 是活的（curl localhost:18789/health → ok）
- 但 API 請求全部失敗

步驟 3：查 Emily 的 openclaw.json 設定
- 發現問題 #1：fallback 設定錯誤
  原本：primary=opus, fallback=opus（一樣的！沒有備援）
  應該：primary=opus, fallback=sonnet
- 修正：把 fallback 改成 sonnet

步驟 4：查 sessions.json
- 發現問題 #2：77 個 session 全部快取了 opus 模型
  即使改了設定，session 快取還是用舊模型
- 修正：把 sessions.json 裡 77 個 opus 替換成 sonnet
- 釋放了 23MB 廢棄 session 檔案

步驟 5：查 auth-profiles.json（API Token）
- 發現問題 #3：Emily 用了彩虹 VIP 的 token（...MYaJCgAA）
  不是她自己的 token（應該用 ...cYGuOAAA）
- 三組 Token 對照：
  Max（Mac）: ...y8zSWQAA（max14151610@gmail.com）
  Emily（Windows）: ...cYGuOAAA（max@ctmaxs.com）
  彩虹 VIP: ...MYaJCgAA（jeff@9417.com.tw）

步驟 6：改了 compaction 設定
- 把 compaction 從 default 改成 aggressive
- 結果：OpenClaw 不接受 aggressive！只接受 default 或 safeguard
  這導致 config 錯誤，影響 gateway 啟動
- 修正：改成 safeguard

--- 3/27 19:00 前後 ---

步驟 7：Token 問題浮現
- 發現 Emily 的 Anthropic token 全部過期
- 嘗試直接改 auth-profiles.json → 失敗！
  重要發現：直接改 auth-profiles.json 無效！
  OpenClaw 重啟時會從 openclaw.json 蓋回去

--- 3/28 10:43 繼續修復 ---

步驟 8：Token 確認過期
- 錯誤變成：HTTP 401 OAuth token has expired

步驟 9：嘗試停止 Emily
- 停排程：schtasks /change /tn "XXX" /disable（停了 8 個排程）
- kill node.exe
- 但 Emily 一直被自動重啟！

步驟 10：找到自動重啟的元兇
- 發現 Windows Service：openclaw-gateway
  用 sc query 找到的
- 停掉：sc stop openclaw-gateway & sc config start= disabled
- 還有 gateway-watchdog.cmd 無限循環腳本
  rename 成 .disabled

步驟 11：封鎖 Emily 的 Discord 頻道權限
- 避免她一直刷錯誤訊息
- Discord API: PUT /channels/{id}/permissions/{emily_id} deny=3072

--- 3/28 11:00 最終解法 ---

步驟 12：正確安裝 Token（最終解法）
- 在 Mac 上：openclaw models auth paste-token --provider anthropic
  → 取得新 token（sk-ant-oat01-Z7JQ...muk8cgAA）
- 用 SSH 透過 echo pipe 方式安裝到 Emily：
  echo $TOKEN | ssh max@100.76.217.87 "openclaw models auth paste-token --provider anthropic"
- 這個指令會正確更新 openclaw.json（不是 auth-profiles.json）

步驟 13：重啟 Emily + 恢復權限
- schtasks /run /tn "OpenClaw Gateway"
- 恢復 Discord 頻道權限
- Emily 正常回應！✅

========================================
【根本原因總結】
========================================

1. Anthropic 服務全球過載（外部因素，不可控）
2. Emily 的 fallback 設定錯誤（primary=opus, fallback 也是 opus）
3. sessions.json 快取了舊模型，改設定後沒跟著更新
4. Emily 用了錯誤的 API token（彩虹 VIP 的，不是自己的）
5. Token 過期後，直接改 auth-profiles.json 無效（要用 CLI）
6. 多層自動重啟機制（排程 + Windows Service + watchdog 腳本）讓停機困難

========================================
【修復產出物】
========================================

1. SOP 文件：docs/emily-token-refresh-sop.md
2. 一鍵腳本：tools/refresh-emily-token.sh
3. 本紀錄：docs/emily-修復紀錄-2026-03-27.txt

========================================
【以後 Token 過期時的流程】
========================================

你只需做一件事：
→ 在 Mac 終端機跑：openclaw models auth paste-token --provider anthropic
→ 然後告訴 Max，Max 會自動同步給 Emily

或者你也可以自己跑第二步：
→ bash tools/refresh-emily-token.sh

========================================
【教訓與改進】
========================================

1. 不要直接改 auth-profiles.json → 用 CLI 指令
2. fallback 模型不能跟 primary 一樣
3. compaction 只能設 default 或 safeguard（不能 aggressive）
4. 停 Emily 要停三層：排程 + Windows Service + watchdog 腳本
5. sessions.json 裡的 model 快取會覆蓋設定檔的 model 設定

========================================
【追加修復：Token 分離（2026-03-28 15:00）】
========================================

發現 Max 和 Emily 共用同一組 token（max14151610@gmail.com），
而 max@ctmaxs.com 的 token 閒置沒人用。

修正：
- Max 改用 max@ctmaxs.com 的 token（...y8zSWQAA）
- Emily 維持 max14151610@gmail.com 的 token（...muk8cgAA）
- Rainbow VIP 維持 jeff@9417.com.tw 的 token

注意：Mac 上 OpenClaw 有兩個地方存 token：
1. auth-profiles.json — paste-token 指令會更新這裡
2. Mac 鑰匙圈（Claude Code-credentials）— gateway 優先讀這裡
兩個都要改才會生效！
