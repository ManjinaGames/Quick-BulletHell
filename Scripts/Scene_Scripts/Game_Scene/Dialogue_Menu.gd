extends Control
class_name Dialogue_Menu
#region VARIABLES
var gameVariables: Game_Variables
@export var gameScene: Game_Scene
@export var dialogueText: Array[String]
@export var dialogueLabel: RichTextLabel
signal nextLine
#endregion
#-------------------------------------------------------------------------------
func Start():
	gameVariables = get_node("/root/GameVariables")
	hide()
#-------------------------------------------------------------------------------
#region FUNCTIONS
func OpenDialogue():
	show()
	for _s in dialogueText:
		dialogueLabel.text = _s
		await nextLine
	hide()
#endregion
#-------------------------------------------------------------------------------
