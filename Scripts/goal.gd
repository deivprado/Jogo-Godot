extends Area2D

onready var changer = get_parent().get_node("Transition_in")

export var path : String
func _ready():
	pass


func _on_goal_body_entered(body):
	if body.name == "Player":
		$confete.emitting = true
		changer.change_scene(path)
		Global.checkpoint_pos = 0
