extends Node2D

signal hole_pressed(hole)

var repairing = false
var repair = 0.0

var y_level
onready var button: TextureButton = $Button

func _ready():
    button.connect("pressed", self, '_on_button_pressed')
    
func _on_button_pressed():
    emit_signal('hole_pressed', self)
    
    
func _physics_process(delta):
    if repairing:
        repair += .1 * delta
        print(repair)
        
    if repair > 1.0:
        GameManager.remove_hole(self)
        queue_free()
    elif repair > .75:
        $Sprite.frame = 3
    elif repair > .5:
        $Sprite.frame = 2
    elif repair > .25:
        $Sprite.frame = 1
    else:
        $Sprite.frame = 0

        
