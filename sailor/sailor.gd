extends Node2D

signal sailor_pressed(sailor)

var path: Array = []
var target = null
var speed = 200

onready var sprite = $AnimatedSprite
onready var button = $Button

func _ready():
    sprite.play('idle')
    button.connect("pressed", self, '_on_button_pressed')



func _on_button_pressed():
    emit_signal('sailor_pressed', self)


func set_target(target_to: Vector2, a_star: AStar2D):
    path = Array(a_star.get_point_path(
        a_star.get_closest_point(position),
        a_star.get_closest_point(target_to)
    ))
    
    if path.size() > 1:
        target = path.pop_front()
    else:
        target = null



func _physics_process(delta):
    if target != null:
        if position.x < target.x:
            position.x += speed * delta
            position.x = min(target.x, position.x)
            sprite.scale.x = 1
        elif position.x > target.x:
            position.x -= speed * delta
            position.x = max(target.x, position.x)
            sprite.scale.x = -1
            
        if position.y < target.y:
            position.y += speed * .5 * delta
            position.y = min(target.y, position.y)
        elif position.y > target.y:
            position.y -= speed * .5 * delta
            position.y = max(target.y, position.y)

            
        if position.is_equal_approx(target) and path.size() > 0:
            target = path.pop_front()
        elif position.is_equal_approx(target) and path.size() == 0:
            target = null
            
        sprite.play('walk')
    else:
        sprite.play('idle')
