extends KinematicBody2D

const BatDeathEffect = preload("res://Effects/BatDeathEffect.tscn")

export var ACCELERATION := 300
export var MAX_SPEED := 50
export var FRICTION := 200
export var WANDER_TARGET_RANGE = 5

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite := $AnimatedSprite
onready var stats := $Stats
onready var playerDetectionZone := $PlayerDetectionZone
onready var hurtBox := $Hurtbox
onready var softCollision := $SoftCollision
onready var wanderController := $WanderController
onready var animationPlayer := $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE,WANDER])
	

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION*delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				restart_state()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				restart_state()
			accelerate_towards_point(wanderController.target_position,delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				restart_state()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position,delta)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func restart_state():
	state = pick_random_state([IDLE,WANDER])
	wanderController.set_wander_timer(rand_range(1,2))

func accelerate_towards_point(point,delta):
	var path = global_position.direction_to(point)
	velocity = velocity.move_toward(path * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 130
	hurtBox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var batDeathEffect = BatDeathEffect.instance()
	get_parent().add_child(batDeathEffect)
	batDeathEffect.global_position = global_position
