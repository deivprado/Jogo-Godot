extends Area2D

var bottles = 1

func _on_items_body_entered(body):
	queue_free()
	Global.bottles += bottles
	print(Global.bottles)

