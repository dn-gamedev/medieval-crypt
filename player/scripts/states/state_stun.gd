class_name StateStun extends State

@export var knockback_speed := 200.0
@export var decelerate_speed := 10.0
@export var invunerable_duration := 1.0

var hurt_box: HurtBox
var direction: Vector2

var next_state: State = null

@onready var idle: State = $"../Idle"

func init() -> void:
  player.player_damage.connect(_player_damage)
  pass

func enter() -> void:
  player.animation_player.animation_finished.connect(animation_finished)

  direction = player.global_position.direction_to(hurt_box.global_position)
  player.velocity = direction * -knockback_speed
  player.update_animation("stun")
  player.make_invunerable(invunerable_duration)
  pass

func exit() -> void:
  next_state = null
  player.animation_player.animation_finished.disconnect(animation_finished)
  pass

func process(_delta: float) -> State:
  player.velocity.x = move_toward(player.velocity.x, 0, player.velocity.x * decelerate_speed * _delta)
  return next_state

func physics(_delta: float) -> State:
  return null;

func handle_input(_event: InputEvent) -> State:
  return null

func _player_damage(hurtbox: HurtBox) -> void:
  hurt_box = hurtbox
  state_machine.change_state(self)
  pass

func animation_finished(_a: String) -> void:
  next_state = idle
