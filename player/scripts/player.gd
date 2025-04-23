class_name Player extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D

@export var speed: float = 150.0
@export var jump_force: float = 350.0
@export var gravity: float = 900.0

var direction: float = 0.0

func _physics_process(_delta: float) -> void:
  direction = Input.get_action_strength("right") - Input.get_action_strength("left")
  velocity.x = direction * speed

  sprite.scale.x = -1 if direction < 0 else 1

  if not is_on_floor():
    velocity.y += gravity * _delta
  else:
    if Input.is_action_just_pressed("up"):
      velocity.y = -jump_force

  move_and_slide()
  pass