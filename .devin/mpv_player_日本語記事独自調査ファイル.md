
input.conf の設定例

# メモ [relative|absolute|absolute-percent|relative-percent|exact|keyframes]

# マウス設定
MOUSE_BTN0_DBL  cycle fullscreen        # ダブルクリックでフルスクリーン
MOUSE_BTN1    cycle mute                # ホイールクリックでミュート
MOUSE_BTN2    cycle pause               # 右クリックで一時停止
MOUSE_BTN3 seek -2 exact                # ホイール上で戻る
MOUSE_BTN4 seek  2 exact                # ホイール下で進む

# 再生/一時停止
SPACE  cycle pause ; show-text "${?pause==no:Play}${?pause==yes:Pause}"
p      cycle pause ; show-text "${?pause==no:Play}${?pause==yes:Pause}"

# 区間リピート 始め, 終わり, クリア
l   ab-loop

_ ignore           #menu: -
Ctrl+l af toggle "@loudnorm"  #menu: My Settings > Loudness on/off

mpv.conf

input-default-bindings=no   # デフォルトのキーバインドを無効
vo=opengl-hq        # OpenGL-HQ
hwdec=auto          #ハードウェアデコードを有効
correct-pts=yes     # fpsを動画に合わせる
cache=131072        # キャッシュ設定[KiB]

# On Screen Displayの設定
osd-bar=no                  # OSDバーを非表示
osd-scale-by-window=no      # ウィンドウサイズを変えても文字の大きさを変えない

# フォント・表示設定
osd-font="Noto Sans CJK JP Kai Regular"
osd-font-size=32
osd-duration=3000
osd-border-size=1

# 字幕は非表示がデフォ（切り換えれるようにしておくと親切）
sub-visibility=no

# 再生はOpenGL-HQでハードウェアレンダリング
vo=opengl-hq
hwdec=auto

# My settings ラウドネス調整 # Editor とある行の前に追加
af = @loudnorm:lavfi=[loudnorm=I=-16:TP=-1.5:LRA=11]

OSCの設定を個別で弄る場合。この設定は ~/.config/mpv/lua-settings/osc.conf に書く。

layout=bottombar
vidscale=no
scalewindowed=1.75
scalefullscreen=1.75
boxalpha=160
hidetimeout=2000

mpv には、弱いまたは古いビデオカードを搭載したコンピュータでもうまく動作する、優れた万能のデフォルト設定が付属しています。ただし、より新しいビデオカードを搭載したコンピュータを使用している場合は、mpv のビデオ品質を向上させるために多くの設定を行う必要があります。(ビデオカードの能力によって制限されます) これを行うには、いくつかの設定ファイルを作成するだけで済みます (デフォルトでは設定ファイルは存在しないため)

ノート: 設定ファイルは、システム全体では /etc/mpv から読み取られ、ユーザーごとには ~/.config/mpv から読み取られます (環境変数 XDG_CONFIG_HOME が設定されている場合を除く) ユーザーごとの設定はシステム全体の設定をオーバーライドし、すべてコマンドラインによってオーバーライドされます。試行錯誤が必要になる場合があるため、ユーザー固有の設定をお勧めします。

一般設定
次の設定を ~/.config/mpv/mpv.conf に追加します。

フォントを変更する:
sub-font="fontName"

高度な設定
これにより、vo=gpu をビデオ出力として使用するときに高品質の OpenGL オプションが読み込まれます(デフォルト)。ほとんどのユーザーは問題なくこれらを実行できますが、実行できない少数のユーザーに問題が発生しないように、デフォルトでは有効になっていません。

profile=gpu-hq

gpu-hq プロファイルは、中程度の品質と速度を実現するために、デフォルトで spline36 スケーリングフィルターに設定されています。最高品質のビデオ出力を得るには、ハードウェアで実行できる場合は ewa_lanczossharp を使用する必要があるとマニュアルに記載されています。

profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp

これらの最後の3つのオプションは、もう少し複雑です。最初のオプションでは、オーディオとビデオが同期しなくなった場合、ビデオフレームをドロップする代わりに、オーディオをリサンプリングします(オーディオピッチのわずかな変化は、ドロップされたフレームよりも目立たないことがよくあります)。 mpv wiki には、 DisplaySynchronization というタイトルの詳細な記事があります。残りの2つは、フレームの表示方法を変更することで、基本的にディスプレイ上で動きがスムーズに見えるようにし、ソースフレームレートがディスプレイのリフレッシュレートとより良く調和するようにします(実際にビデオを60 fpsに変換するSVPの手法と混同しないでください)。 mpv wiki には、 Interpolation というタイトルの詳細な記事がありますが、一般に スムーズモーション としても知られています。

profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp
video-sync=display-resample
interpolation
tscale=oversample

ノート: NVIDIA Optimus が使用されている場合、行 video-sync=display-resample により、ビデオが高速化される可能性があります。

ですが、結論：僕くんの用途なら「`display-sync`」は"使わない"

結論として、僕くんのアニメ制作（作画チェック）環境で推奨する同期設定は、最新（っぽい）機能の`display-sync`系**ではなく**、あえて昔ながらの\*\*`video-sync=audio`\*\*（または未指定、デフォルトが`audio`の場合が多い）だよ。

```conf
# コーディングパートナー.md から抜粋
video-sync=audio                  # 音声同期モード
```

-----

### なんで「`display-sync`」を使わないの？

添付ファイル（`Display synchronization.md`）を読むと、「`display-sync`」こそが最強で、フレーム落ちゼロの"完璧な再生"を実現する技術だって書いてある。
**じゃあ、なんでそれを使わないか？**
答えは、「**僕くんのワークフローと相性が悪いから**」なんだ。

#### 1\. `display-sync`は「長回し」の再生（Playback）用

`display-sync`が解決しようとしてるメインの問題は、「23.976Hzの映画」を「60HzのPCモニター」で再生した時に起こる、\*\*ビミョーなカクつき（スタッター）\*\*なんだよね。

これを解決するために、`display-sync`はモニターの更新タイミング（vsync）を基準にして、映像がカクつかないように、**なんと「音声」の速度をビミョーに（±1%とか）イジって調整する**っていう、かなりアクロバティックなこと（`display-resample`モード）をやってる。

#### 2\. アニメ検査（Scrubbing）には向かない

でも、僕くんのやりたいことは「2時間の映画を滑らかに観る」ことじゃなくて、「**5秒のGIFやMP4を、コマ送り（`.`）したり、逆再生（`R`）したり、シークバーでグリグリする**」ことだよね。

`display-sync`には、このワークフローにとって致命的な弱点があるんだ。

  * **不安定なファイルで自動的にオフになる**
    `display-sync`は、タイムスタンプが変なファイルや、**VFR（可変フレームレート）のコンテンツ**だと、**自動的に無効になっちゃう**。
  * **GIFはVFR扱いが多い**
    僕くんが使う`mpv-keyframe-guide.md`（ファイル3）にも書いてある通り、\*\*GIF形式は「フレーム精度が不正確」（つまりVFR）\*\*なものが多い。

つまり、せっかく`display-sync`をオンにしても、いざ作画チェックでGIFを読み込んだ瞬間に「あ、このファイルVFRだ。はい`display-sync`オフね」って勝手に無効化されたら、まったく意味がないし、むしろ動作が不安定になる原因になっちゃう。

-----

### アニメ検査の「フレーム最重要視」設定

僕くんのワークフロー（アニメ検査）における「フレーム最重要視」は、`display-sync`（再生中の滑らかさ）じゃなくて、\*\*`hr-seek`（シークの正確さ）\*\*で実現すべきなんだ。

推奨する設定の組み合わせは、まさに「`コーディングパートナー.md`」で提案した設定そのものだよ。

1.  **`video-sync=audio`**

      * **役割:** 同期のボスを「音声（Audio Clock）」に任せる。
      * **理由:** `display-sync`みたいに複雑なこと（音声の速度を変えるとか）をしない、一番シンプルで予測しやすいモードだから。ポーズ、コマ送り、シークみたいな「再生が止まってる」状態での操作に一番強い。

2.  **`hr-seek=yes`**

      * **役割:** 高精度シーク。
      * **理由:** これこそが\*\*「フレーム最重要視」の心臓部\*\*。`hr-seek`をオンにしないと、コマ送り（`.`）やシークバーのドラッグが、キーフレーム（映像の区切り）単位になっちゃって、正確な1フレーム移動ができない。`Keyframe MP 2`の操作感を再現するのに必須。

3.  **巨大なキャッシュ (`demuxer-max-bytes=4096MiB`とか)**

      * **役割:** ファイルを丸ごとメモリにぶち込む。
      * **理由:** `hr-seek`で正確な位置に飛ぼうとしても、データがPCのストレージ（SSDとか）にあると、読み込みで一瞬待たされる。特に「1コマ戻し（`,`）」はファイルの前方からデータを読み直すから超遅い。
      * でも、ファイルを丸ごとRAM（メモリ）にキャッシュしちゃえば、ストレージへのアクセスがゼロになる。`video-sync=audio`と`hr-seek=yes`と組み合わせることで、\*\*「押した瞬間に、正確なフレームに、ゼロ遅延で飛ぶ」\*\*っていう、理想の検査環境が完成するんだ。

### まとめ

映画鑑賞なら`display-sync`は神。でも、VFRが混じる短尺ファイルを、ポーズ多めでコマ送り・逆再生する僕くんのアニメ検査なら、**`video-sync=audio` + `hr-seek=yes` + 巨大キャッシュ** が最強の組み合わせってこと。

これ以外にもできることはたくさんありますが、物事はより複雑になり、より強力なビデオカードが必要になります。簡単な概要として、画像でトレーニングされたディープニューラルネットワークを実際に使用するものを含む、エキゾチックなスケーリングとシャープニングの手法を実行する特別なシェーダーをロードすることができます(実世界とアニメーションコンテンツの両方)。これについて詳しくは、 mpv wiki、特に user-shaders のセクション をご覧ください。（あんまりシェーダー関連はどうでもいい。とにかく軽量化する上でオミットするための情報が必要。）

カスタムプロファイル
mpv.conf では、基本的に次のような オプションのグループ である プロファイル を作成できます。

ファイルを書き直すことなく、異なる構成をすばやく切り替えることができます。
特別なコンテンツ用の特別なプロファイルを作成します。
ネスト プロファイル。これにより、単純なプロファイルからより複雑な プロファイル を作成できます。
プロファイルの作成は簡単です。 mpv.conf の上部の領域はトップレベルと呼ばれ、そこに書き込んだオプションはすべて、mpv が開始されると有効になります。ただし、名前を角かっこで囲んでプロファイルを定義すると、その下に書き込むすべてのオプション(新しいプロファイルを定義するまで)はそのプロファイルの一部と見なされます。 mpv.conf の例を次に示します。

profile=myprofile2            #トップレベルエリア、myprofile2をロード
ontop=yes                     #最前面に

[myprofile1]                  #シンプルなプロファイル、トップレベルの領域はここで終わります
profile-desc="a profile"      #プロファイルのオプションの説明
fs=yes                        #フルスクリーンで開始

[myprofile2]                  #別の簡単なプロファイル
profile=gpu-hq                #mpv に付属する組み込みプロファイル
log-file=~~/log               #ログファイルを書き込む場所を設定します。~~/ translates は ~/.config/mpv に変換されます
トップレベルエリア内には2つの線しかなく、その下に2つの別々のプロファイルが定義されています。 mpv が開始すると、最初の行が表示され、 myprofile2 にオプションが読み込まれます(つまり、gpu-hq と log-file=~~/log)最後に ontop=yes をロードし、起動を終了します。 myprofile1 は最上位領域で呼び出されないため、ロードされないことに注意してください。

または、次のコマンドラインから mpv を呼び出すこともできます。

$ mpv --profile=myprofile1 video.mkv
また、myprofile1 のオプションを除くすべてのオプションを無視します。

自動プロファイル
ファイルの拡張子または使用されているプロトコルに基づいて、特定の種類のプロファイルが自動的に読み込ませる。

これらのプロファイルは、一致するファイル拡張子を持つすべてのファイルに対してそれぞれにロードされます (すべての .mkv および .gif ファイルに対して):

[extension.mkv]
keep-open
volume-max=150

[extension.gif]
osc=no
loop-file
このプロファイルは、http または https ストリームが再生されるたびに自動的に読み込まれます

(例: mpv nowikihttps://example.com/video.mp4/nowiki):

[protocol.https]
speed=2
keep-open

[protocol.http]
profile=protocol.https
mpv --list-protocols を実行して、mpv でサポートされているさまざまなプロトコルを確認します。

その他の設定ファイル
さらに、いくつかの設定ファイルとディレクトリを作成できます。その中には次のものがあります。

・~/.config/mpv/script-opts/osc.conf は、 On Screen Controller を管理します。
・Lua スクリプト用の ~/.config/mpv/scripts/script-name.lua。

For reference, this is a variation on @airport 's script which does "always OSC if only audio", and also sets it back to "auto" if you then load a video file (e.g. in a playlist).

Save this as audio-osc.lua at the scripts dir inside mpv config dir:

```
mp.register_event("file-loaded", function()
    local hasvid = mp.get_property_osd("video") ~= "no"
    mp.commandv("script-message", "osc-visibility", (hasvid and "auto" or "always"), "no-osd")
    -- remove the next line if you don't want to affect the osd-bar config
    mp.commandv("set", "options/osd-bar", (hasvid and "yes" or "no"))
end)
```

スクリプト
mpv にはプレイヤーの機能を拡張する 多種多様なスクリプト があります。そのために、 Lua と JavaScript の両方の内部バインディングがあります (最近追加されました) 。

スクリプトは通常、 ~/.config/mpv/scripts/ ディレクトリに配置してインストールします (最初に作成する必要があります) その後、 mpv の起動時に自動的にロードされます mpv の場合一部のスクリプトには独自のインストール手順と設定手順が付属していますので、必ず確認してください。また、古いスクリプト、壊れたスクリプト、メンテナンスされていないスクリプトもあります。

JavaScript
JavaScript (ES5 via MuJS ) は、2014から mpv スクリプト言語としてサポートされています。現在利用できるのは a some scripts のみですが、 documentation exists は独自のものを作りたい人のためのものです。

まず、 mpv scripts ディレクトリに、拡張子 .js を持つスクリプトをドロップします。例えば:

~/.config/mpv/scripts/fullscreen-off-on-pause.js

function onPauseChange (prop, enabled) {
    if (enabled) {
        mp.set_property('fullscreen', 'no')
    }
}

mp.observe_property('pause', 'bool', onPauseChange)

require を使用して CommonJS モジュールをロードする方法などの詳細については、 documentation を参照してください。

JavaScript のサポートは mpv パッケージだけでなく、 mpv-fullAUR や mpv-full-gitAUR などの AUR パッケージでも利用できます。

Lua
mpv 用の興味深い Lua スクリプトがたくさんあります。独自のスクリプトを作成したい場合は、 こちら を参照してください。

mpv-ytdlAutoFormat
mpv-ytdlautoformat は、 Youtube や Twitch やあなたが望むドメインの ytdl-format を 480p やあなたが望む品質に自動変更する Lua スクリプトです。

mpv-stats
mpv-stats (または単に stats) は Lua スクリプトで、現在の状態を示す多くのライブ統計を出力します。これは、ハードウェアが構成に対応できることを確認したり、異なる構成を比較したりする場合に非常に便利です。バージョン v0.28.0 以降、スクリプトは mpv に組み込まれており、 i キーまたは I キー (デフォルト) を使用してオン/オフを切り替えることができます。

mpv-webm
mpv-webm (または単に webm) は、ビデオを見ながら WebM ファイルを作成できる非常に使いやすい Lua スクリプトです。いくつかの機能が含まれており、追加の依存関係はありません (完全に mpv に依存します)

ytdl-preload
ytdl-preload は、プレイリスト内の次の ytdl リンクを preload する Lua スクリプトです。

C
mpv-mpris
C プラグイン mpv-mpris を使用すると、プロトコルを介して他のアプリケーションを MPRIS と統合できます。たとえば、mpv-mpris がインストールされている場合、 kdeconnect は電話がかかってきたときにビデオ再生を自動的に一時停止できます。別の例として、 bluetooth オーディオデバイスのボタン (play\pauseなど) があります。

mpv-mprisAUR をインストールし、 Pacman によって表示されるインストール後の手順に従います。

ヒントとテクニック
ピクチャー
ハードウェアビデオアクセラレーション
参照 ハードウェアビデオアクセラレーション

--hwdec=API オプションを使用すると、ハードウェア アクセラレーションによるビデオ デコードを利用できます。サポートされているすべての API とその他の必要なオプションのリストについては、mpv(1) § hwdec を参照してください。

永続的にするには (たとえば、デスクトップ環境からビデオを再生する場合)、設定ファイルに追加します。

~/.config/mpv/mpv.conf
hwdec=auto
ビデオフィルタで CPU 処理を許可するには、*-copy API を選択します。

ハードウェアアクセラレーションのトラブルシューティングを行うには、ログレベルの調整が必要になる場合があります。たとえば、--msg-level=vd=v,vo=v,vo/gpu/vaapi-egl=trace は次を有効にします。

ビデオデコーダ (vd) とビデオ出力 (vo) モジュールからの Verbose メッセージです。
ビデオデコードを担当するモジュールについて、さらに詳細なtraceメッセージを表示します。ここでは、ログレベルを調整せずに mpv を一度実行した後、興味のあるモジュールは経験的に vo/gpu/vaapi-egl であると判断されました。
縦横比をすばやく切り替える
Shift+a を使用して縦横比を切り替えることができます。

アスペクト比を無視する
--keepaspect=no を使うことでアスペクト比を無視できます。オプションを永続的にしたい場合、設定ファイルに keepaspect=no という行を追加してください。

ルートウィンドウに描画
--wid=0 を付けて mpv を実行してください。これによって mpv はウィンドウ ID が 0 のウィンドウに描画するようになります。

アプリケーション ウィンドウを常に表示する
コマンドラインから mpv を起動したときに、オーディオファイルでもアプリケーションウィンドウを表示するには、--force-window オプションを使用します。このオプションを永続的に使用するには、設定ファイルに force-window=yes という行を追加してください。

ビデオ出力を無効にする
コマンドラインからの起動時にビデオ出力を無効にするには、--vid=no オプション、またはその別名である --no-video を使用します。

ターミナルビデオ
--vo=tct "テキストコンソールで動作するカラー Unicode アートビデオ出力ドライバー"
--vo=caca "テキストコンソールで動作するカラーアスキーアートのビデオ出力ドライバ" libcaca のサポートは脆弱性のために Arch では無効になっています (FS#70962 を参照) が、問題は修正されたにも関わらずまだ元に戻されていません: mpv-cacaAUR をインストールしてください。
オーディオ
ボリュームが小さすぎる
設定ファイルに volume-max=value を設定して volume-max=600 など然るべき値にしてください。さらに (または)、af=acompressor でダイナミックレンジ圧縮を利用することもできます。

オーディオ出力を指定する
次のコマンドを実行して、使用可能なオーディオ出力デバイスのリストを取得します

$ mpv --audio-device=help
次に、~/.config/mpv/mpv.conf に1つ追加します。例えば:

audio-device=alsa/hdmi:CARD=NVidia,DEV=1
HD オーディオパススルー
TrueHD や DTS-MA などの HD オーディオコーデックを AV レシーバーにパススルーできるようにするには、次を ~/.config/mpv/mpv.conf に追加します。

audio-spdif=ac3,eac3,dts-hd,truehd
ボリューム標準化
ソースが異なれば音量が異なるか、一貫性がない可能性があるため、mpv ユーザーは自動音量標準化を設定する必要がある場合があります。例えば:

~/.config/mpv/input.conf
n cycle_values af loudnorm=I=-30 loudnorm=I=-15 anull
これはキー n をバインドして、オーディオフィルタ設定 (af) を指定された値で循環させます。

loudnorm=I=-30: I=-30の loudnorm 設定、ソフトボリューム、バックグラウンドミュージックに適している可能性があります
loudnorm=I=-15: より大きな音量、現在表示されているビデオには適している可能性があります
anull: オーディオフィルタを null にリセットします。つまり、オーディオフィルタを無効にします。
ノート: キーをバインドしても、デフォルトのオーディオフィルタは変更されません。デフォルトを変更するには、例えば af=loudnorm=I=-30 をメイン設定ファイルに追加します。
mpv の音声フィルタリングは、FFmpeg バックエンドによって提供されます。詳細については、Wikipedia:EBU R 128 および ffmpeg Loudnorm フィルター を参照してください。

さまざまなオプションについて言及しているアップストリームの問題 [3] および [4] も参照してください。

Lua スクリプトを使用して mpv を音楽プレーヤーとして改善する
このブログ投稿 では music.lua このスクリプトを使用して mpv を音楽プレーヤーとして改善する方法を紹介しています。

停止した位置からの自動レジューム再生
動画の現在の位置を保存して mpv を終了するデフォルトのキーは Shift+q です。このキーはキーバインドの設定ファイルに quit_watch_later を追加することで変更できます。

プレイヤーの終了時に自動的に現在の再生位置を保存したい場合、--save-position-on-quit フラグを付けて mpv を起動してください。オプションを永続化させるには、設定ファイルに save-position-on-quit という行を追加します。

プレイリストの位置を保存して次のファイルで一時停止
プレイリストは単にファイルのリストである可能性があります。mpv(1) を参照してください。 プレイリストを再生してその位置を記憶するには:

$ mpv --save-position-on-quit --pause --reset-on-next-file=pause --playlist=/path/to/playlist
オプション --pause を使用すると、mpv は一時停止状態で開始され、 --reset-on-next-file=pause は、次のファイルに切り替えるときに一時停止モードをリセットします。

トラブルシューティング
一般的なデバッグ
mpv の再生に問題がある場合 (またはフラットアウトが実行できない場合) は、最初に次の3つのことを行う必要があります。

  1.コマンドラインから mpv を実行します (-vフラグは冗長性を高めます) 。運が良ければ、そこに何が間違っているかを知らせるエラーメッセージが表示されます。$mpv -v video.mkv
  2.mpv のログファイルを出力します。ログファイルをふるいにかけるのは難しいかもしれませんが、何かが壊れている場合は、ログファイルを見ることができます。
    $ mpv -v --log-file=./log video.mkv
  3.設定なしで mpv を実行します。これがうまく動作するなら、問題は設定のどこかにあります $mpv--no-config video.mkv

mpv が実行されても正常に実行されない場合は、 mpv-stats スクリプトをインストールして、そのスクリプトの実行状況を確認することをお勧めします。

再生が途切れたりティアリングが発生する
OpenGL をサポートしているハードウェアを使っている場合 mpv はデフォルトで OpenGL ビデオ出力デバイスを使用します。Intel HD4XXX シリーズなどのカードで 4K ディスプレイに動画を映そうとすると、動画の再生が不安定になって一時的に止まってしまったり盛大にティアリングが発生することがあります。そのような問題が起こる場合、XV (XVideo) ビデオ出力デバイスを使うことで解決できるかもしれません:

~/.config/mpv/mpv.conf
profile=xv
ノート: これは X 上で最も互換性のある VO ですが、品質が低い可能性があり、OSD と字幕表示に問題があります。
また、(低性能なハードウェアで) 再生のパフォーマンスを改善するかわりに、動画の品質が著しく落ちるという問題もあります。

動画の再生性能を高めるオプションとして以下のようなものもあります:

~/.config/mpv/mpv.conf
vd-lavc-fast
vd-lavc-skiploopfilter=<skipvalue>
vd-lavc-skipframe=<skipvalue>
vd-lavc-framedrop=<skipvalue>
vd-lavc-threads=<threads>
mpv 0.35.0 以降、一部の古い Intel プロセッサでは、ダイレクトレンダリングをオフにしないとフレームがドロップします [5]:

~/.config/mpv/mpv.conf
vd-lavc-dr=no
ウィンドウコンポジタの問題
KWin や Mutter などのウィンドウコンポジタは、再生の滑らかさに問題を引き起こす可能性があります。このような場合は、x11-bypass-compositor=yes を設定して、ウィンドウモードでの再生時にウィンドウの合成も無効にすると便利です (合成機能がサポートしている場合) 。

KWin の合成とハードウェアデコードでは、 x11-bypass-compositor=no を設定して合成をフルスクリーンで有効にしておくこともできます。フルスクリーンから離れた後で合成を再有効にすると、しばらくの間、stutter が発生する可能性があります。

インストール
USE フラグ
デフォルトの USE 設定は以下のコア機能を提供します: CLI プレイヤー、Xorg サポート、音声と動画の再生、オンスクリーンディスプレイ (OSD) とオンスクリーンコントローラ (OSC)、そして Lua スクリプティングインターフェースです。

通常はハードウェア動画デコード機能も欲しいでしょう。mpv は VAAPI と VDPAU ハードウェアデコード API の両方を、それぞれ vaapi および vdpau USE フラグを介してサポートしています。システムで利用できる API を手動で有効にする必要があります。mpv はまた、nvenc USE フラグを介して NVDEC ハードウェアデコード API もサポートしています (プロプライエタリな nvidia-drivers が必要です)。

機能の完全な一覧については、下の USE フラグの一覧を参照してください。
+X	Add support for X11
+alsa	Add support for media-libs/alsa-lib (Advanced Linux Sound Architecture)
+cli	Enable the command-line player
+drm	Enable Kernel Mode Setting / Direct Rendering Manager based video outputs
+egl	Enable EGL (Embedded-System Graphics Library, interfacing between windowing system and OpenGL/GLES) support
+iconv	Enable support for the iconv character set conversion library
+libmpv	Enable the shared library and headers (used by frontends / plugins)
+lua	Enable Lua scripting, OSC (On Screen Controller) GUI, and net-misc/yt-dlp support
+uchardet	Enable subtitles charset discovery via app-i18n/uchardet
+vulkan	Add support for 3D graphics and computing via the Vulkan cross-platform API
aqua	Include support for the Mac OS X Aqua (Carbon/Cocoa) GUI
archive	Enable support for various archive formats via app-arch/libarchive
bluray	Enable playback of Blu-ray filesystems
cdda	Add Compact Disk Digital Audio (Standard Audio CD) support
coreaudio	Build the CoreAudio driver on Mac OS X systems
debug	Enable extra debug codepaths, like asserts and extra output. If you want to get meaningful backtraces see https://wiki.gentoo.org/wiki/Project:Quality_Assurance/Backtraces
dvb	Add support for DVB (Digital Video Broadcasting)
dvd	Add support for DVDs
gamepad	Enable gamepad input support
jack	Add support for the JACK Audio Connection Kit
javascript	Enable javascript support
jpeg	Add JPEG image support
lcms	Add lcms support (color management engine)
libcaca	Add support for colored ASCII-art graphics
nvenc	Add support for NVIDIA Encoder/Decoder (NVENC/NVDEC) API for hardware accelerated encoding and decoding on NVIDIA cards (requires x11-drivers/nvidia-drivers)
openal	Add support for the Open Audio Library
pipewire	Enable sound support via native PipeWire backend
pulseaudio	Add sound server support via media-libs/libpulse (may be PulseAudio or PipeWire)
rubberband	Enable high quality pitch correction via media-libs/rubberband
sdl	Enable media-libs/libsdl2 based video and audio outputs (Note: these outputs exist for compatibility reasons only, avoid if possible)
selinux	!!internal use only!! Security Enhanced Linux support, this must be set by the selinux profile or breakage will occur
sixel	Enable support for the sixel video backend using media-libs/libsixel
sndio	Enable sound support via media-sound/sndio
soc	Use additional media-video/ffmpeg patches for efficient playback on some SoCs (e.g. ARM, RISC-V)
test	Enable dependencies and/or preparations necessary to run tests (usually controlled by FEATURES=test but can be toggled independently)
tools	Install extra tools: mpv_identify.sh, mpv_idet.sh, and umpv
vaapi	Enable Video Acceleration API for hardware decoding
vdpau	Enable the Video Decode and Presentation API for Unix acceleration interface
wayland	Enable dev-libs/wayland backend
xv	Add in optional support for the Xvideo extension (an X API for video playback)
zimg	Enable libzimg support (for vf_fingerprint)
zlib	Add support for zlib compression

設定
mpv は通常は設定を必要としません。しかしながら、デフォルトの挙動の多くの側面を変更することができます。 設定のうち最重要な 2 つの部分は、プレイヤーの設定とキーバインディングです。どちらについても以下で簡単に説明します。

プレイヤー設定
プレイヤー設定は、~/.config/mpv/mpv.conf ファイルに option=value 構文を使用して置くべきです。 # の後ろにあるものはすべてコメントとみなされます。

ほとんどすべてのコマンドラインオプションは、プレイヤー設定として設定することができます。多くの場合、--option=value コマンドライン引数と等価な設定は option=value になります。値なしで動作するオプションは、yes に設定することで有効化でき、no に設定することで無効化できます。

異なる設定を簡単に使い分けるために、設定ファイルでプロファイルを定義することができます。プロファイルは [my-profile] のように、角括弧で囲まれた名前で始まります。それに続くオプションはすべて、このプロファイルの一部となります。プロファイルの定義を終了するには、別のプロファイルを開始するか、以降を通常のオプションとするためにプロファイル名 default を使用してください。

ファイル ~/.config/mpv/mpv.confプレーヤー設定例
# シークを常に (例えば HTTP ストリームのローカルキャッシュ内でも) 許可する
force-seekable=yes
# 動画が無い場合でも常に動画ウィンドウを開く
force-window=yes
# プレイリストの終わりに到達したときに終了しない
keep-open=yes
# 終了時に現在の再生位置を常に保存する
save-position-on-quit=yes

# 'high-quality' プロファイルを作成する
[high-quality]
# このプロファイルの説明
profile-desc="High quality rendering"
# デフォルトの 'opengl-hq' プロファイルからすべての設定を取り込む
profile=opengl-hq
# より良いパフォーマンスのためにバンディング低減を無効化する
deband=no

使い方
ユーザスクリプトとプラグイン
mpv のコア機能は、Lua または JavaScript のスクリプトか、C プラグインを使って、拡張することができます。

~/.config/mpv/scripts/ ディレクトリのすべてのスクリプトとプラグインは自動的にロードされます。あるいは --script=/path/to/your/script.file のようにして、コマンドラインから手動でスクリプトまたはプラグインをロードすることもできます。

複数の Lua スクリプトが mpv に付属しており、これらは /usr/share/mpv/lua/ ディレクトリにインストールされます。上流の wiki にもサードパーティ製スクリプトおよびプラグインの膨大なリストがあります。

トラブルシューティング
 重要
mpv に関する問題がある場合は、--log-file オプションでファイルへのログ出力を有効化するか、-v オプションで詳細な端末出力を有効化してください。

ハードウェア動画デコーディングの障害/高い CPU 使用率
ハードウェアデコーディングに関する問題が無いか mpv ログを確認してください。動画再生中に CPU 使用率が高くなるのは、ハードウェアデコーディングに障害がある兆候です。

まず、ハードウェアが必要な動画コーデックに対応しているか確認してください。GPU が VAAPI および VDPAU デコーディング API を利用して対応しているコーデックの一覧は、それぞれ vainfo および vdpauinfo コマンドを利用して確認できます。再生した動画ファイルで使用されているコーデックは mpv ログ内で確認できます。GPU が必要なコーデックに対応しているが、mpv がハードウェアデコーディングを行っていない場合は、--hwdec-codecs=all オプションを試してみてください。

次に、ツリーで利用可能な非 live (9999 以外) で最新のバージョンの mpv を使用していることを確認してください。 最新バージョンへの更新で問題が解決する場合は、Gentoo のバグとして報告してください。

それでも解決しない場合、いくつか試してみることがあります:

・--hwdec=auto-copy で、コピーバックを利用したハードウェアデコーダを有効化してください。
・VAAPI のみ: --vo=vaapi を --hwdec=vaapi または --hwdec=vaapi-copy とともに利用して、vaapi の出力を使用してください。
・VDPAU のみ: --vo=vdpau を --hwdec=vdpau または --hwdec=vdpau-copy とともに利用して、vdpau の出力を使用してください。
・VDPAU のみ: --opengl-backend=x11 で、opengl の出力のために X11/GLX バックエンドを使用してください。
・Intel GPU のみ: x11-base/xorg-server に含まれる modesetting Xorg ドライバを使用してください。
・--opengl-dumb-mode=yes で、opengl 出力のために dumb-mode を有効化してください。
・--vo=xv を --hwdec=auto-copy とともに利用して、xv 出力を使用してください。

以下は日本語の設定について記述のあるブログの資料になります。

１．mpv の設定ファイルについて  

*   /etc/mpv/mpv.conf は全ユーザー共通の設定ファイルだが、Ubuntu Studio 22.04.2 LTS のクリーンインストール直後に内容を確認すると、hwdec=vaapi と 1 行だけ記述されていた  
    ※インストール時に /etc/mpv/mpv.conf が自動的に作成されないこともある
*   ~/.config/mpv/mpv.conf はユーザーごとの設定ファイルだが、クリーンインストール直後は無かったので、必要な設定を書き込むために作成した（※ ~/.config/mpv/ にテキストファイルを作成しファイル名を mpv.conf とすればよい）

  
２．[ArchWiki による高度な設定](https://wiki.archlinux.jp/index.php/Mpv#.E9.AB.98.E5.BA.A6.E3.81.AA.E8.A8.AD.E5.AE.9A)  

*   ArchWiki では以下のような設定例を示しているが、これらについて以下、順に見ていく
    
    > profile=gpu-hq  
    > scale=ewa\_lanczossharp  
    > cscale=ewa\_lanczossharp  
    > video-sync=display-resample  
    > interpolation  
    > tscale=oversample
    
*   profile= はプロファイルの設定であるが、ここでは既存のプロファイルが適用されている
*   先ず利用出来るプロファイルのリストを見てみる
    
    > $ mpv --profile=help  
    > Available profiles:  
    >         enc-to-hp-slate-7      MP4 for HP Slate 7 (1024x600, crazy aspect)  
    >         enc-to-nok-6300       3GP for Nokia 6300  
    >         enc-to-nok-n900       MP4 for Nokia N900  
    >         enc-to-dvdntsc          DVD-Video NTSC, use dvdauthor -v ntsc -a ac3+en (MUST be used with 4:3 or 16:9 aspect, and 720x480, 704x480, 352x480 or 352x240 resolution)  
    >         enc-to-dvdpal            DVD-Video PAL, use dvdauthor -v pal -a ac3+en (MUST be used with 4:3 or 16:9 aspect, and 720x576, 704x576, 352x576 or 352x288 resolution)  
    >         enc-f-webm                VP9 + Opus (for WebM)  
    >         enc-f-mp4                    H.264 + AAC (for MP4)  
    >         enc-f-avi                       MPEG-4 + MP3 (for AVI)  
    >         enc-f-3gp                      H.263 + AAC (for 3GP)  
    >         enc-v-vp9                     VP9 (libvpx)  
    >         enc-v-vp8                     VP8 (libvpx)  
    >         enc-v-mpeg4              MPEG-4 Part 2 (FFmpeg)  
    >         enc-v-mpeg2              MPEG-2 Video (FFmpeg)  
    >         enc-v-h264                  H.264 (x264)  
    >         enc-v-h263                  H.263 (FFmpeg)  
    >         enc-a-opus                  Opus (libopus or FFmpeg)  
    >         enc-a-vorbis                Vorbis (libvorbis or FFmpeg)  
    >         enc-a-mp3                   MP3 (LAME)  
    >         enc-a-ac3                    AC3 (FFmpeg)  
    >         enc-a-aac                    AAC (libfdk-aac or FFmpeg)  
    >         opengl-hq  
    >         sw-fast  
    >         low-latency  
    >         gpu-hq  
    >         encoding  
    >         libmpv  
    >         builtin-pseudo-gui  
    >         pseudo-gui  
    >         default
    
*   この中にある gpu-hq というプロファイルについて、ArchWiki では「中程度の品質と速度を実現するために、デフォルトで spline36 スケーリングフィルターに設定されています」と述べている
*   gpu-hq の内容を見てみる
    
    > $ mpv --show-profile=gpu-hq  
    > Profile gpu-hq:   
    >   scale=spline36  
    >   cscale=spline36  
    >   dscale=mitchell  
    >   dither-depth=auto  
    >   correct-downscaling=yes  
    >   linear-downscaling=yes  
    >   sigmoid-upscaling=yes  
    >   deband=yes
    
*   ArchWiki は、gpu-hq を適用した上で別のスケーリングフィルターを設定している
    
    > profile=gpu-hq  
    > scale=ewa\_lanczossharp  
    > cscale=ewa\_lanczossharp  
    
*   [mpv のマニュアル](https://mpv.io/manual/stable/#gpu-renderer-options)では、scale= と cscale= について以下のように記述している  
    ※青字（ブログ筆者による）の部分が ArchWiki の設定例で採用されたもの（以下同様）
    
    > **\--scale=<filter>**
    > 
    > > The filter function to use when upscaling video.  
    > >   
    > > **bilinear**  
    > > Bilinear hardware texture filtering (fastest, very low quality). This is the default for compatibility reasons.  
    > >   
    > > **spline36**  
    > > Mid quality and speed. This is the default when using gpu-hq.  
    > >   
    > > **lanczos**  
    > > Lanczos scaling. Provides mid quality and speed. Generally worse than spline36, but it results in a slightly sharper image which is good for some content types. The number of taps can be controlled with scale-radius, but is best left unchanged.  
    > >   
    > > (This filter is an alias for sinc-windowed sinc)  
    > >   
    > > **ewa\_lanczos**  
    > > Elliptic weighted average Lanczos scaling. Also known as Jinc. Relatively slow, but very good quality. The radius can be controlled with scale-radius. Increasing the radius makes the filter sharper but adds more ringing.  
    > >   
    > > (This filter is an alias for jinc-windowed jinc)  
    > >   
    > > **ewa\_lanczossharp**  
    > > A slightly sharpened version of ewa\_lanczos, preconfigured to use an ideal radius and parameter. If your hardware can run it, this is probably what you should use by default.  
    > >   
    > > **mitchell**  
    > > Mitchell-Netravali. The B and C parameters can be set with --scale-param1 and --scale-param2. This filter is very good at downscaling (see --dscale).  
    > >   
    > > **oversample**  
    > > A version of nearest neighbour that (naively) oversamples pixels, so that pixels overlapping edges get linearly interpolated instead of rounded. This essentially removes the small imperfections and judder artifacts caused by nearest-neighbour interpolation, in exchange for adding some blur. This filter is good at temporal interpolation, and also known as "smoothmotion" (see --tscale).  
    > >   
    > > **linear**  
    > > A --tscale filter.  
    > >   
    > > There are some more filters, but most are not as useful. For a complete list, pass help as value, e.g.:
    > > 
    > > > mpv --scale=help
    > 
    > **\--cscale=<filter>**
    > 
    > > As --scale, but for interpolating chroma information. If the image is not subsampled, this option is ignored entirely.
    
*   次に video-sync= であるが、[mpv のマニュアル](https://mpv.io/manual/stable/#miscellaneous)では以下のように記述している  
    ※interpolation の設定をするなら、display- のいずれかの設定が必要となる（次項参照）
    
    > **\--video-sync=<audio|...>**
    > 
    > > How the player synchronizes audio and video.  
    > >   
    > > If you use this option, you usually want to set it to display-resample to enable a timing mode that tries to not skip or repeat frames when for example playing 24fps video on a 24Hz screen.  
    > >   
    > > The modes starting with display- try to output video frames completely synchronously to the display, using the detected display vertical refresh rate as a hint how fast frames will be displayed on average. These modes change video speed slightly to match the display. See --video-sync-... options for fine tuning. The robustness of this mode is further reduced by making a some idealized assumptions, which may not always apply in reality. Behavior can depend on the VO and the system's video and audio drivers. Media files must use constant framerate. Section-wise VFR might work as well with some container formats (but not e.g. mkv).  
    > >   
    > > Under some circumstances, the player automatically reverts to audio mode for some time or permanently. This can happen on very low framerate video, or if the framerate cannot be detected.  
    > >   
    > > Also in display-sync modes it can happen that interruptions to video playback (such as toggling fullscreen mode, or simply resizing the window) will skip the video frames that should have been displayed, while audio mode will display them after the renderer has resumed (typically resulting in a short A/V desync and the video "catching up").  
    > >   
    > > Before mpv 0.30.0, there was a fallback to audio mode on severe A/V desync. This was changed for the sake of not sporadically stopping. Now, display-desync does what it promises and may desync with audio by an arbitrary amount, until it is manually fixed with a seek.  
    > >   
    > > These modes also require a vsync blocked presentation mode. For OpenGL, this translates to --opengl-swapinterval=1. For Vulkan, it translates to --vulkan-swap-mode=fifo (or fifo-relaxed).  
    > >   
    > > The modes with desync in their names do not attempt to keep audio/video in sync. They will slowly (or quickly) desync, until e.g. the next seek happens. These modes are meant for testing, not serious use.  
    > >   
    > > **audio:**
    > > 
    > > > Time video frames to audio. This is the most robust mode, because the player doesn't have to assume anything about how the display behaves. The disadvantage is that it can lead to occasional frame drops or repeats. If audio is disabled, this uses the system clock. This is the default mode.
    > > 
    > > **display-resample:**
    > > 
    > > > Resample audio to match the video. This mode will also try to adjust audio speed to compensate for other drift. (This means it will play the audio at a different speed every once in a while to reduce the A/V difference.)
    > > 
    > > **display-resample-vdrop:**
    > > 
    > > > Resample audio to match the video. Drop video frames to compensate for drift.
    > > 
    > > **display-resample-desync:**
    > > 
    > > > Like the previous mode, but no A/V compensation.
    > > 
    > > **display-vdrop:**
    > > 
    > > > Drop or repeat video frames to compensate desyncing video. (Although it should have the same effects as audio, the implementation is very different.)
    > > 
    > > **display-adrop:**
    > > 
    > > > Drop or repeat audio data to compensate desyncing video. This mode will cause severe audio artifacts if the real monitor refresh rate is too different from the reported or forced rate. Since mpv 0.33.0, this acts on entire audio frames, instead of single samples.
    > > 
    > > **display-desync:**
    > > 
    > > > Sync video to display, and let audio play on its own.
    > > 
    > > **desync:**
    > > 
    > > > Sync video according to system clock, and let audio play on its own.
    
*   interpolation については、[mpv のマニュアル](https://mpv.io/manual/stable/#gpu-renderer-options)では以下のように記述している  
    ※使用するフィルターについては次項の tscale= で規定する  
    ※引用文中の下線はブログ筆者によるもの（以下同様）
    
    > **\--interpolation**
    > 
    > > Reduce stuttering caused by mismatches in the video fps and display refresh rate (also known as judder).  
    > > 
    > > > Warning  
    > > > This requires setting the --video-sync option to one of the display- modes, or it will be silently disabled. This was not required before mpv 0.14.0.
    > > 
    > > This essentially attempts to interpolate the missing frames by convoluting the video along the temporal axis. The filter used can be controlled using the --tscale setting.
    
*   tscale= については、[mpv のマニュアル](https://mpv.io/manual/stable/#gpu-renderer-options)では以下のように記述している
    
    > **\--tscale=<filter>**
    > 
    > > The filter used for interpolating the temporal axis (frames). This is only used if --interpolation is enabled. The only valid choices for --tscale are separable convolution filters (use --tscale=help to get a list). The default is mitchell.  
    > >   
    > > Common --tscale choices include oversample, linear, catmull\_rom, mitchell, gaussian, or bicubic. These are listed in increasing order of smoothness/blurriness, with bicubic being the smoothest/blurriest and oversample being the sharpest/least smooth.
    
*   以上のように、ArchWiki による設定例は、gpu-hq というプロファイルを元にして、更に映像のシャープネスを高めるようにしたものである

  
３．ビデオ出力とハードウェアデコードの設定  

*   上記１．に記したように、/etc/mpv/mpv.conf には hwdec=vaapi と 1 行だけ記述されていたのだが、hwdec= について、[mpv のマニュアル](https://mpv.io/manual/stable/#video)には以下のように説明されている  
    ※ vaapi に関する部分を赤字に、nvdec に関する部分を青字にしている（筆者の環境では NVIDIA の GPU を使用しているため）
    
    > **\--hwdec=**
    > 
    > > Specify the hardware video decoding API that should be used if possible. Whether hardware decoding is actually done depends on the video codec. If hardware decoding is not possible, mpv will fall back on software decoding.  
    > >   
    > > Hardware decoding is not enabled by default, to keep the out-of-the-box configuration as reliable as possible. However, when using modern hardware, hardware video decoding should work correctly, offering reduced CPU usage, and possibly lower power consumption. On older systems, it may be necessary to use hardware decoding due to insufficient CPU resources; and even on modern systems, sufficiently complex content (eg: 4K60 AV1) may require it.
    > > 
    > > >   
    > > > **Note**  
    > > >   
    > > > Use the Ctrl+h shortcut to toggle hardware decoding at runtime. It toggles this option between auto and no.  
    > > >   
    > > > If you decide you want to use hardware decoding by default, the general recommendation is to try out decoding with the command line option, and prove to yourself that it works as desired for the content you care about. After that, you can add it to your config file.  
    > > >   
    > > > When testing, you should start by using hwdec=auto-safe as it will limit itself to choosing from hwdecs that are actively supported by the development team. If that doesn't result in working hardware decoding, you can try hwdec=auto to have it attempt to load every possible hwdec, but if auto-safe didn't work, you will probably need to know exactly which hwdec matches your hardware and read up on that entry below.  
    > > >   
    > > > If auto-safe or auto produced the desired results, we recommend just sticking with that and only setting a specific hwdec in your config file if it is really necessary.  
    > > >   
    > > > If you use the Ubuntu package, keep in mind that their /etc/mpv/mpv.conf contains hwdec=vaapi, which is less than ideal as it may not be the right choice for your system, and it may end up using an inefficient wrapper library under the covers. We recommend removing this line or deleting the file altogether.  
    > > >   
    > > >   
    > > > **Note**  
    > > >   
    > > > Even if enabled, hardware decoding is still only white-listed for some codecs. See --hwdec-codecs to enable hardware decoding in more cases.  
    > > >   
    > > >   
    > > > **Which method to choose?**  
    > > >   
    > > > 
    > > > *   If you only want to enable hardware decoding at runtime, don't set the parameter, or put hwdec=no into your mpv.conf (relevant on distros which force-enable it by default, such as on Ubuntu). Use the Ctrl+h default binding to enable it at runtime.
    > > > *   If you're not sure, but want hardware decoding always enabled by default, put hwdec=auto-safe into your mpv.conf, and acknowledge that this may cause problems.
    > > > *   If you want to test available hardware decoding methods, pass --hwdec=auto --hwdec-codecs=all and look at the terminal output.
    > > > *   If you're a developer, or want to perform elaborate tests, you may need any of the other possible option values.
    > > 
    > >   
    > > <api> can be one of the following:  
    > >   
    > > **no:**                        always use software decoding (default)  
    > > **auto:**                     forcibly enable any hw decoder found (see below)  
    > > **yes:**                        exactly the same as auto  
    > > **auto-safe:**           enable any whitelisted hw decoder (see below)  
    > > **auto-copy:**          enable best hw decoder with copy-back (see below)  
    > >   
    > > Actively supported hwdecs:  
    > >   
    > > **d3d11va:**               requires --vo=gpu with --gpu-context=d3d11 or --gpu-context=angle (Windows 8+ only)  
    > > **d3d11va-copy:**    copies video back to system RAM (Windows 8+ only)  
    > > **videotoolbox:**      requires --vo=gpu (macOS 10.8 and up), or --vo=libmpv (iOS 9.0 and up)  
    > > **videotoolbox-copy:**  
    > >                                   copies video back into system RAM (macOS 10.8 or iOS 9.0 and up)  
    > > **vaapi:**                      requires --vo=gpu, --vo=vaapi or --vo=dmabuf-wayland (Linux only)  
    > > **vaapi-copy:**          copies video back into system RAM (Linux with some GPUs only)  
    > > **nvdec:**                     requires --vo=gpu (Any platform CUDA is available)  
    > > **nvdec-copy:**          copies video back to system RAM (Any platform CUDA is available)  
    > > **drm:**                         requires --vo=gpu (Linux only)  
    > > **drm-copy:**             copies video back to system RAM (Linux ony)  
    > >   
    > > Other hwdecs (only use if you know you have to):  
    > >   
    > > **dxva2:**                     requires --vo=gpu with --gpu-context=d3d11, --gpu-context=angle or --gpu-context=dxinterop (Windows only)  
    > > **dxva2-copy:**          copies video back to system RAM (Windows only)  
    > > **vdpau:**                    requires --vo=gpu with X11, or --vo=vdpau (Linux only)  
    > > **vdpau-copy:**         copies video back into system RAM (Linux with some GPUs only)  
    > > **mediacodec:**        requires --vo=gpu --gpu-context=android or --vo=mediacodec\_embed (Android only)  
    > > **mediacodec-copy:**  
    > >                                    copies video back to system RAM (Android only)  
    > > **mmal:**                      requires --vo=gpu (Raspberry Pi only - default if available)  
    > > **mmal-copy:**           copies video back to system RAM (Raspberry Pi only)  
    > > **cuda:**                        requires --vo=gpu (Any platform CUDA is available)  
    > > **cuda-copy:**             copies video back to system RAM (Any platform CUDA is available)  
    > > **crystalhd:**               copies video back to system RAM (Any platform supported by hardware)  
    > > **rkmpp:**                     requires --vo=gpu (some RockChip devices only)  
    > >   
    > > auto tries to automatically enable hardware decoding using the first available method. This still depends what VO you are using. For example, if you are not using --vo=gpu or --vo=vdpau, vdpau decoding will never be enabled. Also note that if the first found method doesn't actually work, it will always fall back to software decoding, instead of trying the next method (might matter on some Linux systems).  
    > >   
    > > auto-safe is similar to auto, but allows only whitelisted methods that are considered "safe". This is supposed to be a reasonable way to enable hardware decdoding by default in a config file (even though you shouldn't do that anyway; prefer runtime enabling with Ctrl+h). Unlike auto, this will not try to enable unknown or known-to-be-bad methods. In addition, this may disable hardware decoding in other situations when it's known to cause problems, but currently this mechanism is quite primitive. (As an example for something that still causes problems: certain combinations of HEVC and Intel chips on Windows tend to cause mpv to crash, most likely due to driver bugs.)  
    > >   
    > > auto-copy-safe selects the union of methods selected with auto-safe and auto-copy.  
    > >   
    > > auto-copy selects only modes that copy the video data back to system memory after decoding. This selects modes like vaapi-copy (and so on). If none of these work, hardware decoding is disabled. This mode is usually guaranteed to incur no additional quality loss compared to software decoding (assuming modern codecs and an error free video stream), and will allow CPU processing with video filters. This mode works with all video filters and VOs.  
    > >   
    > > Because these copy the decoded video back to system RAM, they're often less efficient than the direct modes, and may not help too much over software decoding if you are short on CPU resources.  
    > >   
    > > 
    > > > **Note**  
    > > > Most non-copy methods only work with the OpenGL GPU backend. Currently, only the vaapi, nvdec and cuda methods work with Vulkan.
    > > 
    > >   
    > > The vaapi mode, if used with --vo=gpu, requires Mesa 11, and most likely works with Intel and AMD GPUs only. It also requires the opengl EGL backend.  
    > >   
    > > nvdec and nvdec-copy are the newest, and recommended method to do hardware decoding on Nvidia GPUs.  
    > >   
    > > cuda and cuda-copy are an older implementation of hardware decoding on Nvidia GPUs that uses Nvidia's bitstream parsers rather than FFmpeg's. This can lead to feature deficiencies, such as incorrect playback of HDR content, and nvdec/nvdec-copy should always be preferred unless you specifically need Nvidia's deinterlacing algorithms. To use this deinterlacing you must pass the option: vd-lavc-o=deint=\[weave|bob|adaptive\]. Pass weave (or leave the option unset) to not attempt any deinterlacing.  
    > >   
    > > 
    > > > **Quality reduction with hardware decoding**  
    > > >   
    > > > In theory, hardware decoding does not reduce video quality (at least for the codecs h264 and HEVC). However, due to restrictions in video output APIs, as well as bugs in the actual hardware decoders, there can be some loss, or even blatantly incorrect results. This has largely ceased to be a problem with modern hardware, but there is a lot of hardware out there, so caveat emptor. Known problems are discussed below, but the list cannot be considered exhaustive, as even hwdecs that work well on certain hardware generations may be problematic on other ones.  
    > > >   
    > > > In some cases, RGB conversion is forced, which means the RGB conversion is performed by the hardware decoding API, instead of the shaders used by --vo=gpu. This means certain colorspaces may not display correctly, and certain filtering (such as debanding) cannot be applied in an ideal way. This will also usually force the use of low quality chroma scalers instead of the one specified by --cscale. In other cases, hardware decoding can also reduce the bit depth of the decoded image, which can introduce banding or precision loss for 10-bit files.  
    > > >   
    > > > vdpau always does RGB conversion in hardware, which does not support newer colorspaces like BT.2020 correctly. However, vdpau doesn't support 10 bit or HDR encodings, so these limitations are unlikely to be relevant.  
    > > >   
    > > > dxva2 is not safe. It appears to always use BT.601 for forced RGB conversion, but actual behavior depends on the GPU drivers. Some drivers appear to convert to limited range RGB, which gives a faded appearance. In addition to driver-specific behavior, global system settings might affect this additionally. This can give incorrect results even with completely ordinary video sources.  
    > > >   
    > > > rpi always uses the hardware overlay renderer, even with --vo=gpu.  
    > > >   
    > > > mediacodec is not safe. It forces RGB conversion (not with -copy) and how well it handles non-standard colorspaces is not known. In the rare cases where 10-bit is supported the bit depth of the output will be reduced to 8.  
    > > >   
    > > > cuda should usually be safe, but depending on how a file/stream has been mixed, it has been reported to corrupt the timestamps causing glitched, flashing frames. It can also sometimes cause massive framedrops for unknown reasons. Caution is advised, and nvdec should always be preferred.  
    > > >   
    > > > crystalhd is not safe. It always converts to 4:2:2 YUV, which may be lossy, depending on how chroma sub-sampling is done during conversion. It also discards the top left pixel of each frame for some reason.  
    > > >   
    > > > If you run into any weird decoding issues, frame glitches or discoloration, and you have --hwdec turned on, the first thing you should try is disabling it.  
    
*   hwdec=vaapi にしても hwdec=nvdec にしても、vo=gpu という記述が必要とされている
*   vo= について、[mpv のマニュアル](https://mpv.io/manual/stable/#video-output-drivers)には以下のように説明されている
    
    > **\--vo=<driver1,driver2,...\[,\]>**  
    >       Specify a priority list of video output drivers to be used.  
    >   
    > If the list has a trailing ,, mpv will fall back on drivers not contained in the list.  
    >   
    > 
    > > **Note**  
    > >   
    > > See --vo=help for a list of compiled-in video output drivers.  
    > >   
    > > The recommended output driver is --vo=gpu, which is the default. All other drivers are for compatibility or special purposes. If the default does not work, it will fallback to other drivers (in the same order as listed by --vo=help).
    > 
    >   
    > Available video output drivers are:  
    >   
    > **gpu**  
    > 
    > > General purpose, customizable, GPU-accelerated video output driver. It supports extended scaling methods, dithering, color management, custom shaders, HDR, and more.  
    > >   
    > > See GPU renderer options for options specific to this VO.  
    > >   
    > > By default, it tries to use fast and fail-safe settings. Use the gpu-hq profile to use this driver with defaults set to high quality rendering. The profile can be applied with --profile=gpu-hq and its contents can be viewed with --show-profile=gpu-hq.  
    > >   
    > > This VO abstracts over several possible graphics APIs and windowing contexts, which can be influenced using the --gpu-api and --gpu-context options.  
    > >   
    > > Hardware decoding over OpenGL-interop is supported to some degree. Note that in this mode, some corner case might not be gracefully handled, and color space conversion and chroma upsampling is generally in the hand of the hardware decoder APIs.  
    > >   
    > > gpu makes use of FBOs by default. Sometimes you can achieve better quality or performance by changing the --fbo-format option to rgb16f, rgb32f or rgb. Known problems include Mesa/Intel not accepting rgb16, Mesa sometimes not being compiled with float texture support, and some macOS setups being very slow with rgb16 but fast with rgb32f. If you have problems, you can also try enabling the --gpu-dumb-mode=yes option.
    > 
    > （※中略）  
    >   
    > **vaapi**
    > 
    > > Intel VA API video output driver with support for hardware decoding. Note that there is absolutely no reason to use this, other than compatibility. This is low quality, and has issues with OSD. We strongly recommend that you use --vo=gpu with --hwdec=vaapi instead.
    > 
    > （※後略）
    
*   以上のような mpv のマニュアルの記述から、NVIDIA の GPU を使用してハードウェアデコードするなら、vo=gpu と hwdec=nvdec という記述が妥当だと思われる

  
４．その他の設定  

*   オーディオは Jack へ出力するので、ao=jack とする  
    ※ [mpv のマニュアル](https://mpv.io/manual/stable/#audio-output-drivers)参照
*   デフォルトでは、動画のウィンドウの長辺または短辺がタスクバーを除くデスクトップ一杯にまで拡大されるのだが、これを動画のオリジナルサイズで表示するように window-scale= オプションを使用する
*   window-scale= について [mpv のマニュアル](https://mpv.io/manual/stable/#window)には以下のように記述されている
    
    > **\--window-scale=<factor>**
    > 
    > > Resize the video window to a multiple (or fraction) of the video size. This option is applied before --autofit and other options are applied (so they override this option).  
    > >   
    > > For example, --window-scale=0.5 would show the window at half the video size.
    
    ※筆者の環境では、何故か 0.5 でオリジナルのサイズになるので、window-scale=0.5 とする  
    

  
５．~/.config/mpv/mpv.conf の記述  
  
最終的な記述は、以下のようになる  

> profile=gpu-hq  
> vo=gpu  
> hwdec=nvdec  
> scale=ewa\_lanczossharp  
> cscale=ewa\_lanczossharp  
> video-sync=display-resample  
> interpolation  
> tscale=oversample  
> ao=jack  
> window-scale=0.5

以上が日本語の設定資料になります。