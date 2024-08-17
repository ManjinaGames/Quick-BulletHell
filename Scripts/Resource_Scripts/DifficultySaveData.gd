extends Resource
class_name DifficultySaveData
#-------------------------------------------------------------------------------
@export var stage: Array[StageSaveData]
#-------------------------------------------------------------------------------
func _init():
	for _i in 9:
		stage.push_back(StageSaveData.new())
	stage[0].mySTAGE_STATE = StageSaveData.STAGE_STATE.ENABLED
#-------------------------------------------------------------------------------
