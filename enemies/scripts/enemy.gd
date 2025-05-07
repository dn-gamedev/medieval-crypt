class_name Enemy extends CharacterBody2D

@export var patrol_points: Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

const GRAVITY := 1000
const SPEED := 1500

enum EnemyState {Idle, Walk}
var current_state: EnemyState
var direction := Vector2.LEFT
var number_of_points: int
var point_positions: Array[Vector2]
var current_point: Vector2
var current_point_position: int

func _ready() -> void:
  if patrol_points != null:
    number_of_points = patrol_points.get_children().size()
    for point in patrol_points.get_children():
      point_positions.append(point.global_position)
    current_point = point_positions[current_point_position]
  else:
    print("No patrol points")
  pass

func _physics_process(delta: float) -> void:
  enemy_gravity(delta)
  enemy_idle(delta)
  enemy_walk(delta)

  move_and_slide()
  pass

func enemy_gravity(delta: float):
  velocity.y += GRAVITY * delta

func enemy_idle(delta: float):
  velocity.x = move_toward(velocity.x, 0, SPEED * delta)
  current_state = EnemyState.Idle

func enemy_walk(delta: float):
  if abs(position.x - current_point.x) > 0.5:
    velocity.x = direction.x * SPEED * delta
    current_state = EnemyState.Walk
  else:
    current_point_position += 1
  
  if current_point_position >= number_of_points:
    current_point_position = 0

  current_point = point_positions[current_point_position]

  if current_point.x > position.x:
    direction = Vector2.RIGHT
  else:
    direction = Vector2.LEFT

  sprite.flip_h = direction.x < 0
