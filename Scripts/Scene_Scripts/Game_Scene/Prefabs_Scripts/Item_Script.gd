extends Object2D
class_name Item
#-------------------------------------------------------------------------------
enum ITEM_STATE{SPIN, FALL, IMANTED}
#region VARIABLES
var myOBJECT2D_STATE: OBJECT2D_STATE
var myITEM_STATE: ITEM_STATE
#-------------------------------------------------------------------------------
var size: Vector2 = Vector2(4.0, 4.0)
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS
#func _draw():
	#draw_rect(Rect2(-size.x, -size.y, size.x*2.0, size.y*2.0), Color.GREEN)
#endregion
#-------------------------------------------------------------------------------
