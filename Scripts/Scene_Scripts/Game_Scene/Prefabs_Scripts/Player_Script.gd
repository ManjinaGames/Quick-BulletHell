extends Object2D
class_name Player
#-------------------------------------------------------------------------------
enum PLAYER_STATE{ALIVE, DEATH, INVINCIBLE}
#region VARIABLES
@export var myPLAYER_STATE: PLAYER_STATE
@export var sprite: Sprite2D
@export var hitBox: PlayerCollision
@export var graze: PlayerCollision
@export var magnet: PlayerCollision
#-------------------------------------------------------------------------------
var playerResource: PlayerResource
#endregion
#-------------------------------------------------------------------------------
#region CONSTRUCTORS
func SetPlayer(_playerResournce: PlayerResource):
	playerResource = _playerResournce
	#-------------------------------------------------------------------------------
	hitBox.scale.x  = _playerResournce.hitBox_Scale
	hitBox.scale.y  = _playerResournce.hitBox_Scale
	#-------------------------------------------------------------------------------
	graze.scale.x  = _playerResournce.grazeBox_Scale
	graze.scale.y  = _playerResournce.grazeBox_Scale
	#-------------------------------------------------------------------------------
	magnet.scale.x  = _playerResournce.magnetBox_Scale
	magnet.scale.y  = _playerResournce.magnetBox_Scale
#endregion
#-------------------------------------------------------------------------------
