class_name Player extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

@export var ground_accel := 1000.0
@export var air_accel := 400.0
@export var move_speed := 200.0
@export var friction := 800.0
@export var jump_height := 60.0
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.225
@export var jump_buffer_time := 0.15 #tempo em segundos
@export var coyote_time = 0.1

var last_direction := 1.0 #1 para direita, -1 para a esquerda
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float
var jump_buffer_counter := 0.0
var coyote_time_counter := 0.0

func _ready() -> void:
  state_machine.initialize(self)
  jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
  jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
  fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


func _physics_process(_delta: float) -> void:
  var input = get_input_velocity()
  var target_speed = input * move_speed
  var accel = ground_accel if is_on_floor()  else air_accel
  velocity.y += get_gravity_value() * _delta

  if input == 0:
    velocity.x = move_toward(velocity.x, 0, friction * _delta)
  else:
    velocity.x = move_toward(velocity.x, target_speed, accel * _delta)

  if input == 0 and is_on_floor():
    velocity.x = 0

  if input != 0:
    last_direction = input

  sprite.scale.x = -1 if last_direction < 0 else 1

  # Pulo variável
  if velocity.y < 0 and not Input.is_action_pressed("up"):
    velocity.y += jump_gravity * 2 * _delta

  #atualiza contator do coyote time
  if is_on_floor():
    coyote_time_counter = coyote_time
  else:
    coyote_time_counter -= _delta

  #atualiza o buffer do pulo
  if Input.is_action_just_pressed("up"):
    jump_buffer_counter = jump_buffer_time

  if jump_buffer_counter > 0:
    jump_buffer_counter -= _delta

  # Pulo com buffer e coyote time
  if jump_buffer_counter > 0 and coyote_time_counter > 0.0:
    jump()
    jump_buffer_counter = 0.0

  move_and_slide()
  pass

func get_gravity_value():
  return jump_gravity if velocity.y < 0.0 else fall_gravity


func jump() -> void:
  velocity.y = jump_velocity
  pass

func get_input_velocity() -> float:
  var horizontal: float = 0.0

  if Input.is_action_pressed("left"):
    horizontal -= 1.0
  if Input.is_action_pressed("right"):
    horizontal += 1.0

  return horizontal

func update_animation(state: String) -> void:
  animation_player.play(state)
  pass