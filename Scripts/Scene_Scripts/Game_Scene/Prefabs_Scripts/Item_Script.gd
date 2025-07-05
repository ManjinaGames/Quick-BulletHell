extends Sprite2D
class_name Item
#-------------------------------------------------------------------------------
enum ITEM_STATE{SPIN, FALL, IMANTED}
#region VARIABLES
var velocity: Vector2
var dir: float
var vel: float
#-------------------------------------------------------------------------------
var physics_Update: Callable = func(): pass
var tween_Array: Array[Tween] = []
#-------------------------------------------------------------------------------
var myITEM_STATE: ITEM_STATE
#endregion
#-------------------------------------------------------------------------------
