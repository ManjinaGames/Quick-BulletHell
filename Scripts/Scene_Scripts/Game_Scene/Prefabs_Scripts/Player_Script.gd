extends Node2D
class_name Player
#-------------------------------------------------------------------------------
enum PLAYER_STATE{ALIVE, DEATH, INVINCIBLE}
#region VARIABLES
var velocity: Vector2
var dir: float
var vel: float
#-------------------------------------------------------------------------------
var physics_Update: Callable = func(): pass
var tween_Array: Array[Tween] = []
#-------------------------------------------------------------------------------
@export var myPLAYER_STATE: PLAYER_STATE
#-------------------------------------------------------------------------------
@export var sprite: Sprite2D
#-------------------------------------------------------------------------------
@export var magnetBox_Sprite: Sprite2D
@export var magnetBox_Marker2D: Marker2D
#-------------------------------------------------------------------------------
@export var grazeBox_Sprite: Sprite2D
@export var grazeBox_Marker2D: Marker2D
#-------------------------------------------------------------------------------
@export var hitBox_Sprite: Sprite2D
@export var hitBox_Marker2D: Marker2D
#-------------------------------------------------------------------------------
var playerResource: PlayerResource
#endregion
#-------------------------------------------------------------------------------
#region CONSTRUCTORS
func SetPlayer(_playerResournce: PlayerResource):
	playerResource = _playerResournce
	#-------------------------------------------------------------------------------
	magnetBox_Sprite.scale.x  *= _playerResournce.magnetBox_Scale
	magnetBox_Sprite.scale.y  *= _playerResournce.magnetBox_Scale
	#-------------------------------------------------------------------------------
	grazeBox_Sprite.scale.x  *= _playerResournce.grazeBox_Scale
	grazeBox_Sprite.scale.y  *= _playerResournce.grazeBox_Scale
	#-------------------------------------------------------------------------------
	hitBox_Sprite.scale.x  *= _playerResournce.hitBox_Scale
	hitBox_Sprite.scale.y  *= _playerResournce.hitBox_Scale
#endregion
#-------------------------------------------------------------------------------
