extends Node2D

signal sailor_pressed(sailor)

var path: Array = []
var target = null
var speed = 200

onready var sprite = $AnimatedSprite
onready var button = $Button

var hole_to_repair = null
var is_repairing = false
var is_selected = false

func _ready():
    sprite.play('idle')
    button.connect("pressed", self, '_on_button_pressed')
    button.connect('mouse_entered', self, '_on_button_mouse_entered')
    button.connect('mouse_exited', self, '_on_button_mouse_exited')
    $Cursor.visible = false


func _on_button_mouse_entered():
    if not is_selected:
        $Cursor.visible = true
        $Cursor.playing = false
        $Cursor.frame = 0
    
    
func _on_button_mouse_exited():
    if not is_selected:
        $Cursor.visible = false


func _on_button_pressed():
    emit_signal('sailor_pressed', self)


func select():
    is_selected = true
    $Cursor.visible = true
    $Cursor.playing = true
    $Cursor.frame = 0
    
    
func deselect():
    is_selected = false
    $Cursor.visible = false
    $Cursor.playing = false
    $Cursor.frame = 0


func clear_hole():
    hole_to_repair = null


func repair_hole(hole, a_star: AStar2D):
    var t = a_star.get_point_position(a_star.get_closest_point(Vector2(hole.position.x, hole.y_level)))
    set_target(t, a_star, false if hole.position.y == hole.y_level - 32 else true)
    hole_to_repair = hole


func set_target(target_to: Vector2, a_star: AStar2D, pop_last = false):
    _stop_repairing()
    path = Array(a_star.get_point_path(
        a_star.get_closest_point(position),
        a_star.get_closest_point(target_to)
    ))
    
    if path.size() > 1:
        target = path.pop_front()
        if pop_last:
            path.pop_back()
    else:
        target = null
        if hole_to_repair != null:
            _start_repairing_hole()
            
            
            
func _start_repairing_hole():
    if hole_to_repair != null and is_instance_valid(hole_to_repair) and not hole_to_repair.repairing:
        hole_to_repair.repairing = true
        is_repairing = true
        hole_to_repair.connect('tree_exited', self, '_stop_repairing')
    else:
        hole_to_repair = null
        is_repairing = false


func _stop_repairing():
    if is_instance_valid(hole_to_repair):
        hole_to_repair.repairing = false
        hole_to_repair.disconnect('tree_exited', self, '_stop_repairing')
    is_repairing = false
    hole_to_repair = null


func _physics_process(delta):
    if is_repairing:
        sprite.play('use')
        return
        pass
    
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
            if hole_to_repair != null:
                _start_repairing_hole()
            
        sprite.play('walk')
    else:
        sprite.play('idle')
