# jQuery Lively Layout - HTMLのレイアウト表示をアニメーションで演出するjQueryプラグイン

HTMLを表示する際に、各パーツごとに左右からビューン、とか上からドスーンみたいなアニメーションを指定できるjQueryプラグインです。

[BootStrapのレイアウトを使用したデモ](http://ktty1220.ap01.aws.af.cm/jquery.lively-layout/demo.html)

動きのあるHTMLを実装したい場合にどうそ。でもやりすぎると鬱陶しいかもしれません・・・

## 使用方法

※ jQueryの他に[jQuery Easing Plugin](http://gsgd.co.uk/sandbox/jquery/easing/)が必要になります。

1. HTML内で __jquery.js__ 、 __jquery.easing.js__ 、 __jquery.lively-layout.js__ を読み込みます。

        <script type="text/javascript" src="/path/to/jquery.js"></script>
        <script type="text/javascript" src="/path/to/jquery.easing.js"></script>
        <script type="text/javascript" src="/path/to/jquery.popn-socialbutton.js"></script>

2. アニメーション表示させたい要素をCSSで`visibility: hidden`で非表示状態にしておきます。

    ※ __`display: none`では非表示の要素の位置やサイズも消えてしまう為、正常に動作しません。__

        // `footer`、`.sidebar-nav`、`.navbar`の要素をアニメーションさせる場合のCSS例
        footer,
        .sidebar-nav, 
        .navbar {
          visibility: hidden;
        }

3. __アニメーション設定の配列__ と __完了時のコールバック関数__ を引数に`$.livelyLayout`をコールします。

        // アニメーション設定
        var config = [{
          element: 'footer',
          from: { right: -1 },
          easing: 'easeOutBounce',
          wait: false
        }, {
          element: '.sidebar-nav',
          from: { left: 100, top: 20, color: '#ff0000' },
          easing: 'easeOutBounce',
          complete: function (defaultPosInfo, startCss) {
            $(this).addClass('loaded');
          },
          wait: true
        }, {
          element: '.navbar',
          from: { top: -1 },
          rotate: { rev: 3, type: 'X', direction: 'left' },
          easing: 'easeOutBounce',
          wait: false,
          delay: 100
        }];

        // アニメーション実行
        $.livelyLayout(config, function () {
          // アニメーション完了
          alert('complete');
        });

## API解説: $.livelyLayout(config[, callback])

### 第1引数: config (必須)

各要素のアニメーション表示設定の配列を指定します。指定できるオプションは以下の通りです。

* element __(必須)__

    アニメーションさせる要素の指定です。$(`'...'`)の`'...'`にあたる部分を指定します。

    ここで指定した要素は事前にCSSで`visibility: hidden`にされている必要があります。

        // idが'side-bar'の要素をアニメーション表示させる
        element: '#side-bar',

* from

    $(`element`)をアニメーション表示させる際のスタンバイ位置や初期状態を指定します。

    `top`、`left`などの位置指定の他、CSS設定(`color`など)の指定が可能です。

    なお、`top`、`bottom`、`left`、`right`に関しては0未満の数値を指定する事によってその方向の画面外に初期配置することができます。

        // 初期位置画面左上から登場してアニメーションで本来のレイアウト位置に移動する
        from: { top: 0, left: 0 },

        // 初期位置画面右(画面外)から登場してアニメーションで本来のレイアウト位置に移動する
        from: { right: -1 },

        // 初期位置画面左下(画面外)から文字色赤で登場してアニメーションで本来のレイアウト位置に移動する
        // (アニメーション完了時に文字色は解除される)
        from: { bottom: -1, left: -1, color: '#ff0000' },

* to

    デフォルトでは各要素は本来の表示位置に移動しますが、移動先を変更したい場合に指定します。ただし、`to`で指定した移動先や状態はアニメーション完了時に本来のレイアウト位置・状態に戻ります。

    アニメーションさせたい要素の親などが`position: relative`や`position: absolute`になっていると、移動先の座標位置がずれてしまうので、そういった場合に無理矢理移動先を修正する場合などに使用します。

        // 'position: relative'である'.parent-box'内の'.child-button'の移動先を修正
        to: {
          left: $('.child-button').offset().left - $('.parent-box').offset().left,
          top: $('.child-button').offset().top - $('.parent-box').offset().top
        },

    また、`.parent-box`が`position: static`だったとしても`.parent-box`がアニメーション対象の場合は、内部処理で一時的に`position: absolute`にされるので、親子で別々のアニメーションを同時に行う場合にもこういった`to`による調整が必要になります。

* easing

    アニメーションのタイプを指定します。指定できるタイプは[こちら](http://semooh.jp/jquery/cont/doc/easing/)を参考にしてください。省略時のデフォルトは`swing`です。

        // 緩急なし
        easing: 'linear',

        // 移動先に到着したときにバウンドさせる
        easing: 'easeOutBounce',

* rotate

    アニメーション中に要素を回転させます。以下の3項目を指定します。

    * type

        回転のタイプを指定します。

        * `''` or `Z` or 指定なし

            通常の2D回転です。

        * `'X'`

            X軸回転です。

        * `'Y'`

            Y軸回転です。

    * rev

        移動先に到着するまでの回転数です。デフォルトは`1`です。

    * direction

        右回りと左回りの指定です(`right` or `left`)。デフォルトは`right`です。

    なお、`rotate`は __IE8以下__ では動作しません。

        // 左回りで1回転しながら移動
        rotate: {
          direction: 'left'
        },

        // 右回りにX軸で10回転しながら移動
        rotate: {
          type: 'X',
          rev: 10
        },

* duration

    アニメーションで移動先に到着するまでの時間(ミリ秒)を指定します。デフォルトは`1000`です。

        // 3秒かけてゆっくりと移動
        duration: 3000,

        // 一瞬でシュバッと移動
        duration: 100,

* wait

    `false`を指定した場合、この要素のアニメーションが完了する前に次に指定した要素のアニメーションを開始します。同時に複数の要素をアニメーションさせたい場合に使用します。デフォルトは`true`(1要素ずつアニメーションさせる)です。

* delay

    アニメーション開始までの待機時間です。他の要素とほぼ同時に移動を開始させたいけど、ちょっとだけずらしたい場合などに使用します。

* complete

    この要素のアニメーションが完了したときに呼ばれるコールバック関数です。引数には以下の2つが渡されます。

    ※ 引数の情報はどちらかというとデバッグ用の色が強いのであまり使い道はないかもしれません。

    * defaultPosInfo

        本来のレイアウト上でのその要素の位置情報です。

    * startCss

        アニメーション開始時にその要素に設定された一時的なCSS情報です。全アニメーション完了後にこのCSS情報は解除されます。

    また、このコールバック関数内の`this`はその要素のjQueryオブジェクトです。

        // 要素の移動完了後に'loaded'クラスを付加
        complete: function (defaultPosInfo, startCss) {
          $(this).addClass('loaded');
        },

### 第2引数: callback (省略可能)

`config`で指定した全要素のアニメーション処理が完了したときに呼ばれます。引数はありません。

## 対応ブラウザ

* モダンブラウザ
* IE7以上

なお、jQueryは最新版でのみ動作確認しています。

## 既知の問題点もしくは仕様

* アニメーションさせたい要素が他の要素の配下にあり、かつその親要素が`position:relative`や`position:absolute`だった場合は表示位置がずれます。アニメーションさせる要素は一時的に`position:absolute`になるので、その基点はhtmlのトップレベルである必要があります。
* ある要素とその子要素を同じ`$.livelyLayout()`内でアニメーションさせると子要素の表示位置がずれます(親要素がアニメーションのために一時的に`position: absolute`になり、子要素の移動先の座標がHTMLのトップレベルではなく、親要素が基点になってしまうため)。

これらの問題点は将来的には自動的に調整できたらいいなーとは考えていますが、現状ではこういったケースでは座標のずれる要素の`to`オプションで移動先を調整する必要があります。

## Changelog

### 0.1.0 (2013-07-19)

* 初版リリース

## ライセンス

[MIT license](http://www.opensource.org/licenses/mit-license)で配布します。

&copy; 2013 [ktty1220](mailto:ktty1220@gmail.com)
