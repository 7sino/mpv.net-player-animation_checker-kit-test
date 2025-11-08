# 実用的な解決策 - mpv.netでのスクラブ機能実現

## 🎯 現状の問題点まとめ

1. ❌ **pointer-event.lua** - 絶対位置スクラブ（`%f`）をサポートしていない
2. ⚠️ **mpv-gestures** - 動作はするが、gestures.confがエラーを出す + ウィンドウドラッグと競合
3. ❌ **no-window-dragging** - mpv.netでは効かない（独自実装のため）

---

## ✅ 即座に実行する3ステップ

### ステップ1: gestures.confを削除

```bash
# このファイルを削除
portable_config\script-opts\gestures.conf
```

**理由**: mpv-gesturesは設定ファイルをサポートしていません。存在するとエラーが出ます。

---

### ステップ2: mpv.confとinput.confを確認

**mpv.conf**:
```ini
# no-window-draggingは効果がないが、残しておいてOK
no-window-dragging

# スクリプト読み込みは必須
load-scripts=yes

# その他の設定はそのまま
```

**input.conf**:
```ini
# 左ボタンをmpvの標準処理から除外
MBTN_LEFT       ignore

# ダブルクリックでフルスクリーン
MBTN_LEFT_DBL   cycle fullscreen
```

---

### ステップ3: 使用方法を理解する

**mpv.netのウィンドウドラッグ仕様**:

```
┌─────────────────────────────────┐
│ デッドゾーン（上10%）           │  ← ここではウィンドウドラッグされない
├─────────────────────────────────┤
│  デッド │                │ デッド│
│  ゾーン│   画面中央     │ ゾーン│  ← 中央はウィンドウドラッグされる
│ （左10%│                │右10%）│
├─────────────────────────────────┤
│ デッドゾーン（下22%）           │  ← ここではウィンドウドラッグされない
└─────────────────────────────────┘
```

**✅ 推奨操作エリア**: 
- **画面端（デッドゾーン）でマウスドラッグ**
- → ウィンドウは動かない
- → mpv-gesturesがシークを処理

**❌ 避けるべきエリア**:
- 画面中央でのマウスドラッグ
- → ウィンドウが動いてしまう
- → スクラブ機能と競合

---

## 🎮 mpv-gesturesの使い方

### 基本操作

| 操作エリア | マウスドラッグ方向 | 機能 |
|-----------|------------------|------|
| **画面端** | ← → 水平 | **動画をシーク（スクラブ）** |
| 画面左半分 | ↑ ↓ 垂直 | 再生速度を変更 |
| 画面右半分 | ↑ ↓ 垂直 | 音量を変更 |

### 実際の操作例

```
✅ 正しい使い方:
1. 動画再生中
2. マウスを画面下部（下22%のエリア）に移動
3. 左クリック押したまま左右にドラッグ
4. → 動画がシークされる（ウィンドウは動かない）

❌ 間違った使い方:
1. 動画再生中
2. マウスを画面中央に置く
3. 左クリック押したまま左右にドラッグ
4. → ウィンドウが動いてしまう
```

---

## 📊 動作確認

### 1. エラーメッセージの確認

**mpv.netを起動** → `` ` ``キーでコンソールを開く

**期待される表示**:
```
✅ [info] Loading lua script: gestures.lua
```

**エラーが無いこと**:
```
❌ [gestures] script-opts/gestures.conf:3 unknown key...
   → gestures.confを削除していればこのエラーは出ない
```

### 2. スクラブ機能のテスト

**テスト手順**:
1. 動画を再生
2. **画面下部（シークバー付近）**にマウスを移動
3. 左クリック押したまま左右にドラッグ
4. → 動画がスクラブされればOK！

---

## 🔧 さらなる改善案

### オプション1: OSCの無効化

画面中央でもスクラブできるようにするには、OSC（On-Screen Controller）を無効化：

```ini
# mpv.confに追加
osc=no
```

**効果**:
- OSCメニューが消える
- mpv.netがデッドゾーンを設定しなくなる可能性
- **ただし、未検証 - 効果がない可能性もあり**

### オプション2: mpv本家（コマンドライン版）への移行

**完璧なスクラブ機能を求めるなら、mpv本家を使用**:

**メリット**:
- ✅ `--no-window-dragging`が正常に機能
- ✅ pointer-event.luaやmpv-gesturesが完全動作
- ✅ 画面全体でスクラブ可能
- ✅ Keyframe MP 2と同等の操作感

**デメリット**:
- ❌ GUIが無い（コマンドライン操作）
- ❌ mpv.netの便利機能が使えない

**mpv本家のダウンロード**:
- Windows: https://mpv.io/installation/
- sourceforge: https://sourceforge.net/projects/mpv-player-windows/

**使い方**:
```bash
# mpv.exeを起動
mpv.exe 動画ファイル

# またはドラッグ&ドロップ
```

---

## 🆚 mpv.net vs mpv本家 比較

| 項目 | mpv.net | mpv本家 |
|------|---------|---------|
| GUI | ✅ あり | ❌ 無し |
| 設定エディタ | ✅ あり | ❌ テキスト編集のみ |
| `no-window-dragging` | ❌ 効かない | ✅ 効く |
| マウススクラブ | 🔺 画面端のみ | ✅ 画面全体 |
| 多重起動 | ✅ 簡単 | ✅ 可能 |
| アニメ制作向け | 🔺 やや不便 | ✅ 完璧 |

---

## 💡 最終推奨

### パターン1: mpv.netを使い続ける場合

```
✅ すること:
1. gestures.confを削除
2. 画面端（特に下22%）でマウス操作
3. 画面中央での操作は避ける

✅ メリット:
- GUIで設定が簡単
- mpv.netの便利機能が使える

❌ デメリット:
- 画面中央ではスクラブできない
- Keyframe MP 2より操作性が劣る
```

### パターン2: mpv本家に移行する場合

```
✅ すること:
1. mpv本家（mpv.exe）をダウンロード
2. 既存の設定ファイル（mpv.conf, input.conf）をコピー
3. `no-window-dragging`が自動的に有効化
4. mpv-gesturesが画面全体で動作

✅ メリット:
- Keyframe MP 2と同等の操作感
- 画面全体でスクラブ可能
- 完璧なカスタマイズ性

❌ デメリット:
- GUIが無い
- コマンドライン操作に慣れる必要
```

---

## 📝 設定ファイル（最終版）

### mpv.conf

```ini
# 基本設定
gpu-api=d3d11
profile=fast
priority=high
load-scripts=yes

# キャッシュ設定
cache=yes
demuxer-readahead-secs=120
demuxer-max-bytes=4096MiB
demuxer-max-back-bytes=4096MiB
demuxer-cache-wait=yes

# シーク設定
hr-seek=yes
hr-seek-framedrop=no
seekbarkeyframes=no

# 軽量化
interpolation=no
scale=bilinear
dscale=bilinear
vf=

# ウィンドウドラッグ（mpv.netでは効果なし）
no-window-dragging

# OSD設定
osd-status-msg=Frame: ${estimated-frame-number} / ${estimated-frame-count} (FPS: ${container-fps})
osd-level=1
osd-duration=2000
osd-font-size=32

# その他
loop-file=no
keep-open=yes
ontop=no

# デバッグ用（動作確認後はコメントアウト推奨）
# msg-level=all=v
```

### input.conf

```ini
# フレーム単位操作
RIGHT           frame-step
.               frame-step
LEFT            frame-back-step
,               frame-back-step

# 再生コントロール
SPACE           cycle pause
R               cycle play-direction

# シーク操作
Shift+RIGHT     seek 5 exact
Shift+LEFT      seek -5 exact
UP              seek 30
DOWN            seek -30
Ctrl+RIGHT      seek 1 exact
Ctrl+LEFT       seek -1 exact

# 再生速度
]               add speed 0.1
[               add speed -0.1
}               multiply speed 2.0
{               multiply speed 0.5
BACKSPACE       set speed 1.0
1               set speed 0.25
2               set speed 0.5
3               set speed 1.0
4               set speed 1.5
5               set speed 2.0

# ループ
L               cycle loop-file
l               ab-loop

# 音量
0               add volume 2
9               add volume -2
m               cycle mute

# その他
f               cycle fullscreen
ENTER           cycle fullscreen
q               quit
ESC             quit

# マウスボタン（mpv-gestures用）
MBTN_LEFT       ignore
MBTN_LEFT_DBL   cycle fullscreen
```

---

## 🎉 まとめ

**現実的な解決策**:

1. **mpv.netを使い続ける**
   - gestures.confを削除
   - 画面端でマウス操作
   - 画面中央は避ける
   - **妥協が必要**

2. **mpv本家に移行**
   - 完璧なスクラブ機能
   - Keyframe MP 2と同等
   - GUIは無し
   - **理想的だがCLI操作**

**あなたの選択**:
- GUIの利便性 → mpv.net（画面端でスクラブ）
- 完璧なスクラブ → mpv本家（CLI）

どちらを選択されますか？それに応じて、さらに詳しいセットアップをサポートします！