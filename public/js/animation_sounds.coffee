class ENGINE.Animation_Sounds

    @chimes: []

    @test: ->
        # testStr = getChime(10)
        # audio = new Audio(testStr)
        # console.log("trying to play #{testStr}");
        # audio.play();

    # wrapper that makes it easier to modify for WWW folder permissions
    getFile = (filename) ->
        return "/audio/" + filename
        # return "audio/" + filename

    # chiem from 1 - 24
    # there's no 17 for some reason..
    getChime = (num) ->
        numStr;
        if num < 10 
            numStr = "0" + num
        else
            numStr = num
        return getFile("radian__chime-00" + numStr + ".wav")

    # Setup the audio elements so i don't have to keep recreating them
    for num in [1..24]
        testStr = getChime(num)
        audio = new Audio(testStr)
        # console.log("trying to play #{testStr}");
        audio.volume = .5
        @chimes[num] = audio


    letterToChimeHash = (lower, upper, letter) ->
        range = upper - lower + 1
        code = letter.charCodeAt(0);
        result = lower + (code % range) ;
        # console.log("lower #{lower}, upper #{upper}, letter #{letter}, result: #{result}")
        return result;

    @createPlayChime: (chimeNum) ->
        if chimeNum == 17 
            return
        if percent_chance(30)
            audio = new Audio(getChime(chimeNum));
            audio.volume = Math.random();
            @chimes[chimeNum] = audio;
        # console.log(chimeNum)
        @chimes[chimeNum].play();

    @playChime: (chimeNum) ->
        @createPlayChime(chimeNum)

    @playRandomChime: () ->
        @playChime(_.random(1,24))

    @playHighChime: (letter) ->
        @playChime(letterToChimeHash(15,24,letter))
        # @playChime(_.random(13,20))

    @playLowChime: (letter) ->
        @playChime(letterToChimeHash(1,10,letter))
        # @playChime(_.random(1,6))






