extends Node2D

var blockScene = preload("res://Scenes/box.tscn") 


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	
	if(Input.is_key_pressed(KEY_B)):
		var position = get_viewport().get_mouse_position()
		var block = blockScene.instance()
		self.add_child(block)
		block.set_global_position(position)
