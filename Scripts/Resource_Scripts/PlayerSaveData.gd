extends Resource
class_name PlayerSaveData
#-------------------------------------------------------------------------------
@export var difficulty: Array[DifficultySaveData]
#-------------------------------------------------------------------------------
func _init():
	for _i in 4:
		difficulty.push_back(DifficultySaveData.new())
#-------------------------------------------------------------------------------
