# pointer-event

### mpv向けマウス/タッチ入力イベント検出

シングルクリック、ダブルクリック、ロングクリック、ドラッグ操作を低遅延で検出します。  
各イベントは排他的に検出されるため、例えばダブルクリック時にシングルクリックイベントが検出されることはありません。

ドラッグ操作では開始イベントと終了イベントが発生し、座標変化を含むドラッグイベントも発行されるため、ジェスチャー検出に利用可能。

`--no-window-dragging` オプションを使用しない限り、ウィンドウドラッグがジェスチャー検出を妨げる点に注意。
詳細は `ignore_left_single_long_while_window_dragging` オプションを参照。

## インストール

1. [pointer-event.lua](https://github.com/christoph-heinrich/mpv-pointer-event/raw/master/pointer-event.lua) を [scripts ディレクトリ](https://mpv.io/manual/stable/#script-location) に保存します。
2. `pointer-event.conf`で監視したいイベントを設定してください。

## 使用方法

イベントを検知すると、script-optsディレクトリ（scriptsディレクトリの隣、存在しない場合は作成）内の`pointer-event.conf`から対応する[コマンド](https://mpv.io/manual/master/#list-of-input-commands)が実行されます。

コマンド設定は `<ボタン>_<イベントタイプ>=コマンド` の形式に従います。

利用可能なボタンは
```
left
right
mid
```

タッチ入力は `left` として認識されます。
各ボタンは以下のイベントタイプを監視できます
```
single
double
long
drag_start
drag_end
drag
```

`drag` はポインタ位置の変化 `dx dy` をコマンドに追加します。

さらに以下の設定項目があります：
```
long_click_time
double_click_time
drag_distance
margin_left
margin_right
margin_top
margin_bottom
ignore_left_single_long_while_window_dragging
```

これらはすべて妥当なデフォルト値を持ち、`double_click_time`は[input-doubleclick-time](https://mpv.io/manual/master/#options-input-doubleclick-time)に準拠します。時間はミリ秒単位で解釈されます。  
`drag_distance`は、クリック/タッチではなくドラッグとして認識されるために必要なドラッグ距離を決定します。
`margin_*`オプションは、OSDとの操作を容易にしつつイベントを発生させないためのものです。

ウィンドウドラッグを有効にしたままジェスチャー検出も必要とする場合があります。`ignore_left_single_long_while_window_dragging`は、ウィンドウドラッグ中にシングルクリックやロングクリックイベントが発生するのを防ぐために存在します。これらのイベントはフルスクリーンモードや最大化モードでは引き続き機能します。 
なお、マウス/指を動かさなくても、ボタン押下時点でウィンドウドラッグは開始される点に留意してください。

mpvsの組み込みキーバインドや`input.conf`内のキー設定との競合に注意してください。

## 例

[touch-gestures](https://github.com/christoph-heinrich/mpv-touch-gestures) は、この機能で実現可能な操作例です。