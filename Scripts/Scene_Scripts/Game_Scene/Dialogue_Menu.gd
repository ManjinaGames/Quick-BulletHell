extends Control
class_name Dialogue_Menu
#region VARIABLES
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var gameScene: Game_Scene
@export var dialogueText: Array[String]
@export var dialogueLabel: RichTextLabel
#-------------------------------------------------------------------------------
var isNextPress: bool = false
#endregion
#-------------------------------------------------------------------------------
func Start():
	singleton = get_node("/root/singleton")
	hide()
#-------------------------------------------------------------------------------
#region FUNCTIONS
func OpenDialogue():
	show()
#-------------------------------------------------------------------------------
func ReadDialogue():
	for _s in dialogueText:
		dialogueLabel.text = _s
		isNextPress = false
		while(!isNextPress):
			await gameScene.frame
#-------------------------------------------------------------------------------
func CloseDialogue():
	hide()
#endregion
#-------------------------------------------------------------------------------
