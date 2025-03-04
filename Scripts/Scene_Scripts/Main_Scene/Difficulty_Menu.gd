extends Control
class_name Difficulty_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var button: Array[Button]
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	for _i in singleton.DIFFICULTY.size():
		singleton.SetButton(button[_i], func():DifficultyButton_Selected(_i), func():DifficultyButton_Subited(_i), AnyButton_Canceled)
	singleton.SetButton(back, singleton.CommonSelected, BackButton_Subited, BackButton_Canceled)
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func DifficultyButton_Subited(_i:int) -> void:
	singleton.currentSaveData_Json["difficultyIndex"] = _i
	mainScene.mainMenu.SetGameInfo()
	singleton.Save_SaveData_Json(singleton.optionMenu.optionSaveData_Json["saveIndex"])
	BackButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func DifficultyButton_Selected(_i:int) -> void:
	var _player: int = singleton.currentSaveData_Json["playerIndex"]
	var _stage: int = singleton.currentSaveData_Json["stageIndex"]
	mainScene.mainMenu.SetGameInfo2(_player, _i, _stage)
	singleton.CommonSelected()
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
	mainScene.mainMenu.SetGameInfo()
	singleton.MoveToButton(mainScene.mainMenu.button[2])
	mainScene.mainMenu.show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	back.text = tr("optionMenu_back")
	for _i in button.size():
		button[_i].text = tr("difficultyMenu_button"+str(_i))
#endregion
#-------------------------------------------------------------------------------
