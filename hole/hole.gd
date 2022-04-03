extends Node2D

signal hole_pressed(hole)
signal hole_fixed

var repairing = false
var repair = 0.0

var is_hovering = false

var y_level
onready var button: TextureButton = $Button

var hole_fixed_scene = preload("res://hole/hole_fixed.tscn")


var percentage = 0.0

func _ready():
    var tile_position = (position.y - 16.0) / 16.0
    var min_tile = GameManager.min_tile
    var max_tile = GameManager.max_tile
    percentage = range_lerp(tile_position, min_tile, max_tile, 1, 0)
    self.connect("tree_exiting", GameManager, 'remove_hole', [self])
    button.connect("pressed", self, '_on_button_pressed')

    button.connect('mouse_entered', self, 'set', ['is_hovering', true])
    button.connect('mouse_exited', self, 'set', ['is_hovering', false])
    $AudioStreamPlayer2D.play()


func _on_button_pressed():
    emit_signal('hole_pressed', self)
    

func _physics_process(delta):
    if is_hovering and GameManager.selected_sailor != null and not repairing:
        $Cursor.visible = true
        $Cursor.playing = true
    else:
        $Cursor.visible = false
    
    
    if repairing:
        repair += .1 * delta
        
    if repair > 1.0:
        var hole_fixed = hole_fixed_scene.instance()
        hole_fixed.position = position
        get_parent().get_parent().add_child(hole_fixed)
        emit_signal("hole_fixed")
        queue_free()
    elif repair > .75:
        $Sprite.frame = 3
    elif repair > .5:
        $Sprite.frame = 2
    elif repair > .25:
        $Sprite.frame = 1
    else:
        $Sprite.frame = 0
    
    $Label.text = str(percentage)
        
    if percentage < GameManager.fillage:
        queue_free()


        
