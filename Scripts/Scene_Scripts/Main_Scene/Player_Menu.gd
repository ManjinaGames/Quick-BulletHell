extends Control
class_name Player_Menu
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
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	for _i in singleton.playerResource.size():
		singleton.SetButton(button[_i], singleton.CommonSelected, func():PlayerButton_Subited(_i), AnyButton_Canceled)
	singleton.SetButton(back, singleton.CommonSelected, BackButton_Subited, BackButton_Canceled)
#-------------------------------------------------------------------------------
func PlayerButton_Subited(_i:int) -> void:
	singleton.currentSaveData_Json["playerIndex"] = _i
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
	singleton.MoveToButton(mainScene.mainMenu.button[1])
	mainScene.mainMenu.show()
#endregion
#-------------------------------------------------------------------------------
func SetIdiome():
	back.text = tr("optionMenu_back")
	for _i in button.size():
		button[_i].text = tr("playerMenu_button"+str(_i))
#-------------------------------------------------------------------------------
