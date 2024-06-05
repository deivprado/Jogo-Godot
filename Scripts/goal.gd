extends Area2D


func _ready():
	pass


func _on_goal_body_entered(body):
	if body.name == "Player":
		$confete.emitting = true
