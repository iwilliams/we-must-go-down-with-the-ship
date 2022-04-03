extends Node2D

signal cannon_fired


var direction = 1
var speed = 10



func _ready():
    speed = speed * rand_range(.6, 1.4)
    $Timer.wait_time = $Timer.wait_time * rand_range(.6, 1.4)
    if direction == -1:
        $Sprite.scale.x = -1
    $Timer.connect("timeout", self, '_on_timer_timeout')
    $Timer.start()


func _on_timer_timeout():
    if (direction > 0 and position.x > 0) or (direction < 0 and position.x < GameManager.max_x):
        $Sprite/CPUParticles2D.emitting = true
        $AudioStreamPlayer.play()
        emit_signal("cannon_fired")
        yield(get_tree().create_timer(.4), 'timeout')
        $AudioStreamPlayer2.play()


func _physics_process(delta):
    position.x += speed * direction * delta
    
    if (direction > 0 and position.x > GameManager.max_x + 32) or (direction < 0 and position.x < -32):
        queue_free()
