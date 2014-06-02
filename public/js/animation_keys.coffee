# wrapper class for all the keyboard functions etc..
class ENGINE.Key_Manager

    @ks: undefined; # threex.keyboardstate
    @lock: false; 
    @pressed_keys: []

    @key_log: [] # store all the keys

    # Handle the DOM event and get the key
    @keydown: (event) ->
        key = event.key || event.keyCode || event.which
        if key is 8 or key is 9 or key is 91 # prevent backspace from going back
            event.preventDefault();
        e_km.handle_key_down(key);
        return false;

    @keyup: (event) ->
        key = event.key || event.keyCode || event.which
        e_km.handle_key_up(key);
        return false;

    @enough_keys_pressed: () ->
        return @pressed_keys.length > 3

    @handle_key_up: (key) ->
        @pressed_keys = _.reject(@pressed_keys, (elem) -> 
            elem == key
            )

    @log_key: (key) ->
        @key_log.push(key);

    window.percent_chance = (percent) ->
        return _.random(0,100) <= percent

    @handle_key_down: (key) ->
        @pressed_keys.push(key)
        # if not @enough_keys_pressed()
            ## console.log("not enough keys");
            # return;


        letter = @string_for_key(key)
        if letter is NULL_STRING
            return;

        if @dont_update_twitter_block
            return;


        @log_key(letter)
        if @base_animations_count() > 0 and percent_chance(80)
            random_letter = ENGINE.Base_Animation.get_random_animation()
            random_letter.add_random_modifier();
            if percent_chance(80)
                random_letter.live_longer();
        # # else 
        ENGINE.base_animations.add(ENGINE.Base_Animation, {lifespan: .4, letter:letter}).add_random_modifier().add_random_modifier();
        # ENGINE.rage_letters.add(ENGINE.Rage_Letter, {lifespan: 2, letter:letter})
        # ENGINE.Rage_Sound.test() 
        @update_twitter_link();
        if percent_chance(70)
            ENGINE.Animation_Sounds.playLowChime(letter);


    @base_animations_count: () ->
        return ENGINE.base_animations.length;

    NULL_STRING = "meh"

    @string_for_key: (key) ->
        str
        if 48 <= key <= 90
            str = String.fromCharCode(key);
            if !@ks.pressed('shift')
                str = str.toLowerCase();
        else 
            # noCode[key] = 1
            str = NULL_STRING
            # str = switch key
                # when 189 then '\\'
                # when 190 then '\\'
        return str

    t_link = document.querySelector('#twitter-btn')
    t_img = document.querySelector('#twitter-bird')
    t_count = document.querySelector('#twitter-count')
    # f_url = encodeURIComponent("http://stanford.edu/~charlesy/mash")
    f_url = encodeURIComponent("http://t.co/Lmxob5C0DE")

    @dont_update_twitter_block: false

    @update_twitter_link: () ->
        numLiveKeys = @base_animations_count();

        if @dont_update_twitter_block
            if numLiveKeys == 0
                @dont_update_twitter_block = false
                t_img.src = "/images/bird_gray_48.png"
                @update_twitter_link()
            return;

        t_count.innerText = numLiveKeys
        # t_count.innerText = @key_log.length;

        percent_color = numLiveKeys / 140;
        base_color = new THREE.Color(0xe7e7e7);
        blue_color = new THREE.Color(0x00acee);
        
        final_color = base_color.lerp(blue_color, percent_color).getHexString();

        # console.log("numLiveKeys: #{numLiveKeys}, final_color: #{final_color}")

        t_count.style.color = "#" + final_color;


        if numLiveKeys >= 140
            t_count.innerText = 140
            t_count.style.color = "#00acee"
            t_link.disabled = false;
            t_img.src = "/images/bird_blue_48.png"
            @win_sequence();

        # last_140 = _.last(@key_log, 140 - f_url.length).join("")
        # t_link.href = "https://twitter.com/intent/tweet?text=" + last_140 + "&url=" + f_url
        # link.href = "https://twitter.com/intent/tweet?via=maSHA512_224&text=" + last_140

    @win_sequence: () ->
        @dont_update_twitter_block = true;
        last_140 = encodeURIComponent(_.last(@key_log, 140).join(""));
        
        please = " Don't abuse this url :)";

        $.ajax({
            dataType:'json'
            type:"get"
            url: "http://cs-147-test.herokuapp.com/tweet?s=" + last_140;
            success: (data) ->
                console.log(data);
            })
        # So this fails, but the request still goes through


e_km = ENGINE.Key_Manager
window.noCode = {}