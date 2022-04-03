tool
extends Node2D


export(int) var size = 1 setget set_size
var _real_size = size * 2
func set_size(value):
    size = value
    _real_size = size*2


func _process(delta):
    $Sprite.region_rect.size = Vector2((_real_size+2)*16, 16)
    $Sprite.offset.x = 0

        
func setup_a_star(a_star, vector_map):
    var min_coord = position - Vector2((_real_size*16)/2, 0)
    var max_coord = position + Vector2((_real_size*16)/2, 0)
    
    for x in range(min_coord.x, max_coord.x + 1, 16):
        var id = a_star.get_available_point_id()
        var vector = Vector2(x, min_coord.y)
        vector_map[vector] = id
        a_star.add_point(id, vector)
        
    for x in range(min_coord.x, max_coord.x + 1, 16):
        var vector = Vector2(x, min_coord.y)
        var id = vector_map[vector]
        var next_vector = vector + Vector2(16, 0)
        if vector_map.has(next_vector):
            var next_id = vector_map.get(next_vector)
            a_star.connect_points(id, next_id)
            
    return [min_coord, max_coord]
