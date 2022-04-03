extends Node2D


onready var a_star = AStar2D.new()

var vector_map = {}

onready var sailors = $Sailors.get_children()

onready var floors = $Floors.get_children()
onready var ladders = $Ladders.get_children()


var enemy_y = 160
var x_max = 1280

export(PackedScene) var hole_scene 
export(PackedScene) var enemy_scene

var hole_ranges = []


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
        
    $Timer.connect("timeout", self, '_on_timer_timeout')
    $Timer.start()
    
    
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
    if $Enemies.get_child_count() < 5:
        spawn_enemy()
    
    
func spawn_hole():
    var result = get_random_hole_spawn()
    var spawn = result[0]
    var y_level = result[1]
    while GameManager.holes.has(spawn):
        result = get_random_hole_spawn()
        spawn = result[0]
        y_level = result[1]
    var hole = hole_scene.instance()
    hole.y_level = y_level
    hole.position = spawn
    GameManager.add_hole(hole)
    $Holes.add_child(hole)

            
        
func _on_sailor_pressed(sailor):
    if GameManager.selected_sailor != null:
        GameManager.selected_sailor.deselect() 
    GameManager.selected_sailor = sailor
    GameManager.selected_sailor.select()
    
    
func _on_sailor_died(sailor):
    if GameManager.selected_sailor == sailor:
        GameManager.selected_sailor = null


func on_hole_pressed(hole):
    if GameManager.selected_sailor and not hole.repairing:
        GameManager.selected_sailor.repair_hole(hole, a_star)
        GameManager.selected_sailor.deselect()
        GameManager.selected_sailor = null


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
    $Enemies.add_child(enemy)
    enemy.connect('cannon_fired', self, '_on_cannon_fired')



func _unhandled_input(event):
    if event is InputEventMouseButton and GameManager.selected_sailor != null:
        var e: InputEventMouseButton = event
        if not e.pressed:
            var target = a_star.get_point_position(a_star.get_closest_point(to_local(e.position)))
            GameManager.selected_sailor.set_target(target, a_star)
            GameManager.selected_sailor.deselect()
            GameManager.selected_sailor = null
