mpv.netでウィンドウドラッグを完全に無効化し、全画面でシークできるようにするための具体的な改修方法を説明します。

## 現在の実装状況

まず、現在の実装を理解する必要があります：

### ウィンドウドラッグの実装箇所

ウィンドウドラッグ機能は`MainForm.cs`の`OnMouseMove`メソッドで実装されています。 [1](#0-0) 

このコードでは以下の条件が全て満たされた場合にウィンドウドラッグが有効になります：
- マウス位置がクリック位置から移動している
- `WindowState == FormWindowState.Normal`（通常ウィンドウモード）
- 左マウスボタンが押されている
- `!IsMouseInOsc()`（OSCエリア外）
- `Player.GetPropertyBool("window-dragging")`が`true`

### シーク機能の実装箇所

マウス位置はmpvに送信され、mpvのOSC（On-Screen Controller）がシーク処理を行います。これは`WndProc`メソッドの`WM_MOUSEMOVE`ケースで処理されています。 [2](#0-1) 

### OSCデッドゾーンの定義

`IsMouseInOsc()`メソッドは、ウィンドウの端付近にデッドゾーンを定義しています。 [3](#0-2) 

## 改修方法

### 方法1：OnMouseMoveメソッドの改修（推奨）

**最も確実な方法**は、`OnMouseMove`メソッド内のウィンドウドラッグ処理を完全に削除またはコメントアウトすることです。 [4](#0-3) 

この10行のコード（条件チェックとウィンドウドラッグ処理）を削除またはコメントアウトしてください。こうすることで：
- ウィンドウドラッグが完全に無効化されます
- マウス位置は引き続きmpvに送信されるため、シーク機能は正常に動作します

### 方法2：設定ファイルでの無効化

コードを変更せずに、設定ファイルで`window-dragging`プロパティを`no`に設定する方法もあります。ただし、これはmpv.netが起動時にこのプロパティを読み込む実装になっている場合のみ有効です。

## 重要な注意点

1. **全画面モードでは既にウィンドウドラッグが無効**：`WindowState == FormWindowState.Normal`の条件により、全画面モード（`FormWindowState.Maximized`）では元々ウィンドウドラッグは動作しません。 [5](#0-4) 

2. **シーク機能は既に全画面で動作**：マウス位置は`IsMouseInOsc()`チェックに関係なく常にmpvに送信されるため、全画面モードでもシーク機能は画面全体で動作します。 [6](#0-5) 

3. **IsMouseInOsc()はウィンドウドラッグにのみ影響**：このメソッドはウィンドウドラッグを防ぐためのものであり、シーク機能には影響しません。

## Notes

- 全画面モードでは`FormWindowState.Maximized`と`FormBorderStyle.None`の組み合わせが使用されます [7](#0-6) 
- 全画面への切り替えは`CycleFullscreen`メソッドで処理されます [8](#0-7) 
- 左ダブルクリックのイベントも別途処理されています [9](#0-8) 

ウィンドウドラッグを完全に無効化するには、方法1で示した`OnMouseMove`メソッド内の該当コードを削除することが最も確実で、副作用のない方法です。

### Citations

**File:** src/MpvNet.Windows/WinForms/MainForm.cs (L265-265)
```csharp
    bool IsFullscreen => WindowState == FormWindowState.Maximized && FormBorderStyle == FormBorderStyle.None;
```

**File:** src/MpvNet.Windows/WinForms/MainForm.cs (L269-281)
```csharp
    bool IsMouseInOsc()
    {
        Point pos = PointToClient(MousePosition);
        float top = 0;

        if (!Player.Border)
            top = ClientSize.Height * 0.1f;

        return pos.X < ClientSize.Width * 0.1 ||
               pos.X > ClientSize.Width * 0.9 ||
               pos.Y < top ||
               pos.Y > ClientSize.Height * 0.78;
    }
```

**File:** src/MpvNet.Windows/WinForms/MainForm.cs (L762-803)
```csharp
    public void CycleFullscreen(bool enabled)
    {
        _lastCycleFullscreen = Environment.TickCount;
        Player.Fullscreen = enabled;

        if (enabled)
        {
            if (WindowState != FormWindowState.Maximized || FormBorderStyle != FormBorderStyle.None)
            {
                FormBorderStyle = FormBorderStyle.None;
                WindowState = FormWindowState.Maximized;

                if (_wasMaximized)
                {
                    Rectangle bounds = Screen.FromControl(this).Bounds;
                    uint SWP_SHOWWINDOW = 0x0040;
                    IntPtr HWND_TOP= IntPtr.Zero;
                    SetWindowPos(Handle, HWND_TOP, bounds.X, bounds.Y, bounds.Width, bounds.Height, SWP_SHOWWINDOW);
                }
            }
        }
        else
        {
            if (WindowState == FormWindowState.Maximized && FormBorderStyle == FormBorderStyle.None)
            {
                if (_wasMaximized)
                    WindowState = FormWindowState.Maximized;
                else
                {
                    WindowState = FormWindowState.Normal;

                    if (!Player.WasInitialSizeSet)
                        SetFormPosAndSize();
                }

                FormBorderStyle = Player.Border ? FormBorderStyle.Sizable : FormBorderStyle.None;

                if (!KeepSize())
                    SetFormPosAndSize();
            }
        }
    }
```

**File:** src/MpvNet.Windows/WinForms/MainForm.cs (L1065-1074)
```csharp
            case 0x200: // WM_MOUSEMOVE
                if (Environment.TickCount - _lastCycleFullscreen > 500)
                {
                    Point pos = PointToClient(Cursor.Position);
                    Player.Command($"mouse {pos.X} {pos.Y}");
                }

                if (IsCursorPosDifferent(_lastCursorPosition))
                    ShowCursor();
                break;
```

**File:** src/MpvNet.Windows/WinForms/MainForm.cs (L1075-1080)
```csharp
            case 0x203: // WM_LBUTTONDBLCLK
                {
                    Point pos = PointToClient(Cursor.Position);
                    Player.Command($"mouse {pos.X} {pos.Y} 0 double");
                }
                break;
```

**File:** src/MpvNet.Windows/WinForms/MainForm.cs (L1443-1457)
```csharp
    protected override void OnMouseMove(MouseEventArgs e)
    {
        base.OnMouseMove(e);

        if (IsCursorPosDifferent(_mouseDownLocation) &&
            WindowState == FormWindowState.Normal &&
            e.Button == MouseButtons.Left && !IsMouseInOsc() &&
            Player.GetPropertyBool("window-dragging"))
        {
            var HTCAPTION = new IntPtr(2);
            var WM_NCLBUTTONDOWN = 0xA1;
            ReleaseCapture();
            PostMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, IntPtr.Zero);
        }
    }
```
## mpv.netのウィンドウドラッグ無効化と全画面シーク機能の実装
mpv.netのウィンドウドラッグ機能と全画面シーク機能の実装をトレース。主要な改修ポイントは[1b]の条件チェックと[2c]のマウス位置送信処理。ドラッグ無効化は[1c]のWindows API呼び出しを削除することで実現可能。
### 1. ウィンドウドラッグ機能の実装フロー
MainForm.csでのウィンドウドラッグ処理の制御フロー
### 1a. OnMouseMoveイベントハンドラ (`MainForm.cs:1443`)
マウス移動イベントの開始点
```text
protected override void OnMouseMove(MouseEventArgs e)
```
### 1b. ウィンドウドラッグの条件チェック (`MainForm.cs:1447`)
5つの条件がすべて満たされた場合にドラッグを開始
```text
if (IsCursorPosDifferent(_mouseDownLocation) &&
            WindowState == FormWindowState.Normal &&
            e.Button == MouseButtons.Left && !IsMouseInOsc() &&
            Player.GetPropertyBool("window-dragging"))
```
### 1c. Windows APIによるウィンドウドラッグ実行 (`MainForm.cs:1452`)
Windowsメッセージを送信してウィンドウの移動を開始
```text
var HTCAPTION = new IntPtr(2);
            var WM_NCLBUTTONDOWN = 0xA1;
            ReleaseCapture();
            PostMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, IntPtr.Zero);
```
### 2. 全画面シーク機能の実装フロー
マウス位置をmpvに送信してシークを実行する処理
### 2a. WndProcでのマウス移動検知 (`MainForm.cs:1065`)
WindowsメッセージWM_MOUSEMOVEを処理
```text
case 0x200: // WM_MOUSEMOVE
```
### 2b. 全画面切り替え後の待機処理 (`MainForm.cs:1066`)
全画面モード切り替え後500ms待機してから処理を開始
```text
if (Environment.TickCount - _lastCycleFullscreen > 500)
```
### 2c. マウス位置をmpvに送信 (`MainForm.cs:1068`)
現在のマウス座標をmpvにコマンドとして送信
```text
Point pos = PointToClient(Cursor.Position);
                    Player.Command($"mouse {pos.X} {pos.Y}");
```
### 3. OSCデッドゾーンの判定ロジック
ウィンドウドラッグを無効化する領域の判定処理
### 3a. OSC領域判定メソッド (`MainForm.cs:269`)
マウスがOSC（On-Screen Controller）領域内にあるかを判定
```text
bool IsMouseInOsc()
```
### 3b. 境界領域の計算 (`MainForm.cs:271`)
ボーダーレス時は上部10%をデッドゾーンとして設定
```text
Point pos = PointToClient(MousePosition);
        float top = 0;

        if (!Player.Border)
            top = ClientSize.Height * 0.1f;
```
### 3c. デッドゾーンの境界判定 (`MainForm.cs:277`)
左右10%と下部22%をドラッグ無効領域として判定
```text
return pos.X < ClientSize.Width * 0.1 ||
               pos.X > ClientSize.Width * 0.9 ||
               pos.Y < top ||
               pos.Y > ClientSize.Height * 0.78;
```
### 4. 全画面モードの切り替え処理
全画面モードと通常モードの切り替え実装
### 4a. 全画面切り替えメソッド (`MainForm.cs:762`)
全画面モードの有効/無効を切り替える
```text
public void CycleFullscreen(bool enabled)
```
### 4b. 全画面モードへの移行 (`MainForm.cs:767`)
ボーダーレスと最大化を組み合わせて全画面を実現
```text
if (enabled)
        {
            if (WindowState != FormWindowState.Maximized || FormBorderStyle != FormBorderStyle.None)
            {
                FormBorderStyle = FormBorderStyle.None;
                WindowState = FormWindowState.Maximized;
```
### 4c. 全画面状態の判定 (`MainForm.cs:265`)
最大化＋ボーダーレスの組み合わせで全画面と判定
```text
bool IsFullscreen => WindowState == FormWindowState.Maximized && FormBorderStyle == FormBorderStyle.None;
```