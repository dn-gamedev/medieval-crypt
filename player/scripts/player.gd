class_name Player extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: HitBox = $HitBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

@export var ground_accel := 1000.0
@export var air_accel := 400.0
@export var move_speed := 200.0
@export var friction := 800.0
@export var jump_height := 40.0
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.2
@export var jump_buffer_time := 0.15 # tempo em segundos
@export var coyote_time = 0.1

signal player_damage(hurt_box: HurtBox)

var last_direction := 1.0 # 1 para direita, -1 para a esquerda
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float
var jump_buffer_counter := 0.0
var coyote_time_counter := 0.0
var wall_jump_push := 100.0
var wall_jump_force := -200.0
var touching_wall := false
var wall_slide_speed := 50.0
var wall_jump_count := 1

var hp := 3
var max_hp := 3
var invunerable := false

func _ready() -> void:
  state_machine.initialize(self)
  hitbox.damage.connect(take_damage)
  PlayerManager.player = self
  jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
  jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
  fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _physics_process(_delta: float) -> void:
  var input := get_input_velocity()
  var target_speed := input * move_speed
  var accel = ground_accel if is_on_floor() else air_accel
  velocity.y += get_gravity_value() * _delta
  touching_wall = is_on_wall_only()

  player_moviment(input, _delta, target_speed, accel)

  if input == 0 and is_on_floor():
    velocity.x = 0

  if input != 0:
    last_direction = input

  sprite.scale.x = -1 if last_direction < 0 else 1

  variable_jump(jump_gravity, _delta)
  coyote_time_jump(_delta)

  #atualiza o buffer do pulo
  if Input.is_action_just_pressed("jump"):
    jump_buffer_counter = jump_buffer_time

  if jump_buffer_counter > 0:
    jump_buffer_counter -= _delta

  if touching_wall && velocity.y > wall_slide_speed:
    velocity.y = wall_slide_speed
    animation_player.play("RESET")

  # Pulo com buffer e coyote time
  if Input.is_action_just_pressed("jump"):
    if jump_buffer_counter > 0 and coyote_time_counter > 0.0:
      jump()
      jump_buffer_counter = 0.0
    elif touching_wall && wall_jump_count < 1:
      wall_jump()

  move_and_slide()
  pass

func player_moviment(input: float, _delta: float, target_speed: float, accel: float):
  if input == 0:
    velocity.x = move_toward(velocity.x, 0, friction * _delta)
  else:
    velocity.x = move_toward(velocity.x, target_speed, accel * _delta)

func variable_jump(jump_g: float, _delta: float):
  if velocity.y < 0 and not Input.is_action_pressed("jump"):
    velocity.y += jump_g * 2 * _delta

func coyote_time_jump(_delta: float):
  if is_on_floor():
    coyote_time_counter = coyote_time
    wall_jump_count = 0
  else:
    coyote_time_counter -= _delta

func get_gravity_value():
  return jump_gravity if velocity.y < 0.0 else fall_gravity


func jump() -> void:
  velocity.y = jump_velocity
  pass

func wall_jump():
  velocity.y = wall_jump_force
  wall_jump_count += 1
  #velocity.x = wall_jump_push * -sprite.scale.x  # Pula na direção oposta da parede

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

func update_hp(delta: int) -> void:
  hp = clampi(hp + delta, 0, max_hp)
  pass

func take_damage(hurt_box: HurtBox) -> void:
  if invunerable:
    return

  update_hp(-hurt_box.damage)
  if hp > 0:
    player_damage.emit(hurt_box)

  pass

func _make_invunerable(_duration: float) -> void:
  invunerable = true
  hitbox.monitoring = false
  await get_tree().create_timer(_duration).timeout

  invunerable = false
  hitbox.monitoring = true
  pass