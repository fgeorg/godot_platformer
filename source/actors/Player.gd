extends Actor
class_name Player

export var cayote_time_in_seconds: = .1

export var friction: = 4.0
export var max_speed: = Vector2(800.0, 1000.0)

export var speed: = 1000.0
export var jump_strength: = 5000.0

var _is_jumping: bool = false
var _was_on_floor: bool = false
var _lastPosition: Vector2
var _cayote_time: = 0.0
var _cayote_time_available: = false


func trigger_stomp() -> void:
	if _velocity.y > 0:
	  _velocity.y *= -1

func _on_EnemyDetector_body_entered(body: Node) -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	apply_input(delta)
	apply_gravity(delta)
	apply_cayote_time(delta)
	run_physics(delta)
	apply_friction()
	apply_speed_limits()
	animate_sprite(delta)
	_was_on_floor = is_on_floor()
	_lastPosition = get_position()

func is_on_floor() -> bool:
	return .is_on_floor() || _cayote_time > 0

func apply_input(delta: float) -> void:
	var is_on_floor = is_on_floor() || _was_on_floor || _cayote_time > 0
	var did_start_jump = Input.is_action_just_pressed("jump") and is_on_floor
	var direction: = Vector2(
		(delta * (speed) + friction) * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")),
		-jump_strength if did_start_jump else 0.0
	)
	_velocity += direction

	if (did_start_jump):
		_is_jumping = true
	if (_velocity.y > 0):
		_is_jumping = false
	if (_is_jumping && Input.is_action_just_released("jump")):
		_is_jumping = false
		_velocity.y *= 0.5

func apply_gravity(delta: float) -> void:
	_velocity.y += GRAVITY * delta
	
func apply_friction() -> void:
	if (is_on_floor()):
		if (_velocity.x > 0):
			_velocity.x = max(0, _velocity.x - friction)
		if (_velocity.x < 0):
			_velocity.x = min(0, _velocity.x + friction)
	
func apply_speed_limits() -> void:
	_velocity.y = min(_velocity.y, max_speed.y)
	_velocity.y = max(_velocity.y, -max_speed.y)
	_velocity.x = min(_velocity.x, max_speed.x)
	_velocity.x = max(_velocity.x, -max_speed.x)

func apply_cayote_time(delta: float) -> void:
	if (.is_on_floor()):
		_cayote_time_available = true
	if (_cayote_time_available && !test_move(transform, Vector2(0, GRAVITY * delta))):
		# start cayote time
		_cayote_time = cayote_time_in_seconds
		_cayote_time_available = false
	
	if (abs(_velocity.y) > 5 * GRAVITY * delta):
		_cayote_time = 0
		
	if (_cayote_time > 0):
		_cayote_time -= delta
		_velocity.y = 0

func run_physics(delta: float) -> void:
	var snap: Vector2 = Vector2.DOWN * 60.0 if _velocity.y >= 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(_velocity, snap, Vector2(0,-1), false)
	#_velocity = move_and_slide(_velocity, Vector2(0,-1), false)

func animate_sprite(delta) -> void:
	var is_on_floor = is_on_floor() || _was_on_floor
	var x_vel = (position.x - _lastPosition.x) / delta
	if (_is_jumping):
		$AnimatedSprite.play("jump")
	elif (!is_on_floor):
		$AnimatedSprite.play("fall")
	elif (abs(x_vel) > 10):
		$AnimatedSprite.play("walking")
		$AnimatedSprite.speed_scale = abs(x_vel) / 200.0
	else:
		$AnimatedSprite.play("stand")
	if (_velocity.x != 0):
		$AnimatedSprite.flip_h = _velocity.x < 0


