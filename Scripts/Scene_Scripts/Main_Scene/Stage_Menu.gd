extends Control
class_name Stage_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var button: Array[Button]
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	for _i in singleton.STAGE.size():
		singleton.SetButton(button[_i], singleton.CommonSelected, func():StageButton_Subited(_i), AnyButton_Canceled)
	singleton.SetButton(back, singleton.CommonSelected, BackButton_Subited, BackButton_Canceled)
#-------------------------------------------------------------------------------
func UpdateStageButtons():
	var _playerIndex: StringName = str(singleton.currentSaveData_Json["playerIndex"])
	var _difficultyIndex: StringName = str(singleton.currentSaveData_Json["difficultyIndex"])
	var _stage: Dictionary = singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex]
	for _i in singleton.STAGE.size():
		match(int(_stage[str(_i)]["value"])):
			singleton.STAGE_STATE.DISABLED:
				button[_i].text = "[Locked]"
			singleton.STAGE_STATE.ENABLED:
				SetButtonIdiome(button[_i], _i)
			singleton.STAGE_STATE.COMPLETED:
				SetButtonIdiome(button[_i], _i)
				button[_i].text += " (Clear)"
#-------------------------------------------------------------------------------
func StageButton_Subited(_i:int) -> void:
	var _playerIndex: StringName = str(singleton.currentSaveData_Json["playerIndex"])
	var _difficultyIndex: StringName = str(singleton.currentSaveData_Json["difficultyIndex"])
	var _stage: Dictionary = singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex]
	match(int(_stage[str(_i)]["value"])):
		singleton.STAGE_STATE.DISABLED:
			singleton.CommonCanceled()
		_:
			hide()
			singleton.currentSaveData_Json["stageIndex"] = _i
			mainScene.mainMenu.SetGameInfo()
			singleton.MoveToButton(mainScene.startMenu.start)
			mainScene.startMenu.show()
			singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	singleton.MoveToButton(back)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Subited() -> void:
	BackButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func BackButton_Canceled() -> void:
	BackButton_Common()
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Common() -> void:
	hide()
	singleton.MoveToButton(mainScene.mainMenu.button[0])
	mainScene.mainMenu.show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	back.text = tr("optionMenu_back")
	for _i in button.size():
		SetButtonIdiome(button[_i], _i)
#-------------------------------------------------------------------------------
func SetButtonIdiome(_b:Button, _i:int):
	_b.text = tr("stageMenu_button"+str(_i))
#endregion
#-------------------------------------------------------------------------------
