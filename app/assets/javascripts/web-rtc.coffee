$ ->
    # 初期化
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia
    window.URL = window.URL || window.webkitURL
    window.localStream = null

    sts = $('#status')
    cht = $('#chat-history')
    suffix = "_skimtalks"
    username = $('#status').data('username') + suffix
    user_id = $('#status').data('user_id')
    files = null
    lastSender = null
    contact_id = null
    schedule_id = null
    localPeerConnect = null
    peer = null
    destroyFlag = null

    # サーバに情報を保存しクライアントに表示を追加
    sendChat = () ->
        myText = $('#chat').val()
        # myTextに何らかの値がある場合
        if myText != ""
            setHr("remote")
            saveContent(myText, 'text', 'talks/upload_text')
            cht.prepend("<p>送信： " + myText + p_end)
            # 区切り線のための値をセット
            lastSender = "local"

            # フィールドをクリア
            $('#chat').val("")

        # files[0]になんらかの値がある場合
        if files && files[0]
            setHr("remote")
            saveContent(files[0],'file', 'talks/upload_file')
            blobUrl = window.URL.createObjectURL(files[0])
            cht.prepend('<p>送信： <a target="_blank" href="' + blobUrl + '">' + files[0].name + '</a>' + p_end)
            if files[0].type.match(/image/)
                setImage(blobUrl, files[0].name)

            # 区切り線のための値をセット
            lastSender = "local"

            # フィールドをクリア
            $('#file').val("")
            $('.filename').text("No file selected")

    # chatをサーバから取得し表示する
    openChat = ->
        getChat().done (result) ->
            if result.histories
                $('#chat-history').html(result.histories)
                lastSender = result.last_sender
            $('#loading').modal 'hide'

        getChat().fail (result) ->
            notify.error result
            $('#loading').modal 'hide'

    # chatをサーバから取得
    getChat = ->
        $('#chats').show()
        $('#talk-start').show()
        $('#chat-history').empty()
        data = schedule_id: schedule_id, sender: user_id
        return $.ajax
            type: "GET"
            dataType: "json"
            url: "talks/get_history"
            data: data

    # 接続成功時の処理
    startContact = (conn) ->
        $('#talk-start').hide()
        $('#chat_submit').hide()
        $('#remote_submit').show()
        if !contact_id
            contact_id = conn.peer
        remoteName = contact_id.replace(suffix, "")
        sts.append("<p>" + remoteName + "と接続しました" + p_end)
        connect(conn)
        localUserMedia(window.localStream)

    # チャット欄に時刻を追加
    getHM = ->
        date = new Date()
        h = date.getHours().toString()
        if h.length == 1
            h = "0" + h
        m = date.getMinutes().toString()
        if m.length == 1
            m = "0" + m
        HM = h + " : " + m

    # チャット欄に追加する時刻のhtml
    p_end = '<small class="c5 pull-right">' + getHM() + '</small></p>'

    # チャット欄に区切り線を追加
    # setHr(どちらの場合にhr要素をセットするか)
    # setHr(here) => lastSenderがhereだった場合にセットする
    setHr = (target) ->
        if lastSender == target
            cht.prepend("<hr />")

    # チャット欄に写真を表示
    setImage = (src, alt) ->
        img = document.createElement("img")
        img.src = src
        img.alt = alt
        img.height = 100
        img.width = 100
        img.onload = (e) ->
            window.URL.revokeObjectURL @src
        cht.prepend(img)

    # ローカルのビデオ/音声を取得
    localUserMedia = (localStream) ->
        if !localStream
            navigator.getUserMedia(
                {video: true, audio: true},
                (stream) ->
                        window.localStream = stream
                        $('#my_video').prop('src', window.URL.createObjectURL(stream))
                ,
                (e) ->
                    err.text(e)
            )

    # リモートのビデオ/音声を取得
    remoteUserMedia = (call) ->
        call.on 'stream', (stream) ->
            $('#target_video').prop('src', window.URL.createObjectURL(stream))

    # text/fileをサーバに保存
    saveContent = (content, content_name, url) ->
        form_data = new FormData()
        form_data.append(content_name, content)
        form_data.append('schedule_id', schedule_id)
        form_data.append('user_id', user_id)
        xhr_req = new XMLHttpRequest()
        xhr_req.open(
            'POST',
            url
        )
        xhr_req.send(form_data)
        # xhr_req.onload = (e) ->
        #     if this.status == 200
        #         alert("hogeQQQQQ")

    # ファイルは変更された時点で予め読み込んでおく
    $('#file').on 'change', (e) ->
        files = e.target.files

    # データ送信(オフライン時の処理）
    $('#chat_submit').on 'click', ->
        sendChat()

    # データ(テキスト & ファイル)
    connect = (conn) ->
        $('#call_video').show()

        # データ送信（オンライン時の処理）
        $('#remote_submit').on 'click', ->
            myText = $('#chat').val()
            if myText != ""
                conn.send(myText)
            if files && files[0]
                fileSet = [files[0], files[0].name, files[0].type]
                conn.send(fileSet)
            sendChat()

        # データ受信
        conn.on 'data', (data) ->
            # 接続リクエスト受信時のみp2p経由で情報取得
            if data[1] == "start_flag" && data[0] != null
                schedule_id = data[0]
                openChat()

            # p2p接続後、通常のデータ受信時
            else
                setHr("local")

                # テキスト受信
                if data.constructor == String
                    cht.prepend("<p>受信： " + data + p_end)

                # ファイル受信
                else if data.constructor == Array
                    dataView = new Uint8Array(data[0])
                    dataBlob = new Blob([dataView], { type: data[3] })
                    blobUrl = window.URL.createObjectURL(dataBlob)
                    cht.prepend('<p>受信： <a target="_blank" href="' + blobUrl + '">' + data[1] + '</a>' + p_end)
                    if data[2].match(/image/)
                        setImage(blobUrl, data[1])

                # 区切り線のための値をセット
                lastSender = "remote"

    # localPeerが存在しなければpeerサーバへpeerを登録
    openLocalPeer = (localPeer) ->
        localPeer.listAllPeers (list) ->
            alert(list)
            alert("username: " + username)
            if list.indexOf(username) < 0
                alert("このIDは使用可能だよ〜")
                peer.on 'open', (id) ->
                    if id && id != ""
                        id = id.replace(/_skimtalks/, "")
                        sts.append("<p>Your code is : " + id + p_end)
                        localPeerConnect = "true"

                peer.on 'error', (e) ->
                    # e = e.toString()
                    sts.append("<p>" + e + p_end)
                    localPeerConnect = "false"

            else
                alert("Please retry in few minutes later.")
                localPeerConnect = "false"

    # 接続準備
    if destroyFlag != "true"
        peer = new Peer(
            username,
            { key: 'd2be0c46-30b6-4c87-aaf7-8f686dad90fe' }
        )
        openLocalPeer(peer)

    # scheduleを選びチャットを表示
    $('.talk-schedule').on 'click', ->
        # 値をセット、画面を表示
        $('#loading').modal 'show'
        schedule_id = $(this).data('schedule_id')

        # 接続リクエストするための値をセット
        r = $(this).data('remote_name')
        contact_id = r + suffix
        openChat()

    # 選択されたscheduleの接続リクエストを送信 
    $('#talk-start').on 'click', ->
        if localPeerConnect == "true"
            conn = peer.connect(contact_id)
            conn.on 'open', ->
                startContact(conn)

                # remote側も同じチャットを開けるようにremoteにlocal側のscheduleを渡す
                connect_data = [schedule_id, "start_flag"]
                conn.send(connect_data)

            # conn.on 'error', (e) ->
            # errorになる条件が不明

        else if localPeerConnect == "false"
            openLocalPeer(peer)
            if localPeerConnect == "true"
                alert("もっかい押して")

    # 接続リクエスト受信
    peer.on 'connection', (conn) ->
        conn.on 'open', ->
            startContact(conn)

        # conn.on 'error', (e) ->
        # errorになる条件が不明

    # ビデオ発信
    $('#call_video').on 'click', ->
        call = peer.call(contact_id, window.localStream)
        remoteUserMedia(call)

    # ビデオ着信
    peer.on 'call', (call) ->
        call.answer(window.localStream)
        remoteUserMedia(call)

    # 接続終了時の処理
    $(window).on 'beforeunload', () ->
        destroyFlag = "true"
        peer.destroy()
        "画面を離れてもよろしいですか?" + peer.id
