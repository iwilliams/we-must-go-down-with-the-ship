extends Node2D

var speed = 100

func _ready():
    speed = speed * rand_range(.5, 1.5)

func _physics_process(delta):
    position.y -= 100 * delta
    if global_position.y < 0:
        queue_free()
