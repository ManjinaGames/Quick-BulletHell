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
	for _i in 4:
		singleton.SetButton(button[_i], singleton.CommonSelected, func():DifficultyButton_Subited(_i), AnyButton_Canceled)
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
