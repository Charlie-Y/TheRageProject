# Create the global entity
window.ENGINE = {};

class ENGINE.Entity 
    # === Class Properties === #

    # === Class Methods === #

    # ==== Constructor === #

    constructor: (args) ->
        _.extend(@, args)

        if @oncreate
            @oncreate()

    # === Instance Properties === #
    x: undefined
    y: undefined
    z: undefined
    pos: undefined #position as a node or position as something else
    _remove: false # if it should be removed by a collection
    collection: undefined # what collection it belongs to, added later
    model: undefined # the scene model

    # === Instance Methods === #

    # -- Step --
    # updates the inner data in a meaningful way
    step: (delta) ->
        console.log("Entity step() needs to be defined");

    # -- Render --
    # updates the scene and all the scene related variables
    render: (delta) ->
        console.log("Entity render() needs to be defined");

    updateModelPosition: () ->
        if @model?
            @model.position.set(@x,@y,@z)

    # returns a THREE.Vector3 based on the obj data
    positionFromData: () ->
        return new THREE.Vector3(@x, @y, @z)

    remove: ->
        this._remove = true;
        this.collection.dirty = true;

# Collections are arrays with some extra entity management
class ENGINE.Collection  extends Array
    # === Class Properties === #

    # === Class Methods === #

    # ==== Constructor === #

    constructor: (@parent) ->
        @index = 0
        @dirty = false;

        if this.oncreate
            this.oncreate()

    # === Instance Properties === #

    parent: undefined # something that manages the collection, a scene or something
    index: undefined
    dirty: false

    # === Instance Methods === #

    # Add an entity with the given args
    add: (constructor, args) ->
        entity = new constructor(_.extend({
            collection: @,
            index: this.index++
            }, args))
        @push(entity)
        return entity;

    clean: ->
        len = @length
        i = 0
        while i < len
          if this[i]._remove
            @splice i--, 1
            len--
          i++

    step: (delta) ->
        if (@dirty)
            @dirty = false
            @clean();
            @.sort( (a,b) ->
                return (a.zIndex | 0) - (b.zIndex | 0)
                )

    # call methods on all entities without args
    call: (method) ->
        args = Array.prototype.slice.call(arguments, 1);
        i = 0
        len = @length

        while i < len
          this[i][method].apply this[i], args  if this[i][method]
          i++

    apply: (method, args) ->
        i = 0
        len = @length

        while i < len
          this[i][method].apply this[i], args  if this[i][method]
          i++

