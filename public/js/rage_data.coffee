# attaches to a ENGINE.Rage_letter and modifies it based on some stuff...
class ENGINE.Rage_Letter_Mod_Container extends Array
    # maybe later..., i was thikning that i don't want multiple
    # of the same mods affecting the same letter and i need some 
    # way to track taht but now i don't care

class ENGINE.Rage_Letter_Mod

    letter: undefined
    type: undefined # some random modifier name
    applied: false

    constructor: (@letter) ->
        @assign_type();

    # Convenience accessors
    lifespan: () => return @letter.lifespan;
    time_passed: () => return @letter.time_passed;
    model: () => return @letter.model

    # ... makes perfect sense...
    RAND_RGB = "rr"
    LIVE_LONGER = "ll"
    SHRINK = "s"
    EXPAND = "e"
    DISTORT = "d"
    WIREFRAME = "w"

    assign_type: () =>
        @type = _.sample([WIREFRAME])
        # @type = _.sample([RAND_RGB, LIVE_LONGER, SHRINK, EXPAND])
        # @type = _.sample([RAND_RGB, LIVE_LONGER, SHRINK, EXPAND, DISTORT, WIREFRAME])

    remove_self: () =>
        @letter.mods = _.reject(@letter.mods, (elem) ->
            elem == @
            ) 

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
                @letter.lifespan += .4
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
                wireframeMaterial = new THREE.MeshBasicMaterial( { color: 0x00ee00, wireframe: true, transparent: true } )
                @model().material = wireframeMaterial;
                @applied = true;

    apply_scale: (shrink_scale) =>
        model = @model()
        model.scale.x = shrink_scale
        model.scale.y = shrink_scale
        model.scale.z = shrink_scale
    

# Enables the spewing of letters everywhere!
class ENGINE.Rage_Letter extends ENGINE.Entity

    lifespan: undefined # in seconds. clock.getDelta returns thousands of seconds...
    time_passed: 0
    letter: 'X' #
    mods: [] # ENGINE.Rage_Letter_Mod s

    # Because screw proper code factoring
    @get_random_letter: ->
        rl = _.sample(ENGINE.rage_letters);
        # console.log("random letter #{rl.letter}")
        return rl

    constructor: (args) ->
        super(args)
        # console.log("made letter #{@letter}")

    # ======= Basic templating code ======
    full_remove: () =>
        ENGINE.threeScene.remove(@model)
        @remove();

    time_left: () =>
        return @lifespan - @time_passed

    step: (delta) =>
        # console.log("Lifespan #{@lifespan}")
        if @time_left() < 0
            # console.log("Removing")
            @full_remove();

        if @time_left() > 0
            @time_passed += delta

    render: () =>
        if @model is undefined
            # // add 3D text
            materialFront = new THREE.MeshBasicMaterial( { color: 0xffffff } );
            # materialSide = new THREE.MeshBasicMaterial( { color: 0xff0000 } );
            # materialSide = new THREE.MeshBasicMaterial( { color: 0xdddddd } );
            materialSide = new THREE.MeshBasicMaterial( { color: 0x101010 } );
            materialArray = [ materialFront, materialSide ];
            textGeom = new THREE.TextGeometry( @letter, 
            {
                size: 40, height: 8, curveSegments: 5,
                font: "helvetiker", weight: "bold", style: "normal",
                # bevelThickness: 2, bevelSize: 1, bevelEnabled: true,
                material: 0, extrudeMaterial: 1
            });
            # font: helvetiker, gentilis, droid sans, droid serif, optimer
            # weight: normal, bold
            textMaterial = new THREE.MeshFaceMaterial(materialArray);
            textMesh = new THREE.Mesh(textGeom, textMaterial );
            textGeom.computeBoundingBox();
            textWidth = textGeom.boundingBox.max.x - textGeom.boundingBox.min.x;
            textHeight = textGeom.boundingBox.max.y - textGeom.boundingBox.min.y;
            textMesh.rotation.x = -Math.PI / 2;

            # textMesh.position.set( -0.5 * textWidth, 0 , 0 );
            randX = _.random(-20, 20)
            randY = _.random(0, 30)
            randZ = _.random(-20, 20)

            textMesh.position.set( -0.5 * textWidth + randX, 0, .5 * textHeight + randZ);

            @model = textMesh

            # geometry = new THREE.SphereGeometry( 30, 32, 16 );
            # material = new THREE.MeshLambertMaterial( { color: 0x000088 } );
            # mesh = new THREE.Mesh( geometry, material );
            # mesh.position.set(0,0,0);
            ENGINE.threeScene.add(textMesh);
        else 
            @apply_mods()

    # ====== Modifier code =======

    has_mods: () =>
        return @mods.length > 0

    apply_mods: () =>
        if @has_mods()
            # console.log("apply_mods")
            for mod in @mods
                mod.apply();

    add_random_modifier: () =>
        # console.log("adding random modifier to #{@letter}")
        @mods.push(new ENGINE.Rage_Letter_Mod(@))


class ENGINE.Rage_Sound 

    @test: ->
        audio = new Audio('/audio/inception.mp3')
        audio.play();
