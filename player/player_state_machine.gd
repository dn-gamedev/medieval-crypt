class_name PlayerStateMachine extends Node

var states: Array[State]
var prev_state: State
var current_state: State

func _ready() -> void:
  process_mode = Node.PROCESS_MODE_DISABLED
  pass

func _process(delta: float) -> void:
  change_state(current_state.process(delta))

func _physics_process(delta: float) -> void:
  change_state(current_state.physics(delta))

func _unhandled_input(event: InputEvent) -> void:
  change_state(current_state.handle_input(event))

func initialize(player: Player) -> void:
  states = []
  for child in get_children():
    if child is State:
      states.append(child)

  if states.size() == 0:
    return

  var first_state := states[0]

  first_state.player = player
  first_state.state_machine = self

  for state in states:
    state.init()

  change_state(first_state)
  process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: State) -> void:
  if new_state == null || new_state == current_state:
    return

  if current_state:
    current_state.exit()

  prev_state = current_state
  current_state = new_state
  current_state.enter()