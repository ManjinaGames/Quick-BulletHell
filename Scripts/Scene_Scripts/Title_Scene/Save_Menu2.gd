extends Control
class_name Save_Menu2
#region VARIABLES
@export var titleScene: Title_Scene
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var title: Label
@export var saveLabel: Label
#-------------------------------------------------------------------------------
@export_group("What to do Menu")
@export var whatToDo_Menu: PanelContainer
@export var start: Button
@export var delete: Button
@export var back: Button
#-------------------------------------------------------------------------------
@export_group("Confirm Menu")
@export var confirm_Menu: PanelContainer
@export var yes: Button
@export var no: Button
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start():
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	whatToDo_Menu.hide()
	confirm_Menu.hide()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region ENTER THIS MENU
func Set_SaveMenu2(_index:int):
	SetWhatToDoText()
	#-------------------------------------------------------------------------------
	gameVariables.DisconnectButton(start)
	gameVariables.DisconnectButton(delete)
	gameVariables.DisconnectButton(back)
	gameVariables.SetButton(start, gameVariables.CommonSelected, func():StartButton_Subited(_index), StartButton_Canceled)
	gameVariables.SetButton(delete, gameVariables.CommonSelected, DeleteButton_Subited, StartButton_Canceled)
	gameVariables.SetButton(back, gameVariables.CommonSelected, func():CancelButton_Subited(_index), func():CancelButton_Canceled(_index))
	#-------------------------------------------------------------------------------
	gameVariables.DisconnectButton(yes)
	gameVariables.DisconnectButton(no)
	gameVariables.SetButton(yes, gameVariables.CommonSelected, func():YesButton_Subited(_index), YesButton_Canceled)
	gameVariables.SetButton(no, gameVariables.CommonSelected, NoButton_Subited, NoButton_Canceled)
#endregion
#-------------------------------------------------------------------------------
#region WHAT TO DO BUTTON FUNCTIONS
func StartButton_Subited(_index:int) -> void:
	gameVariables.optionMenu.optionSaveData.saveIndex = _index
	gameVariables.optionMenu.Save_OptionSaveData(gameVariables.optionMenu.optionSaveData)
	#-------------------------------------------------------------------------------
	gameVariables.currentSaveData = gameVariables.Load_SaveData(_index)
	gameVariables.Save_SaveData(gameVariables.currentSaveData, _index)
	#-------------------------------------------------------------------------------
	gameVariables.CommonSubmited()
	get_tree().change_scene_to_file(gameVariables.mainScene_Path)
#-------------------------------------------------------------------------------
func StartButton_Canceled() -> void:
	gameVariables.MoveToButton(back)
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func DeleteButton_Subited() -> void:
	title.text = tr("deleteMenu_title")
	whatToDo_Menu.hide()
	confirm_Menu.show()
	gameVariables.MoveToButton(no)
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func CancelButton_Subited(_index:int) -> void:
	CancelButton_Common(_index)
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func CancelButton_Canceled(_index:int) -> void:
	CancelButton_Common(_index)
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func CancelButton_Common(_index:int) -> void:
	GoBackToSaveMenu1(_index)
#endregion
#-------------------------------------------------------------------------------
#region CONFIRM BUTTON FUNCTIONS
func YesButton_Subited(_index:int) -> void:
	confirm_Menu.hide()
	gameVariables.Delete_SaveData(_index)
	gameVariables.currentSaveData = null
	titleScene.saveMenu.button[_index].text = titleScene.saveMenu.SetEmptySaveText(_index)
	GoBackToSaveMenu1(_index)
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func YesButton_Canceled() -> void:
	gameVariables.MoveToButton(no)
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func NoButton_Subited() -> void:
	NoButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func NoButton_Canceled() -> void:
	NoButton_Common()
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func NoButton_Common() -> void:
	SetWhatToDoText()
	confirm_Menu.hide()
	whatToDo_Menu.show()
	gameVariables.MoveToButton(delete)
#endregion
#-------------------------------------------------------------------------------
#region MISC
func SetWhatToDoText():
	title.text = tr("saveMenu2_Title")
#-------------------------------------------------------------------------------
func GoBackToSaveMenu1(_index:int):
	hide()
	titleScene.saveMenu.show()
	gameVariables.MoveToButton(titleScene.saveMenu.button[_index])
#endregion
#-------------------------------------------------------------------------------
func SetIdiome():
	start.text = tr("saveMenu2_button0")
	delete.text = tr("saveMenu2_button1")
	back.text = tr("optionMenu_back")
	#-------------------------------------------------------------------------------
	yes.text = tr("deleteMenu_button0")
	no.text = tr("deleteMenu_button1")
