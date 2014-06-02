# attaches to a ENGINE.Rage_letter and modifies it based on some stuff...
# class ENGINE.Base_Animation_Mod_Container extends Array
    # maybe later..., i was thikning that i don't want multiple
    # of the same mods affecting the same letter and i need some 
    # way to track taht but now i don't care

class ENGINE.Base_Animation_Mod

    b_animation: undefined
    type: undefined # some random modifier name
    applied: false
    id: undefined

    constructor: (@b_animation, @type) ->
        if !@type?
            @assign_type();
        @id = _.uniqueId('mod');

    # Convenience accessors
    lifespan: () => return @b_animation.lifespan;
    time_passed: () => return @b_animation.time_passed;
    model: () => return @b_animation.model

    # ... makes perfect sense...
    RAND_RGB = "rr"
    LIVE_LONGER = "ll"
    SHRINK = "s"
    EXPAND = "e"
    DISTORT = "d"
    SIGN_DISTORT = "sd"
    WIREFRAME = "w"
    BROKEN_TRANSPARENT = "t"
    FADE_TO_BLACK = "fb"
    FADE_TO_D_BLUE = "fdb"
    FADE_TO_D_GREEN = "fdg"

    BACKGROUND_COLOR = "#101010"

    assign_type: () =>
        @type = _.sample([FADE_TO_D_BLUE, FADE_TO_D_BLUE, FADE_TO_BLACK, FADE_TO_BLACK, LIVE_LONGER])
        # @type = _.sample([RAND_RGB, LIVE_LONGER, SHRINK, EXPAND])
        # @type = _.sample([RAND_RGB, LIVE_LONGER, SHRINK, EXPAND, DISTORT, WIREFRAME])

    # remove_self: () =>
    #     len = @b_animation.mods.length
    #     i = 0
    #     console.log(@b_animation.mods);
    #     while i < len
    #         if @b_animation.mods[i] == @
    #             @b_animation.mods.splice i--, 1
    #             len--
    #         i++
        # console.log(@b_animation.mods);

        # @b_animation.mods = _.reject(@b_animation.mods, (elem) ->
            # elem == @
            # ) 

    remove_on_redundancy: () =>
        if @mod_redundant()
            @applied = true

    mod_redundant: () =>
        for mod in @b_animation.mods
            if mod.id != @id
                if mod.type == @type and !mod.applied
                    return true;
        return false;

    fade_color: () =>
        val =  switch @type
            when FADE_TO_BLACK then 0x000000
            when FADE_TO_D_BLUE then 0x000022
            when FADE_TO_D_GREEN then 0x002200
        return val

    apply: () =>
        if !@applied
            # Randomly rgb colorize the whole letter
            if @type is RAND_RGB
                rand_color = _.sample(["0xff0000", "0x00ff00", "0x0000ff"])
                if @model()
                    @model().material.materials[0].color.setHex(rand_color)
                    @model().material.materials[1].color.setHex(rand_color)
                @applied = true
            # make the letter live longer
            if @type is LIVE_LONGER
                @b_animation.lifespan += Math.random() * 9
                @applied = true
            # make the letter smaller slowly
            if @type is SHRINK
                if !@model()
                    return;
                percent_complete = @time_passed() / @lifespan()
                shrink_percent = .70 # shrink to 70% of actual value
                shrink_progress = (1 - shrink_percent) * percent_complete
                shrink_scale = 1 - shrink_progress

                @apply_scale(shrink_scale)

                if shrink_scale < shrink_percent
                    @applied = true;
            # make the letter expand
            if @type is EXPAND
                if !@model()
                    return;
                percent_complete = @time_passed() / @lifespan()
                shrink_percent = 1.3 # shrink to 70% of actual value
                shrink_progress = (shrink_percent - 1) * percent_complete
                shrink_scale = 1 + shrink_progress

                @apply_scale(shrink_scale)

                if shrink_scale > shrink_percent
                    @applied = true;
            # change it to a wireframe
            if @type is WIREFRAME
                if @model() is undefined
                    return
                wireframeMaterial = new THREE.MeshBasicMaterial( { color: 0x000011, wireframe: true, transparent: true } )
                @model().material = wireframeMaterial;
                @applied = true;
            if @type is DISTORT
                @remove_on_redundancy()
                if @model() is undefined
                    return 
                if percent_chance(55)
                    return 
                for v in @model().geometry.vertices
                    distort_factor = .4
                    v.x -= _.random(-distort_factor, distort_factor);
                    v.y += _.random(-distort_factor, distort_factor);
                @model().geometry.verticesNeedUpdate = true;
            if @type is SIGN_DISTORT
                @remove_on_redundancy()

                if @model() is undefined
                    return 
                if percent_chance(40)
                    return 
                for v in @model().geometry.vertices
                    distort_factor = Math.sin(@time_passed()) * .005
                    v.x -= _.random(-distort_factor * 3.5, distort_factor);
                    v.y += _.random(-distort_factor * 3.5, distort_factor);
                @model().geometry.verticesNeedUpdate = true;
            if @type is BROKEN_TRANSPARENT
                @remove_on_redundancy()
                if @model() is undefined
                    return
                @model().material.materials[0] = new THREE.MeshNormalMaterial( { transparent: true, opacity: 0.5 } );
                @applied = true;
            if @type is FADE_TO_BLACK or @type is FADE_TO_D_GREEN  or @type is FADE_TO_D_BLUE
                @remove_on_redundancy()
                if @model() is undefined
                    return
                black = undefined
                percent_complete = @time_passed() / @lifespan()
                black = new THREE.Color(@fade_color())
                # black = new THREE.Color(@fade_color())
                # console.log("fading #{percent_complete}")

                if @model().material.materials?
                    @model().material.materials[0].color.lerp(black, .049 * percent_complete)
                    @model().material.materials[1].color.lerp(black, .049 * percent_complete)
                else 
                    @model().material.color.lerp(black, .01 * percent_complete)
                

    apply_scale: (shrink_scale) =>
        model = @model()
        model.scale.x = shrink_scale
        model.scale.y = shrink_scale
        model.scale.z = shrink_scale
    

