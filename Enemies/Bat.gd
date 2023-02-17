extends KinematicBody2D

var knockback = Vector2.ZERO
var FRICTION = 200

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION*delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 130
