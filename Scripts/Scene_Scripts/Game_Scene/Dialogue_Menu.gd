extends Control
class_name Dialogue_Menu
#region VARIABLES
var singleton: Singleton
@export var gameScene: Game_Scene
@export var dialogueText: Array[String]
@export var dialogueLabel: RichTextLabel
signal nextLine
#endregion
#-------------------------------------------------------------------------------
func Start():
	singleton = get_node("/root/singleton")
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
