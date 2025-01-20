extends Resource
##A resource that hold all the player Select Stats.
class_name PlayerResource
#region VARIABLES
@export var normalSpeed: float = 7.0
@export var focusSpeed: float = 3.5
#-------------------------------------------------------------------------------
@export var hitBox_Scale: float = 1.0
@export var grazeBox_Scale: float = 1.0
@export var magnetBox_Scale: float = 1.0
#-------------------------------------------------------------------------------
@export var maxLives: int
@export var maxPower: int
@export var maxMoney: int
#endregion
#-------------------------------------------------------------------------------
func CopyFrom(_playerResource: PlayerResource) -> void:
	normalSpeed = _playerResource.normalSpeed
	focusSpeed = _playerResource.focusSpeed
	#-------------------------------------------------------------------------------
	maxLives = _playerResource.maxLives
	maxPower = _playerResource.maxPower
	maxMoney = _playerResource.maxMoney
	#-------------------------------------------------------------------------------
	hitBox_Scale = _playerResource.hitBox_Scale
	grazeBox_Scale = _playerResource.grazeBox_Scale
	magnetBox_Scale = _playerResource.magnetBox_Scale
#-------------------------------------------------------------------------------
