extends Node2D


onready var a_star = AStar2D.new()

var vector_map = {}

onready var sailors = $Sailors.get_children()

onready var floors = $Floors.get_children()
onready var ladders = $Ladders.get_children()

var selected_sailor = null

# Called when the node enters the scene tree for the first time.
func _ready():
    for floor_node in floors:
        floor_node.setup_a_star(a_star, vector_map)
    
    for floor_node in ladders:
        floor_node.setup_a_star(a_star, vector_map)

    for sailor in sailors:
        sailor.connect('sailor_pressed', self, '_on_sailor_pressed')
        
        
func _on_sailor_pressed(sailor):
    selected_sailor = sailor



func _unhandled_input(event):
    if event is InputEventMouseButton and selected_sailor != null:
        var e: InputEventMouseButton = event
        if not e.pressed:
            var target = a_star.get_point_position(a_star.get_closest_point(to_local(e.position)))
            selected_sailor.set_target(target, a_star)
            selected_sailor = null
