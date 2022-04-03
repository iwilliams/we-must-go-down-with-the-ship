extends Label

export(String) var score_prop

func _process(delta):
    var score_value = GameManager.get(score_prop)
    if score_value == null:
        return
    text = "%s: %010d" % [score_prop.to_upper().replace('_', '-'), score_value]
