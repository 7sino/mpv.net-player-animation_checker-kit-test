mpv.netでのマウススクラブシーク実装について、詳しく分析しました。**残念ながら、mpv.netの制約により完璧な実装は困難**ですが、いくつかの解決策を提案します。
##  問題の本質
mpv.netは**独自のウィンドウドラッグ実装**を持っており、以下の問題があります：
  
```
┌─────────────────────────────┐
│ デッドゾーン（上10%）      │ ← ドラッグ無効
├─────────────────────────────┤
│ 左10%│  中央エリア  │右10% │ ← ドラッグ有効
│ -----│  ★ここが問題 │----- │    (スクラブと競合)
├─────────────────────────────┤
│ デッドゾーン（下22%）      │ ← ドラッグ無効
└─────────────────────────────┘
```
  
1. **`no-window-dragging`が効かない** - mpv.net独自実装のため
2. **画面中央でドラッグするとウィンドウが動く** - Luaスクリプトより先に処理される
3. **OSCとの競合** - 下部のシークバーエリアとの干渉
## ✅ 実用的な解決策（3つ）
  
### 【解決策1】改良版scrub-seek.lua（推奨）
  
現在の`scrub-seek.lua`を改善し、OSCエリア外で確実に動作するようにします
### ステップ1: ファイル配置
  
```
portable_config/
├── mpv.conf                          ← 上記の最適化版
├── input.conf                        ← 上記の対応版
└── scripts/
    └── scrub-seek-improved.lua      ← 改良版スクリプト
```
  
### ステップ2: 操作エリアの理解
  
```
┌─────────────────────────────┐
│ ✅ 上部10% - スクラブOK     │
├─────────────────────────────┤
│ ✅左  ❌      中央     ✅右  │  ← 左右10%のみスクラブOK
│  10% │  (ウィンドウ移動)│10% │    中央は避ける
├─────────────────────────────┤
│ ✅ 下部22% - スクラブOK     │
│    (ただしOSCバー除く)      │
└─────────────────────────────┘
```
  
**推奨操作エリア：**
- ✅ **画面左端・右端**（左右10%のエリア）
- ✅ **画面下部**（下22%のエリア、OSCバーより上）
- ❌ **画面中央**（ウィンドウドラッグと競合）
  
### ステップ3: 動作テスト
  
1. mpv.netを起動
2. `` ` ``キーでコンソールを開く
3. 以下のメッセージを確認：
  
```
✓ Scrub Seek Script Loaded (mpv.net Edition)
✓ Safe zones: Top, Left, Right, Bottom edges
⚠ Avoid center area (window dragging zone)
```
  
4. 動画を再生
5. **画面左端**でマウスドラッグ → シークされればOK！
  
---
  
## 【解決策2】mpv.netでの妥協案 + 操作習慣の変更
完全な解決は難しいですが、以下の方法で**80%の満足度**は得られます：
### 実践的な使い方
```
✅ 推奨操作：
1. 画面左端・右端（10%エリア）でドラッグ
2. 画面下部（OSCバーより上）でドラッグ
3. 中央エリアは触らない
  
⚠️ 避けるべき操作：
1. 画面中央でのドラッグ
2. 長距離のドラッグ
```
  
### カスタマイズ例
**sensitivity（感度）調整**
`scrub-seek-improved.lua`の設定値を変更：
  
```lua
-- 感度を上げる（より速くシーク）
sensitivity = 0.3,  -- デフォルト: 0.15
  
-- 感度を下げる（より細かくシーク）
sensitivity = 0.05,
```
スクリプトが読み込まれているのにシークできない原因を特定しました。**マウスイベントの登録方法に問題**があります。
  ---
  
## 🔍 問題の原因
  
1. **`script-binding`の不完全な実装** - マウスムーブとマウスアップが正しく処理されていない
2. **mpv.netのイベントシステムとの競合** - 標準的な`add_key_binding`では不十分
3. **input.confの設定ミス** - マウスイベントが正しくスクリプトに渡っていない
  
## ✅ 完全修正版スクリプト
### 1. ファイルの配置
  
```
portable_config/
├── mpv.conf                              ← 既存のまま
├── input.conf                            ← 上記の修正版に置き換え
└── scripts/
    ├── scrub-seek-improved-v2.lua       ← 新しいスクリプト
    └── scrub-seek.lua                   ← 古いものは削除or リネーム
```
  
### 2. input.conf の重要な変更点
**❌ 削除すべき行：**
```ini
MBTN_LEFT           script-binding mouse-down
MBTN_LEFT           ignore
MBTN_LEFT+drag      ignore
```
  
**✅ 正しい状態：**
```ini
# MBTN_LEFT に関する記述を一切書かない
# スクリプトが add_forced_key_binding で直接制御
```
  
### 3. デバッグモードの確認
スクリプト内の `debug` フラグは `true` に設定されています。コンソール（`` ` ``キー）で詳細なログを確認できます。
  
---
  
## 🧪 動作テスト手順
### ステップ1: mpv.netを再起動
1. mpv.netを完全に終了
2. 動画ファイルを開く
3. `` ` ``キーでコンソールを開く
4. 
### ステップ2: ログの確認
以下のメッセージが表示されることを確認：
  
```
[scrub_seek_improved] Scrub Seek v2 (Mouse Property Observer)
[scrub_seek_improved] ✓ Safe zones: Edges (Top/Left/Right/Bottom)
[scrub_seek_improved] ⚠ Avoid: Center area (window drag zone)
[scrub_seek_improved] ✓ OSC area excluded: bottom 80px
```
### ステップ3: マウス操作テスト
#### テスト1: 画面左端でドラッグ
  
```
操作：画面左端（左から10%のエリア）で左右にドラッグ
  
期待される表示：
[scrub_seek_improved] Mouse DOWN at (50,300) - area: safe
[scrub_seek_improved] ✓ Ready to scrub
[scrub_seek_improved] ✓ Drag started (dist: 8.5px)
[scrub_seek_improved] ✓ Seek: 10.50s + 0.15s = 10.65s
[scrub_seek_improved] ✓ Seek: 10.65s + 0.18s = 10.83s
[scrub_seek_improved] ✓ Mouse released
```
  
#### テスト2: 画面下部でドラッグ
  
```
操作：画面下部（下から22%、OSCバーより上）で左右にドラッグ
  
期待される表示：
[scrub_seek_improved] Mouse DOWN at (400,700) - area: safe
[scrub_seek_improved] ✓ Ready to scrub
[scrub_seek_improved] ✓ Drag started (dist: 12.3px)
[scrub_seek_improved] ✓ Seek: 5.20s + 0.30s = 5.50s
```
  
#### テスト3: 画面中央でドラッグ（エラー確認）
  
```
操作：画面中央でドラッグ
  
期待される表示：
[scrub_seek_improved] Mouse DOWN at (960,540) - area: center
[scrub_seek_improved] ⚠ Center area - skipping (window drag zone)
（何も起こらない = 正常）
```
  
#### テスト4: クリックで一時停止
  
```
操作：画面左端でクリック（ドラッグしない）
  
期待される表示：
[scrub_seek_improved] Mouse DOWN at (50,300) - area: safe
[scrub_seek_improved] Mouse UP at (50,300) - dragging: false
[scrub_seek_improved] ✓ Click detected - toggled pause
```
  
---
  
## 🐛 トラブルシューティング
  
### 問題1: 「area: unknown」と表示される
  
**原因：** OSDサイズが取得できていない
  
**解決策：**
```ini
# mpv.conf に追加
osd-scale=1.0
```
  
### 問題2: マウスイベントが全く検出されない
  
**原因：** input.confに古い設定が残っている
  
**解決策：**
```bash
# input.conf から以下を完全削除
MBTN_LEFT (すべての行)
MBTN_LEFT_UP (すべての行)
```
  
### 問題3: シークはできるがウィンドウも動く
  
**原因：** 中央エリアで操作している
  
**解決策：** 画面の端（左右10%、下22%）で操作する
  
### 問題4: 感度が合わない
  
**解決策：** スクリプト内の `sensitivity` を調整
  
```lua
-- より速くシーク
sensitivity = 0.3,  -- デフォルト: 0.15
  
-- より細かくシーク
sensitivity = 0.05,
```
  
---
  
## 📊 デバッグ情報の見方
  
### 正常動作時のログ例
  
```
[scrub_seek_improved] Mouse DOWN at (100,400) - area: safe
[scrub_seek_improved] ✓ Ready to scrub - drag left/right to seek
[scrub_seek_improved] ✓ Drag started (dist: 10.2px)
[scrub_seek_improved] ✓ Seek: 5.00s + 0.45s = 5.45s
[scrub_seek_improved] ✓ Seek: 5.45s + 0.30s = 5.75s
[scrub_seek_improved] ✓ Mouse released
```
  
### エラー時のログ例
  
```
# 中央エリアでの操作（意図的にスキップ）
[scrub_seek_improved] Mouse DOWN at (960,540) - area: center
[scrub_seek_improved] ⚠ Center area - skipping (window drag zone)
  
# OSCエリアでの操作（完全無視）
[scrub_seek_improved] Mouse DOWN at (960,1000) - area: osc
（何もログ出力されない = 正常）
```
  
---
  
## 🎨 感度のカスタマイズ例
  
### アニメーター向け（精密操作）
  
```lua
local opts = {
    sensitivity = 0.05,        -- 非常に細かい制御
    drag_threshold = 3,        -- ドラッグ検出を鋭敏に
    click_threshold = 0.15,    -- クリック判定を厳密に
}
```
  
### 一般ユーザー向け（快適操作）
  
```lua
local opts = {
    sensitivity = 0.2,         -- やや速めのシーク
    drag_threshold = 8,        -- 誤操作防止
    click_threshold = 0.25,    -- クリック判定を寛容に
}
```
  
---
  
## 📸 期待される動作
  
画像1のように、コンソールで以下が確認できれば成功です：
  
```
✓ Mouse DOWN が検出される
✓ area: safe と表示される（左右端・下部の場合）
✓ Drag started が表示される
✓ Seek: X.XXs + X.XXs = X.XXs が連続表示される
✓ Mouse released で終了
```
