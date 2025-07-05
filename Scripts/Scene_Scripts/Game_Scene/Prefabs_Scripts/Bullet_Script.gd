extends Sprite2D
class_name Bullet
#region VARIABLES
var velocity: Vector2
var dir: float
var vel: float
var isGrazed: bool = false
#-------------------------------------------------------------------------------
var physics_Update: Callable = func(): pass
var tween_Array: Array[Tween] = []
#endregion
#-------------------------------------------------------------------------------
