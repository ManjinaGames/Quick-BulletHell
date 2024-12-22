extends Control
class_name Title_Menu
#region VARIABLES
@export var titleScene: Title_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var title: Label
@export var button: Array[Button]
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	singleton.SetButton(button[0], singleton.CommonSelected, StartButton_Subited, AnyButton_Canceled)
	singleton.SetButton(button[1], singleton.CommonSelected, OptionsButton_Subited, AnyButton_Canceled)
	singleton.SetButton(button[2], singleton.CommonSelected, QuitButton_Subited, AnyButton_Canceled)
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
	var _index: int = singleton.optionMenu.optionSaveData_Json["saveIndex"]
	titleScene.saveMenu.show()
	singleton.MoveToButton(titleScene.saveMenu.button[_index])
	#NOTA: Por alguna razon el boton no se alinea con el container la primera vez, hay que ayudarlo
	#NOTA2: Necesita arreglarse para que entre en la posicion correcta.
	titleScene.saveMenu.scrollContainer.scroll_vertical = int(titleScene.saveMenu.GetContainer_ButtonSize_Y_Current() * _index)
	#titleScene.saveMenu.scrollContainer.scroll_vertical = 0
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionsButton_Subited() -> void:
	titleScene.hide()
	hide()
	singleton.MoveToButton(singleton.optionMenu.back)
	singleton.optionMenu.show()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func QuitButton_Subited() -> void:
	singleton.CommonSubmited()
	get_tree().quit()
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	singleton.MoveToLastButton(button)
	singleton.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region OPTION MENU BACK BUTTON
func OptionMenu_BackButton_Start() -> void:
	singleton.DisconnectButton(singleton.optionMenu.back)
	singleton.SetButton(singleton.optionMenu.back,  singleton.CommonSelected, OptionMenu_BackButton_Subited, OptionMenu_BackButton_Canceled)
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Subited() -> void:
	OptionMenu_BackButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Canceled() -> void:
	OptionMenu_BackButton_Common()
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Common() -> void:
	singleton.optionMenu.Save_OptionSaveData_Json()
	singleton.optionMenu.hide()
	titleScene.show()
	show()
	singleton.MoveToButton(titleScene.titleMenu.button[1])
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	title.text = tr("titleMenu_title")
	for _j in button.size():
		button[_j].text = tr("titleMenu_button"+str(_j))
#endregion
#-------------------------------------------------------------------------------
