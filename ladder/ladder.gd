tool
extends Node2D


export(int) var size = 2


func _process(delta):
    $Sprite.region_rect.size = Vector2(16, size*16)
    $Sprite.offset.y = $Sprite.region_rect.size.y*-.5

        
func setup_a_star(a_star: AStar2D, vector_map: Dictionary):
    var min_coord = position - Vector2(0, size*16)
    var max_coord = position
    
    var has_min = vector_map.has(min_coord)
    var has_max = vector_map.has(max_coord)
    
    if vector_map.has(min_coord) and vector_map.has(max_coord):
        for y in range(min_coord.y, max_coord.y + 1, 16):
            var vector = Vector2(min_coord.x, y)
            if vector_map.has(vector):
                continue
            var id = a_star.get_available_point_id()
            vector_map[vector] = id
            a_star.add_point(id, vector)
            
        for y in range(min_coord.y, max_coord.y + 1, 16):
            var vector = Vector2(min_coord.x, y)
            var id = vector_map[vector]
            var next_vector = vector + Vector2(0, 16)
            if vector_map.has(next_vector):
                var next_id = vector_map.get(next_vector)
                a_star.connect_points(id, next_id)
    else:
        
        pass
