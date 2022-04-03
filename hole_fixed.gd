extends Node2D


func _ready():
    $AudioStreamPlayer2D.play()
    yield($AudioStreamPlayer2D, 'finished')
    queue_free()

func _physics_process(delta):
    position.y -= 20 * delta
