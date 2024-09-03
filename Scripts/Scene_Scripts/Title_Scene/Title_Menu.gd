extends Control
class_name Title_Menu
#region VARIABLES
@export var titleScene: Title_Scene
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var title: Label
@export var button: Array[Button]
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	gameVariables.SetButton(button[0], gameVariables.CommonSelected, StartButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(button[1], gameVariables.CommonSelected, OptionsButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(button[2], gameVariables.CommonSelected, QuitButton_Subited, AnyButton_Canceled)
	#-------------------------------------------------------------------------------
	OptionMenu_BackButton_Start()
	#-------------------------------------------------------------------------------
	show()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func StartButton_Subited() -> void:
	hide()
	titleScene.saveMenu.SetSaveButtons()
	var _index: int = gameVariables.optionMenu.optionSaveData.saveIndex
	titleScene.saveMenu.show()
	gameVariables.MoveToButton(titleScene.saveMenu.button[_index])
	#NOTA: Por alguna razon el boton no se alinea con el container la primera vez, hay que ayudarlo
	#NOTA2: Necesita arreglarse para que entre en la posicion correcta.
	titleScene.saveMenu.scrollContainer.scroll_vertical = int(titleScene.saveMenu.buttonSize.y * _index)
	#titleScene.saveMenu.scrollContainer.scroll_vertical = 0
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionsButton_Subited() -> void:
	titleScene.hide()
	hide()
	gameVariables.MoveToButton(gameVariables.optionMenu.back)
	gameVariables.optionMenu.show()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func QuitButton_Subited() -> void:
	gameVariables.CommonSubmited()
	get_tree().quit()
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	gameVariables.MoveToLastButton(button)
	gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region OPTION MENU BACK BUTTON
func OptionMenu_BackButton_Start() -> void:
	gameVariables.DisconnectButton(gameVariables.optionMenu.back)
	gameVariables.SetButton(gameVariables.optionMenu.back,  gameVariables.CommonSelected, OptionMenu_BackButton_Subited, OptionMenu_BackButton_Canceled)
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Subited() -> void:
	OptionMenu_BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Canceled() -> void:
	OptionMenu_BackButton_Common()
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Common() -> void:
	gameVariables.optionMenu.Save_OptionSaveData(gameVariables.optionMenu.optionSaveData)
	gameVariables.optionMenu.hide()
	titleScene.show()
	show()
	gameVariables.MoveToButton(titleScene.titleMenu.button[1])
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	title.text = tr("titleMenu_title")
	for _j in button.size():
		button[_j].text = tr("titleMenu_button"+str(_j))
#endregion
#-------------------------------------------------------------------------------
