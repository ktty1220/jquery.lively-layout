#jshint jquery:true, forin:false
do (jQuery) ->
  ###*
  * 同期for関数(ループ内で非同期処理があっても完了まで待つ)
  ###
  syncEach = () ->
    [ array, func, idx, cb, args... ] = arguments
    if idx instanceof Function
      cb = idx
      idx = 0
    return cb.apply array, [ undefined ].concat(args) if idx >= array.length
    next = () =>
      return cb arguments[0] if arguments[0] instanceof Error
      syncEach.apply @, [ array, func, idx + 1, cb ].concat(a for a in arguments)
    try
      func.apply array, [ array[idx], idx, next ].concat(args)
    catch e
      return cb e

  ###*
  * 要素のmargin-xxxの数値取得
  ###
  margin = (elem, pos) ->
    m = parseFloat(elem.css "margin-#{pos}")
    if isNaN m then 0 else m

  ###*
  * $.livelyLayout()
  ###
  jQuery.livelyLayout = (animConf = {}, cb) ->
    $window = $(window)

    ### 登録されているアニメーション対象の要素の現在位置を取得 ###
    posInfo = {}
    for ac in animConf
      $el = $(ac.element)
      pi =
        css:
          position: $el.css 'position'
          top: $el.css 'top'
          bottom: $el.css 'bottom'
          left: $el.css 'left'
          right: $el.css 'right'
          marginTop: $el.css 'margin-top'
          marginLeft: $el.css 'margin-left'
        offset:
          left: $el.offset().left - margin($el, 'left')
          top: $el.offset().top - margin($el, 'top')
        height: $el.height()
        width: $el.width()

      posInfo[ac.element] = pi

    #console.log posInfo

    ### 登場させる要素は一時的に画面外に配置する関係上スクロールバーが出てしまうのでhtml要素を少し改造(処理後に元に戻す) ###
    $html = $('html').css
      width: $window.width()
      position: 'relative'
      overflow: 'hidden'

    ### アニメーション設定を1つずつ同期処理 ###
    syncEach animConf, (item, index, next, cssInfo = []) ->
      $el = $(item.element)
      ### 現在位置の情報を取得 ###
      elPos = posInfo[item.element]

      ### 登場アニメーション時はposition:absoluteにする ###
      elCss = $.extend {},
        position: 'absolute'
        visibility: 'visible'
        marginTop: elPos.css.marginTop
        marginLeft: elPos.css.marginLeft
        left: elPos.offset.left
        top: elPos.offset.top
        width: elPos.width
        height: elPos.height
      , item.from ? {}

      ### スタートx位置特殊設定(画面外設置) ###
      if item.from?.right < 0
        elCss.left = $window.width()
        elCss.right = 'auto'
      else if item.from?.left < 0
        elCss.left = elPos.width * -1

      ### スタートy位置特殊設定(画面外設置) ###
      if item.from?.bottom < 0
        elCss.top = $window.height()
        elCss.bottom = 'auto'
      else if item.from?.top < 0
        elCss.top = elPos.height * -1

      #console.log elCss

      ### 全処理完了後にCSSを解除する為の設定を保持 ###
      cssInfo.push
        item: item
        css: elCss

      ### 移動先は初期配置位置 ###
      animVal = $.extend {},
        top: elPos.offset.top
        left: elPos.offset.left
      , item.to ? {}

      ### animate設定 ###
      animOpt =
        duration: item.duration ? 1000
        easing: item.easing ? 'swing'

      ### 完了待ち設定 ###
      item.wait = true unless item.wait?
      animOpt.complete = () ->
        elObj = $(item.element).css 'transform', ''
        item.complete?.call elObj, elPos, elCss
        item.done = true
        next cssInfo if item.wait

      ### 要素回転設定 ###
      if item.rotate?
        item.rotate.rev ?= 1
        item.rotate.type ?= ''
        item.rotate.direction ?= 'right'
        ### durationの間に指定した回転数を満たすstep()毎の傾き算出 ###
        deg = item.rotate.rev * 180 / parseInt((item.duration ? 1000) / jQuery.fx.interval, 10)
        deg *= -1 if item.rotate.direction is 'left'
        angle = 0
        animOpt.step = () ->
          angle += deg
          $(@).css 'transform', "rotate#{item.rotate.type}(#{angle}deg)"

      ### 要素アニメーション処理実行 ###
      $el.css(elCss).show()
      $el.delay item.delay if item.delay?
      $el.animate animVal, animOpt

      ### 完了待ちしない場合はすぐに次の要素へ ###
      next cssInfo unless item.wait

    , (err, cssInfo) ->
      throw new Error err if err?

      ### 全要素のアニメーションが完了するまで待機 ###
      timer = setInterval () ->
        if (ci for ci in cssInfo when not ci.item.done).length is 0
          clearInterval timer

          ### 一時的に変更したhtml要素のCSSを解除 ###
          $html.css
            width: ''
            position: ''
            overflow: ''

          ### アニメーション用に変更した各要素のCSSを解除して素の状態に戻す ###
          for ci in cssInfo
            delete ci.css.visibility
            $(ci.item.element).css k, '' for k, v of ci.css

          cb?()
      , 100
