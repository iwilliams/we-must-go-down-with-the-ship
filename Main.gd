extends Node2D


onready var a_star = AStar2D.new()

var vector_map = {}

onready var sailors = $Sailors.get_children()

onready var floors = $Floors.get_children()
onready var ladders = $Ladders.get_children()


export(PackedScene) var hole_scene 

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


func on_hole_pressed(hole):
    if GameManager.selected_sailor and not hole.repairing:
        GameManager.selected_sailor.repair_hole(hole, a_star)
        GameManager.selected_sailor.deselect()
        GameManager.selected_sailor = null


func _unhandled_input(event):
    if event is InputEventMouseButton and GameManager.selected_sailor != null:
        var e: InputEventMouseButton = event
        if not e.pressed:
            var target = a_star.get_point_position(a_star.get_closest_point(to_local(e.position)))
            GameManager.selected_sailor.set_target(target, a_star)
            GameManager.selected_sailor.deselect()
            GameManager.selected_sailor = null
