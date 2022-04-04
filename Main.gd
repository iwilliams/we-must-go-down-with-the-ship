extends Control

signal game_ended

onready var a_star = AStar2D.new()

var vector_map = {}

onready var score_timer = $ScoreTimer
onready var ship_timer = $Control/Main/ShipTimer
onready var enemies_container = $Enemies
onready var holes_container = $Control/Main/Holes
onready var sailors_container = $Control/Main/Sailors
onready var sailors = sailors_container.get_children()
onready var floors = $Control/Main/Floors.get_children()
onready var ladders = $Control/Main/Ladders.get_children()
onready var move_cursor_container = $Control/Main/MoveCursor

onready var game_over_animation_player = $GameOverContainer/AnimationPlayer
onready var try_again_button = $GameOverContainer/VBoxContainer/TryAgainButton

var enemy_y = 164
var x_max = 1280

export(PackedScene) var hole_scene 
export(PackedScene) var enemy_scene

var is_restarting = false

var hole_ranges = []

var hovering_hole = null


# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    GameManager.register_main(self)
    
    for floor_node in floors:
        var bounds = floor_node.setup_a_star(a_star, vector_map)
        hole_ranges.push_front(bounds)
    hole_ranges.pop_front()
    
    for floor_node in ladders:
        floor_node.setup_a_star(a_star, vector_map)

    for sailor in sailors:
        sailor.connect('sailor_pressed', self, '_on_sailor_pressed')
        sailor.connect('sailor_died', self, '_on_sailor_died')
        
    ship_timer.connect("timeout", self, '_on_timer_timeout')
    ship_timer.start()
    
    try_again_button.connect("pressed", self, '_on_try_again_pressed')
    
    score_timer.connect("timeout", self, '_on_score_timer_timeout')
    score_timer.start()
    
    
func _on_score_timer_timeout():
    if is_restarting or GameManager.is_game_over:
        return
    else:
        GameManager.score += 5
    
    
func _on_try_again_pressed():
    is_restarting = true
    GameManager.restart_game()
    
    
func get_random_hole_spawn():
    hole_ranges.shuffle()
    return [Vector2(
        floor(
#            stepify(rand_range(hole_ranges[hole_ranges.size() - 1][0].x, hole_ranges[hole_ranges.size() - 1][1].x), 16)
            stepify(rand_range(hole_ranges[0][0].x, hole_ranges[0][1].x), 16)
        ), 
        floor(
#            hole_ranges[hole_ranges.size() - 1][0].y
            stepify(rand_range(hole_ranges[0][0].y - (16*2), hole_ranges[0][0].y), 16)
        )
    ), hole_ranges[0][0].y]
    
    
func _on_timer_timeout():
    if enemies_container.get_child_count() < 5:
        spawn_enemy()
    
    
func spawn_hole():
    if GameManager.fillage >= 1.0:
        return
    var result = get_random_hole_spawn()
    var spawn = result[0]
    var y_level = result[1]
    
    var tile_position = (spawn.y - 16.0) / 16.0
    var min_tile = GameManager.min_tile
    var max_tile = GameManager.max_tile
    var percentage = range_lerp(tile_position, min_tile, max_tile, 1, 0)
    
    while GameManager.holes.has(spawn) or percentage < GameManager.fillage:
        result = get_random_hole_spawn()
        spawn = result[0]
        y_level = result[1]
        tile_position = (spawn.y - 16.0) / 16.0
        min_tile = GameManager.min_tile
        max_tile = GameManager.max_tile
        percentage = range_lerp(tile_position, min_tile, max_tile, 1, 0)
        
    var hole = hole_scene.instance()
    hole.y_level = y_level
    hole.position = spawn
    GameManager.add_hole(hole)
    holes_container.add_child(hole)
    hole.connect('hole_entered', self, '_on_hole_entered')
    hole.connect('hole_exited', self, '_on_hole_exited')
    hole.connect('tree_exiting', self, '_on_hole_exited', [hole])
    
    
func _on_hole_entered(hole):
    hovering_hole = hole
    
    
func _on_hole_exited(hole):
    if hovering_hole == hole:
        hovering_hole = null
            
        
func _on_sailor_pressed(sailor):
    if GameManager.selected_sailor != null:
        GameManager.selected_sailor.deselect() 
    GameManager.selected_sailor = sailor
    GameManager.selected_sailor.select()
    
    
func _on_sailor_died(sailor):
    if GameManager.selected_sailor == sailor:
        GameManager.selected_sailor = null
        GameManager.score = max(GameManager.score - 100, 0)
            

func end_game():
    clear_cursor_path()
    if GameManager.selected_sailor != null:
        GameManager.selected_sailor.deselect()
    GameManager.selected_sailor = null
    game_over_animation_player.play("gameover")
    emit_signal('game_ended')
    var sailors_count = sailors_container.get_child_count()
    if sailors_count > 0:
        $AnimationPlayer.stop()
        var tween = Tween.new()
        tween.interpolate_property(
            $Control,
            'rect_position',
            $Control.rect_position,
            Vector2($Control.rect_position.x, 512),
            10
        )
        add_child(tween)
        tween.start()


func on_hole_pressed(hole):
    if GameManager.selected_sailor and not hole.repairing:
        GameManager.selected_sailor.repair_hole(hole, a_star)
        GameManager.selected_sailor.deselect()
        GameManager.selected_sailor = null
        clear_cursor_path()


func _on_cannon_fired():
    yield(get_tree().create_timer(1.0), "timeout")
    spawn_hole()


func spawn_enemy():
    var spawn = Vector2(0, enemy_y)
    var enemy = enemy_scene.instance()
    if randf() > .5:
        spawn.x = -32
        enemy.direction = 1
    else:
        spawn.x = x_max + 32
        enemy.direction = -1
    enemy.position = spawn
    enemies_container.add_child(enemy)
    enemy.connect('cannon_fired', self, '_on_cannon_fired')


var last_target = null

func clear_cursor_path():
    for child in move_cursor_container.get_children():
        child.queue_free()


func _unhandled_input(event):
    if event is InputEventMouseButton:
        if GameManager.is_game_over:
            return
        if GameManager.selected_sailor != null:
            var e: InputEventMouseButton = event
            if not e.pressed:
                var target = a_star.get_point_position(a_star.get_closest_point($Control/Main.to_local(e.position)))
                GameManager.selected_sailor.set_target(target, a_star)
                GameManager.selected_sailor.deselect()
                GameManager.selected_sailor = null
                clear_cursor_path()
                
    

            
            
            
            
            
func _physics_process(delta):
    if GameManager.is_game_over or is_restarting:
        return
    var sailors_count = sailors_container.get_child_count()
    var fillage = GameManager.fillage
    if sailors_count < 1 or fillage >= 1.0:
        end_game()
        
    if GameManager.selected_sailor != null:
        var target = a_star.get_point_position(a_star.get_closest_point($Control/Main.get_local_mouse_position()))
        if hovering_hole != null:
            target = hovering_hole.position
            target.y = hovering_hole.y_level

        if last_target == null or not target.is_equal_approx(last_target):
            last_target = target
            var path = Array(a_star.get_point_path(
                a_star.get_closest_point(GameManager.selected_sailor.position),
                a_star.get_closest_point(target)
            ))
            clear_cursor_path()
            for point in path:
                var cursor = preload("res://path_cursor.tscn").instance()
                cursor.position = point
                move_cursor_container.add_child(cursor)
    else:
        clear_cursor_path()

