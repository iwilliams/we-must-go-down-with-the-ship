extends Label


func _process(delta):
    text = "SCORE: %010d" % GameManager.score
