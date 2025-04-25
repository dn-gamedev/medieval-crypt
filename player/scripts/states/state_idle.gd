class_name StateIdle extends State

@onready var run: State = $"../Run"

func enter() -> void:
  player.update_animation("idle")
  pass

func exit() -> void:
  pass

func process(_delta: float) -> State:
  if player.velocity.x != 0:
    return run

  return null

func physics(_delta: float) -> State:
  return null;

func handle_input(_event: InputEvent) -> State:
  return null
