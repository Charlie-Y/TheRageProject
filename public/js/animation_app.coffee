# console.log("nexus.js")



# // standard global variables
keyboard = new THREEx.KeyboardState();
clock = new THREE.Clock();
container = undefined
scene = undefined
camera = undefined
renderer = undefined
controls = undefined


# // custom global variables


init = () -> 
    # // SCENE
    scene = new THREE.Scene();
    ENGINE.threeScene = scene;
    # // CAMERA
    SCREEN_WIDTH = window.innerWidth
    SCREEN_HEIGHT = window.innerHeight;
    VIEW_ANGLE = 45
    ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT
    NEAR = 0.1
    FAR = 20000
    camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR);
    ENGINE.threeCamera = camera
    scene.add(camera);
    camera.position.set(0,100,70);
    # camera.position.set(40,120,70);
    # camera.position.set(0,150,400);

    camera.lookAt(scene.position);  
    renderer = new THREE.WebGLRenderer( {antialias:true} );
    ENGINE.threeRenderer = renderer
    renderer.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    container = document.getElementById( 'ThreeJS' );
    container.appendChild( renderer.domElement );
    # // EVENTS
    THREEx.WindowResize(renderer, camera);
    # THREEx.FullScreen.bindKey({ charCode : 'm'.charCodeAt(0) });
    ENGINE.Key_Manager.ks = keyboard
    # // CONTROLS
    controls = new THREE.OrbitControls( camera, renderer.domElement );
    ENGINE.threeControls = controls
    # // LIGHT
    light = new THREE.PointLight(0xffffff);
    light.position.set(100,250,100);
    scene.add(light);
    # // FLOOR
    # floorTexture = new THREE.ImageUtils.loadTexture( 'images/blank.png' );
    # floorTexture = new THREE.ImageUtils.loadTexture( 'images/checkerboard.jpg' );
    # floorTexture.wrapS = floorTexture.wrapT = THREE.RepeatWrapping; 
    # floorTexture.repeat.set( 10, 10 );
    # floorMaterial = new THREE.MeshBasicMaterial( { color: 0xffffff, side: THREE.DoubleSide } );
    floorMaterial = new THREE.MeshBasicMaterial( { color: 0x101010, side: THREE.DoubleSide } );
    # floorMaterial = new THREE.MeshBasicMaterial( { color: 0x0e0f1a, side: THREE.DoubleSide } );
    # floorMaterial = new THREE.MeshBasicMaterial( { map: floorTexture, side: THREE.DoubleSide } );
    floorGeometry = new THREE.PlaneGeometry(2000, 2000, 10, 10);
    floor = new THREE.Mesh(floorGeometry, floorMaterial);
    floor.position.y = -0.5;
    floor.rotation.x = Math.PI / 2;
    scene.add(floor);
    # // SKYBOX
    skyBoxGeometry = new THREE.CubeGeometry( 10000, 10000, 10000 );
    skyBoxMaterial = new THREE.MeshBasicMaterial( { color: 0x222241, side: THREE.BackSide } );
    # skyBoxMaterial = new THREE.MeshBasicMaterial( { color: 0x9999ff, side: THREE.BackSide } );
    skyBox = new THREE.Mesh( skyBoxGeometry, skyBoxMaterial );
    scene.add(skyBox);
    
    # ////////////
    # // CUSTOM //
    # ////////////

    # axisHelper = new THREE.AxisHelper( 5000 );
    # scene.add( axisHelper );
    
    # geometry = new THREE.SphereGeometry( 30, 32, 16 );
    # material = new THREE.MeshLambertMaterial( { color: 0x000088 } );
    # mesh = new THREE.Mesh( geometry, material );
    # mesh.position.set(0,0,0);
    # scene.add(mesh);
    
    ENGINE.Init();

animate = () ->
    requestAnimationFrame( animate );
    render();       
    delta = clock.getDelta();
    update(delta);


update = (delta) ->
    ENGINE.update(delta)
    controls.update();

render = () ->
    ENGINE.render();
    renderer.render( scene, camera );

# ENGINE.sounds = new ENGINE.Collection(ENGINE);
ENGINE.base_animations = new ENGINE.Collection(ENGINE);
# Redfine the clean as to update the twitter link properluy
ENGINE.base_animations.clean = () ->
    len = @length
    i = 0
    while i < len
        if this[i]._remove
            ENGINE.Animation_Sounds.playHighChime(this[i].letter);
            @splice i--, 1
            len--
        i++
    ENGINE.Key_Manager.update_twitter_link();

# ENGINE.global_animations = new ENGINE.Collection(ENGINE);

ENGINE.Init = () ->
    console.log("Engine Init")
    document.addEventListener("keydown", ENGINE.Key_Manager.keydown, false);
    document.addEventListener("keyup", ENGINE.Key_Manager.keyup, false);

    # ENGINE.base_animations.add(ENGINE.Base_Animation, {lifespan: 10}).add_mod("fb").add_mod("fb")
    

ENGINE.render = () ->
    ENGINE.base_animations.call('render', undefined);

    # @sounds.call('render', undefined);
    # @global_animations.call('render', undefined);

ENGINE.update = (delta) ->
    #step clears out things that need to be deleted
    # ENGINEsounds.step(delta);
    # @rage_letters.step(delta);
    # @global_animations.step(delta);
    # if ENGINE.Key_Manager.ks.pressed('t')
    #     console.log("Delta: #{delta}")
    # if ENGINE.Key_Manager.ks.pressed('c')
    #     console.log("Num letters: #{ENGINE.rage_letters.length}")

    # @sounds.call('step', delta);
    ENGINE.base_animations.call('step', delta);
    ENGINE.base_animations.step();
    # @global_animations.call('step', delta);



init();
animate();




###

Things that need to come together and incrementally

animations

keyboard manager
    - associating keys/combinations of keys to actions - A
    - determining when things will happen based on key combinations


base animations - letters spewing
    A: Creation - DONE 

    A: modifications
        change color
        get bigger, smaller
        flash, wireframe,
        lasts longer on the screen

global animations
    A: creation
        screen flashing
        color changing
        sliding etc

base sound
    A: creation
    A: modification
        change pitch
        elongate
        repeat
        flash
        stutter

# it should consider tweeting it out


###


























