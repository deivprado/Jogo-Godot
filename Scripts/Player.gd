extends KinematicBody2D

var velocity = Vector2.ZERO
var move_speed = 480
var gravity = 1200
var jump_force = -720
var is_grounded 


var hurted = false
onready var raycasts = $raycasts

var knockback_dir = 1
var knockback_int = 1000

var player_health =  3
var max_health = 3

signal change_life(player_health)

func _ready() -> void:
	Global.set("player", self)
	connect("change_life", get_parent().get_node("HUD/HBoxContainer/Holder"), "on_change_life")
	emit_signal("change_life", max_health)
#	position.x = Global.checkpoint_pos + 50
	


func _physics_process(delta: float) -> void:
	velocity.x = 0
	velocity.y += gravity * delta 
	_get_input()	
	
	velocity = move_and_slide(velocity)
	
	is_grounded = _check_is_ground()
	
	_set_animation()
	
	for plataforms in get_slide_count():
		var collision = get_slide_collision(plataforms)
		if collision.collider.has_method("collide_with"):
			collision.collider.collide_with(collision, self)
	
func _get_input():
	var move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))	
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	
	if move_direction != 0:
		$sprite.scale.x = move_direction
		knockback_dir = move_direction

func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("jump") and is_grounded:
		velocity.y = jump_force / 2
		
func _check_is_ground():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false	

func _set_animation():
	var anim = "idle"
	
	if !is_grounded:
		anim = "Jump"
	elif velocity.x != 0:
		anim = "run"
	
	if velocity.y > 0 and !is_grounded:
		anim = "fall"
	if hurted:
		anim = "hit"
		
	if $anim.assigned_animation != anim:
		$anim.play(anim)
	
func knockback():
	velocity.x = -knockback_dir * knockback_int
	velocity = move_and_slide(velocity)
	
func _on_hurtbox_body_entered(body):
	player_health -= 1
	hurted = true
	emit_signal("change_life", player_health)
	knockback()
	get_node("hurtbox/collision").set_deferred("disabled", true)
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("hurtbox/collision").set_deferred("disabled", false)	
	hurted = false
	if player_health < 1:
		queue_free()
		get_tree().reload_current_scene()
		
func hit_checkpoint():
	Global.checkpoint_pos = position.x


func _on_hurtbox_area_entered(area):
	player_health -= 1
	hurted = true
	emit_signal("change_life", player_health)
	knockback()
	get_node("hurtbox/collision").set_deferred("disabled", true)
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("hurtbox/collision").set_deferred("disabled", false)	
	hurted = false
	if player_health < 1:
		queue_free()
		get_tree().reload_current_scene()


func _on_Trigger_PlayerEntered():
	$camera.current = false
