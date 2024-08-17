extends Resource
class_name SaveData
#-------------------------------------------------------------------------------
@export var playerIndex: int = 0
@export var difficultyIndex: int = 0
@export var stageIndex: int = 0
#-------------------------------------------------------------------------------
@export var player: Array[PlayerSaveData]
#-------------------------------------------------------------------------------
func _init():
	for _i in 2:
		player.push_back(PlayerSaveData.new())
#-------------------------------------------------------------------------------
