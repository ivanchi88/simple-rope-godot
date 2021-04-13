extends KinematicBody2D

export (int) var speed = 800
export (int) var jump_speed = -900
export (int) var gravity = 4000 
var velocity = Vector2.ZERO

var ropeScene = preload("res://Scenes/Rope.tscn") 
var hasRope = false 
var rope = null

var cooldown = 0
var passed = cooldown

var dir = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):

	velocity.x = dir * speed

	var retractForce = Vector2.ZERO
	if(rope != null):
		rope.firstPosition = global_position
		retractForce = rope.retractForce * delta
	
	velocity.y += gravity * delta
	velocity += retractForce
	velocity = move_and_slide(velocity, Vector2.UP)

	passed += delta 


func _input(event):
	dir = 0
	if(Input.is_key_pressed(KEY_A)):
		dir = -1
		$sprite.flip_h = true
	if(Input.is_key_pressed(KEY_D)):
		dir = 1
		$sprite.flip_h = false
	if(Input.is_key_pressed(KEY_W)): 
		if is_on_floor():
			velocity.y = jump_speed

	if (cooldown < passed && Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var mouse = get_viewport().get_mouse_position()
		var ropeDir = (mouse - global_position).normalized()
		var ropeInstance = rope 
		if(ropeInstance == null):
			ropeInstance = ropeScene.instance()
			rope = ropeInstance

		ropeInstance.accel = ropeDir.normalized() * 4000
		rope.firstPosition = global_position
		rope.hooked = false

		get_parent().add_child(ropeInstance)

		passed = 0
