class_name StateRun extends State

@onready var idle: State = $"../Idle"

func enter() -> void:
  player.update_animation("running")

  pass

func exit() -> void:
  pass

func process(_delta: float) -> State:
  if player.velocity.x == 0:
    return idle
  return null

func physics(_delta: float) -> State:
  return null;

func handle_input(_event: InputEvent) -> State:
  return null
