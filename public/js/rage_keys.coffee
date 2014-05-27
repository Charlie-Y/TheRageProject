# wrapper class for all the keyboard functions etc..
class ENGINE.Key_Manager

    @ks: undefined; # threex.keyboardstate
    @lock: false; 
    @pressed_keys: []

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

    percent_chance = (percent) ->
        return _.random(0,100) <= percent

    @handle_key_down: (key) ->
        @pressed_keys.push(key)
        # if not @enough_keys_pressed()
            ## console.log("not enough keys");
            # return;
        letter = @string_for_key(key)
        # console.log("Key down #{key} - #{letter}");
        # console.log("Key down #{letter}");
        # if @rage_letter_count() > 0 and percent_chance(0)
        #     random_letter = ENGINE.Rage_Letter.get_random_letter()
        #     random_letter.add_random_modifier();
        # else 
        # ENGINE.rage_letters.add(ENGINE.Rage_Letter, {lifespan: 2, letter:letter})
        ENGINE.rage_letters.add(ENGINE.Rage_Letter, {lifespan: 2, letter:letter}).add_random_modifier();


    @rage_letter_count: () ->
        return ENGINE.rage_letters.length;

    @string_for_key: (key) ->
        str = "foo"
        if 48 <= key <= 90
            str = String.fromCharCode(key);
        else 
            # noCode[key] = 1
            str = "F"
            # str = switch key
                # when 189 then '\\'
                # when 190 then '\\'



        return str


e_km = ENGINE.Key_Manager
window.noCode = {}