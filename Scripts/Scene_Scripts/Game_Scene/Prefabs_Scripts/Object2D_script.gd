extends Sprite2D
class_name Object2D
#region VARIABLES
var velocity: Vector2
var dir: float
var vel: float
#-------------------------------------------------------------------------------
var physics_Update: Callable = func(): pass
var tween_Array: Array[Tween] = []
#endregion
#-------------------------------------------------------------------------------
