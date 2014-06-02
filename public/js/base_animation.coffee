
# Enables the spewing of letters everywhere!
class ENGINE.Base_Animation extends ENGINE.Entity

    lifespan: undefined # in seconds. clock.getDelta returns thousands of seconds...
    time_passed: 0
    letter: 'X' #
    mods: [] # ENGINE.Base_Animation_Mod
    type: undefined # some kind of animation type

    # Because screw proper code factoring
    @get_random_animation: ->
        rl = _.sample(ENGINE.base_animations);
        # console.log("random letter #{rl.letter}")
        return rl

    constructor: (args) ->
        super(args)
        # console.log("made letter #{@letter}")

    # ======= Basic templating code ======
    full_remove: () =>
        ENGINE.threeScene.remove(@model)
        # ENGINE.Key_Manager.update_twitter_link();
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

            @model = @get_text_mesh();
            # @model = @get_sphere_mesh();
            ENGINE.threeScene.add(@model);

            # geometry = new THREE.SphereGeometry( 30, 32, 16 );
            # material = new THREE.MeshLambertMaterial( { color: 0x000088 } );
            # mesh = new THREE.Mesh( geometry, material );
            # mesh.position.set(0,0,0);
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
        @mods.push(new ENGINE.Base_Animation_Mod(@))
        return @

    live_longer: () =>
        LIVE_LONGER = "ll"
        @mods.push(new ENGINE.Base_Animation_Mod(@, LIVE_LONGER))

    add_mod: (mod_name) =>
        @mods.push(new ENGINE.Base_Animation_Mod(@, mod_name))
        return @


    get_text_mesh: () =>
            # // add 3D text
            materialFront = new THREE.MeshBasicMaterial( { color: 0xffffff } );
            # materialSide = new THREE.MeshBasicMaterial( { color: 0xff0000 } );
            materialSide = new THREE.MeshBasicMaterial( { color: 0xdddddd } );
            # materialSide = new THREE.MeshBasicMaterial( { color: 0x101010 } );
            materialArray = [ materialFront, materialSide ];
            textGeom = new THREE.TextGeometry( @letter, 
            


            {
                size: 20 + _.random(0,20) , height: 20, curveSegments: 5,
                font: "helvetiker", weight: "normal", style: "normal",
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
            randX = _.random(-40, 40)
            randY = _.random(0, 10)
            randZ = _.random(-40, 40)

            textMesh.position.set( -0.5 * textWidth + randX, randY, .5 * textHeight + randZ);

            return textMesh

    get_sphere_mesh: () =>
        geometry = new THREE.SphereGeometry( 30, 32, 16 );
        material = new THREE.MeshLambertMaterial( { color: 0x000088 } );
        mesh = new THREE.Mesh( geometry, material );
        randX = _.random(-40, 40)
        randY = _.random(0, 5)
        randZ = _.random(-40, 40)
        mesh.position.set(randX, randY, randZ);
        return mesh;
