extends Actor
class_name Enemy

export var starting_velocity: = Vector2(-200, 0)

func _ready() -> void:
	_velocity = starting_velocity

func _on_StompDetector_body_entered(player: Player) -> void:
	if (player.global_position.y > get_node("StompDetector").global_position.y):
		return
	player.trigger_stomp()
	#get_node("CollisionShape2D").disabled = true
	queue_free()

func _physics_process(delta: float) -> void:
	_velocity.y += GRAVITY * delta
	if (is_on_wall()):
		_velocity.x *= -1
	_velocity.y = move_and_slide(_velocity, Vector2.UP).y
	
	$AnimatedSprite.flip_h = _velocity.x > 0


