extends Node2D

signal hole_pressed(hole)

var repairing = false
var repair = 0.0

var y_level
onready var button: TextureButton = $Button


var percentage = 0.0

func _ready():
    var tile_position = (position.y - 16.0) / 16.0
    var min_tile = GameManager.min_tile
    var max_tile = GameManager.max_tile
    percentage = range_lerp(tile_position, min_tile, max_tile, 1, 0)
    self.connect("tree_exiting", GameManager, 'remove_hole', [self])
    button.connect("pressed", self, '_on_button_pressed')
    
func _on_button_pressed():
    emit_signal('hole_pressed', self)
    
    
func _physics_process(delta):
    if repairing:
        repair += .1 * delta
        
    if repair > 1.0:
#        GameManager.remove_hole(self)
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


        
