extends Node
class_name Game_Scene
#-------------------------------------------------------------------------------
enum GAME_STATE{IN_GAMEPLAY, IN_CUTIN, IN_MARKET, IN_OPTION_MENU, IN_DIALOGUE, IN_GAMEOVER}
#region VARIABLES
var singleton: Singleton
#-------------------------------------------------------------------------------
var myGAME_STATE: GAME_STATE = GAME_STATE.IN_GAMEPLAY
var inPause: bool = false
#-------------------------------------------------------------------------------
@export var currentLayer: CanvasLayer
@export var pauseMenu: Pause_Menu
@export var gameoverMenu: GameOver_Menu
@export var marketMenu: Market_Menu
@export var dialogueMenu: Dialogue_Menu
#-------------------------------------------------------------------------------
@export var timerLabel: Label
var timer: int
@export var content: Control
@export var player: Player
@export var playerExplotion: PackedScene
#-------------------------------------------------------------------------------
@export var enemy_Prefab: PackedScene
@export var enemyBullet_Prefab: PackedScene
@export var item_Prefab: PackedScene
#-------------------------------------------------------------------------------
@export var maxScoreLabel_title: RichTextLabel
@export var maxScoreLabel_Num: RichTextLabel
@export var scoreLabel_title: RichTextLabel
@export var scoreLabel_Num: RichTextLabel
@export var powerLabel_title: RichTextLabel
@export var powerLabel_Num: RichTextLabel
@export var livesLabel_title: RichTextLabel
@export var livesLabel_Num: RichTextLabel
@export var moneyLabel_title: RichTextLabel
@export var moneyLabel_Num: RichTextLabel
@export var maxMoneyLabel_Num: RichTextLabel
@export var leftLabel: RichTextLabel
#-------------------------------------------------------------------------------
@export var completedPanel: PanelContainer
@export var completedLabel: Label
#-------------------------------------------------------------------------------
var enemyBulletsEnabled: Array[Bullet]
var enemyBulletsDisabled: Array[Bullet]
var playerBulletsEnabled: Array[Bullet]
var playerBulletsDisabled: Array[Bullet]
var itemsEnabled: Array[Item]
var itemsDisabled: Array[Item]
#-------------------------------------------------------------------------------
@export_flags_2d_physics var playerLayer: int
@export_flags_2d_physics var grazeLayer: int
@export_flags_2d_physics var magnetLayer: int
@export_flags_2d_physics var enemyLayer: int
#-------------------------------------------------------------------------------
var height: float
#-------------------------------------------------------------------------------
var width: float
#-------------------------------------------------------------------------------
var playerMaxX: float
var playerMinX: float
var playerMaxY: float
var playerMinY: float
#-------------------------------------------------------------------------------
var lifePoints: int
var powerPoints: int
var moneyPoints: int
var scorePoints: int
#-------------------------------------------------------------------------------
var _direct_space_state :PhysicsDirectSpaceState2D
var deltaTimeScale: float = 1
#-------------------------------------------------------------------------------
signal frame
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready():
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	_direct_space_state = content.get_world_2d().direct_space_state
	#-------------------------------------------------------------------------------
	pauseMenu.Start()
	gameoverMenu.Start()
	marketMenu.Start()
	dialogueMenu.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	singleton.PlayBGM(singleton.bgmStage1)
	get_tree().set_deferred("paused", false)
	currentLayer.show()
	await BeginGame()
#-------------------------------------------------------------------------------
func _physics_process(_delta:float) -> void:
	deltaTimeScale = Engine.time_scale
	frame.emit()
	Debug_Information()
	#-------------------------------------------------------------------------------
	match(myGAME_STATE):
		GAME_STATE.IN_GAMEPLAY:
			PlayerMovement()
			PauseGame()
			return
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_CUTIN:
			PlayerMovement()
			PauseGame()
			return
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_MARKET:
			pass
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_OPTION_MENU:
			pass
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_DIALOGUE:
			PlayerMovement()
			if(Input.is_action_just_pressed("input_Shoot")):
				dialogueMenu.isNextPress = true
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_GAMEOVER:
			pass
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region PLAYER FUNCTIONS
func PlayerMovement() -> void:
	if(player.myPLAYER_STATE == Player.PLAYER_STATE.DEATH):
		return
	#-------------------------------------------------------------------------------
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if(input_dir != Vector2.ZERO):
		input_dir.normalized()
		var myPosition: Vector2 = player.position
		if(Input.is_action_pressed("input_Focus")):
			myPosition += input_dir * player.focusSpeed * deltaTimeScale
		else:
			myPosition += input_dir * player.normalSpeed * deltaTimeScale
		myPosition.x = clampf(myPosition.x, playerMinX, playerMaxX)
		myPosition.y = clampf(myPosition.y, playerMinY, playerMaxY)
		player.position = myPosition
#endregion
#-------------------------------------------------------------------------------
#region PAUSE INPUTS
func PauseGame() -> void:
	if(myGAME_STATE == GAME_STATE.IN_GAMEOVER):
		return
	#-------------------------------------------------------------------------------
	if(Input.is_action_just_pressed("input_Pause")):
		pauseMenu.show()
		StopTime()
		singleton.MoveToButton(pauseMenu.continuar)
#-------------------------------------------------------------------------------
func StopTime():
	singleton.playPosition = singleton.bgmPlayer.get_playback_position()
	singleton.bgmPlayer.stop()
	get_tree().set_deferred("paused", true)
#-------------------------------------------------------------------------------
func PauseOff():
	pauseMenu.hide()
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	get_tree().set_deferred("paused", false)
	singleton.bgmPlayer.play(singleton.playPosition)
#endregion
#-------------------------------------------------------------------------------
#region PLAYER BULLET FUNCTIONS
func CreateDisabledPlayerBullets(_num:int):
	for _i in _num:
		var _bullet: Bullet = enemyBullet_Prefab.instantiate() as Bullet
		playerBulletsDisabled.push_back(_bullet)
		_bullet.myOBJECT2D_STATE = Bullet.OBJECT2D_STATE.DEATH
		_bullet.hide()
		content.add_child(_bullet)
#-------------------------------------------------------------------------------
func PlayerShoot() -> void:
	while(CanPlayerShoot()):
		if(Input.is_action_pressed("input_Shoot") and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
			PlayerShoot1(player.position.x, player.position.y-16, 16, -90)
			await Frame(4)
		else:
			await frame
#-------------------------------------------------------------------------------
func CanPlayerShoot() -> bool:
	if(myGAME_STATE == GAME_STATE.IN_GAMEPLAY or myGAME_STATE == GAME_STATE.IN_CUTIN):
		return true
	else:
		return false
#-------------------------------------------------------------------------------
func PlayerShoot1(_x:float, _y:float, _vel:float, _dir:float) -> void:
	var _bullet = CreatePlayerBullet(_x, _y, _vel, _dir)
	while(_bullet != null):
		if(0 <= _bullet.position.x and _bullet.position.x <= width):
			if(0 <= _bullet.position.y and _bullet.position.y <= height):
				var _result: Array[Dictionary] = Colliding(_bullet, enemyLayer)
				if(_result):
					ShootedEnemy(_result[0]["collider"].get_parent())
					DestroyPlayerBullet(_bullet)
					break
				var _dir2: float = deg_to_rad(_bullet.dir)
				_bullet.position += Vector2(_bullet.vel*cos(_dir2), _bullet.vel*sin(_dir2)) * deltaTimeScale
				await frame
			else:
				DestroyPlayerBullet(_bullet)
				break
		else:
			DestroyPlayerBullet(_bullet)
			break
#-------------------------------------------------------------------------------
func CreatePlayerBullet(_x:float, _y:float, _vel:float, _dir:float) -> Bullet:
	var _bullet : Bullet
	if(playerBulletsDisabled.size()>0):
		_bullet = playerBulletsDisabled[0]
		playerBulletsDisabled.erase(_bullet)
		_bullet.show()
	else:
		_bullet = enemyBullet_Prefab.instantiate() as Bullet
		content.add_child(_bullet)
	playerBulletsEnabled.push_back(_bullet)
	_bullet.position = Vector2(_x, _y)
	_bullet.rotation = deg_to_rad(_dir + 90.0)
	_bullet.vel = _vel
	_bullet.dir = _dir
	_bullet.myOBJECT2D_STATE = Bullet.OBJECT2D_STATE.ALIVE
	_bullet.frame = 9
	return _bullet
#-------------------------------------------------------------------------------
func DestroyPlayerBullet(_bullet:Bullet) -> void:
	_bullet.hide()
	_bullet.position = Vector2.ZERO
	playerBulletsEnabled.erase(_bullet)
	playerBulletsDisabled.push_back(_bullet)
#-------------------------------------------------------------------------------
func ShootedEnemy(_enemy:Enemy) -> void:
	if(!_enemy.canBeHit):
		return
	_enemy.hp-=1
	if(_enemy.hp>0):
		SetHp(_enemy)
	else:
		_enemy.canBeHit = false
		_enemy.myOBJECT2D_STATE = Enemy.OBJECT2D_STATE.DEATH
#endregion
#-------------------------------------------------------------------------------
#region UI FINCTIONS
func SetGameLimits() -> void:
	await content.resized
	#-------------------------------------------------------------------------------
	height = content.size.y
	width = content.size.x
	#-------------------------------------------------------------------------------
	var _offSet: float = 10
	playerMinX = _offSet
	playerMaxX = width-_offSet
	playerMinY = _offSet
	playerMaxY = height-_offSet
#-------------------------------------------------------------------------------
func CenterX(_f:float) -> float:
	var _x: float = width*0.5+width*0.5*_f
	return _x
#-------------------------------------------------------------------------------
func CenterY(_f:float) -> float:
	var _y: float = height*0.5+height*0.5*_f
	return _y
#-------------------------------------------------------------------------------
func Debug_Information() -> void:
	var _s: String = ""
	_s += "Enemy Bullets Enabled: " + str(enemyBulletsEnabled.size())+"\n"
	_s += "Enemy Bullets Disabled: " + str(enemyBulletsDisabled.size())+"\n"
	_s += "Player Bullets Enabled: " + str(playerBulletsEnabled.size())+"\n"
	_s += "Player Bullets Disabled: " + str(playerBulletsDisabled.size())+"\n"
	_s += "Items Enabled: " + str(itemsEnabled.size())+"\n"
	_s += "Items Disabled: " + str(itemsDisabled.size())+"\n"
	_s += "\n"
	_s += "GAME_STATE." + GAME_STATE.keys()[myGAME_STATE]+"\n"
	_s += "PLAYER_STATE." + Player.PLAYER_STATE.keys()[player.myPLAYER_STATE]+"\n"
	leftLabel.text = _s
#-------------------------------------------------------------------------------
func SetScore() -> void:
	var _s: String = str(scorePoints).pad_zeros(9)
	_s = _s.insert(_s.length()-3,",")
	_s = _s.insert(_s.length()-7,",")
	scoreLabel_Num.text = "[center]"+_s+"[/center]"
#-------------------------------------------------------------------------------
func SetInfoText_Life() -> void:
	livesLabel_Num.text = GetInfoText_LifePower(lifePoints, player.maxLives)
#-------------------------------------------------------------------------------
func SetInfoText_Power() -> void:
	powerLabel_Num.text = GetInfoText_LifePower(powerPoints, player.maxPower)
#-------------------------------------------------------------------------------
func GetInfoText_LifePower(_point:int, _maxPoint:int) -> String:
	var _s: String = "[center]"+str(_point).pad_zeros(2)+" / "+str(_maxPoint).pad_zeros(2)+"[/center]"
	return _s
#-------------------------------------------------------------------------------
func SetInfoText_Death():
	livesLabel_Num.text = "[center]"+"  --"+" / "+str(player.maxLives).pad_zeros(2)+"[/center]"
#-------------------------------------------------------------------------------
func SetMoney() -> void:
	moneyLabel_Num.text = "[center]"+str(moneyPoints)+" G[/center]"
	#-------------------------------------------------------------------------------
func SetMaxMoney() -> void:
	maxMoneyLabel_Num.text = "[center]"+str(9999)+" G[/center]"
#endregion
#-------------------------------------------------------------------------------
#region ITEM FUNCTIONS
func SpawnItems(_x:float, _y:float, _rad:float, _num:int) -> void:
	for _i in _num:
		var _x2:float = _x + randf_range(-_rad,_rad)
		var _y2:float = _y + randf_range(-_rad,_rad)
		SpawnItem(_x2, _y2, -3)
#-------------------------------------------------------------------------------
func SpawnItem(_x:float, _y:float, _velY: float) -> void:
	var _item: Item = CreateItem(_x, _y, _velY)
	var _maxVelY: float = 3.0
	var _magnetVel: float = 8.0
	#-------------------------------------------------------------------------------
	while(_item != null):
		match(_item.myITEM_STATE):
			Item.ITEM_STATE.SPIN:
				if(_item.velY <= 0):
					ItemMovement_Fall(_item, _maxVelY)
					_item.rotation += 0.5 * deltaTimeScale
				else:
					_item.rotation = 0
					_item.myITEM_STATE = Item.ITEM_STATE.FALL
			#-------------------------------------------------------------------------------
			Item.ITEM_STATE.FALL:
				if(_item.position.y <= height):
					ItemMovement_Fall(_item, _maxVelY)
					#-------------------------------------------------------------------------------
					var _result: Array[Dictionary] = Colliding(_item, magnetLayer)
					if(_result and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
						_item.myITEM_STATE = Item.ITEM_STATE.IMANTED
					elif(!CanPlayerShoot() and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
						_item.myITEM_STATE = Item.ITEM_STATE.IMANTED
				else:
					DestroyItem(_item)
					return
			#-------------------------------------------------------------------------------
			Item.ITEM_STATE.IMANTED:
				var _vel: Vector2 = (player.position - _item.position)
				if(_vel.length_squared() > 144.0):
					var _dir = atan2(_vel.y, _vel.x)
					var _vel2 = Vector2(cos(_dir), sin(_dir))
					_item.position += _vel2 * _magnetVel * deltaTimeScale
				else:
					scorePoints += 10
					moneyPoints += 1
					SetScore()
					SetMoney()
					DestroyItem(_item)
					return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		await frame
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func ItemMovement_Fall(_item:Item, _maxVelY:float):
	if(_item.velY > _maxVelY):
		_item.velY = _maxVelY
	elif(_item.velY < _maxVelY):
		_item.velY += 0.05 * deltaTimeScale
	_item.position.y += _item.velY * deltaTimeScale
#-------------------------------------------------------------------------------
func CreateDisabledItem(_num:int):
	for _i in _num:
		var _item: Item = item_Prefab.instantiate() as Item
		itemsDisabled.push_back(_item)
		_item.hide()
		content.add_child(_item)
#-------------------------------------------------------------------------------
func CreateItem(_x:float, _y:float, _velY:float) -> Item:
	var _item : Item
	if(itemsDisabled.size()>0):
		_item = itemsDisabled[0]
		itemsDisabled.erase(_item)
		_item.show()
	else:
		_item = item_Prefab.instantiate() as Item
		content.add_child(_item)
	itemsEnabled.push_back(_item)
	_x = clamp(_x, 0, width)
	_item.position = Vector2(_x, _y)
	_item.velY = _velY
	_item.rotation = randf_range(0, 360)
	_item.myITEM_STATE = Item.ITEM_STATE.SPIN
	return _item
#-------------------------------------------------------------------------------
func DestroyItem(_item:Item) -> void:
	_item.hide()
	_item.position = Vector2.ZERO
	itemsEnabled.erase(_item)
	itemsDisabled.push_back(_item)
#endregion
#-------------------------------------------------------------------------------
#region START FUNCTIONS
func BeginGame() -> void:
	SetGameLimits()
	#-------------------------------------------------------------------------------
	CreateDisabledItem(200)
	CreateDisabledPlayerBullets(50)
	CreateDisabledEnemyBullets(5000)
	#-------------------------------------------------------------------------------
	SetScore()
	SetMoney()
	SetMaxMoney()
	lifePoints = int(float(player.maxLives)*0.25)
	SetInfoText_Life()
	powerPoints = int(float(player.maxPower)*0.25)
	SetInfoText_Power()
	#-------------------------------------------------------------------------------
	completedPanel.hide()
	completedLabel.text = ""
	timerLabel.text = ""
	#-------------------------------------------------------------------------------
	await content.resized
	player.position = Vector2(width*0.5, height*0.85)
	player.myPLAYER_STATE = Player.PLAYER_STATE.ALIVE
	#-------------------------------------------------------------------------------
	Enter_GameState()
	Choreography()
#-------------------------------------------------------------------------------
func Choreography() -> void:
	match(singleton.currentSaveData_Json["stageIndex"]):
		0:
			await Stage1()
		1:
			await Stage2()
		2:
			await Stage3()
		3:
			await Stage4()
		4:
			await Stage5()
		5:
			await Stage6()
		6:
			await Stage7()
		7:
			await Stage8()
		8:
			await Stage9()
#endregion
#-------------------------------------------------------------------------------
#region STAGE 1
func Stage1() -> void:
	#await WaveOfEnemies_and_Market("Wave of Enemies N°1", InfiniteEnemySpawn, 7)
	#await WaveOfEnemies_and_Market("Wave of Enemies N°2", Stage1_Wave1_UM1, 30)
	#await WaveOfEnemies_and_Market("Wave of Enemies N°3", Stage1_Wave2_UM1, 30)
	await CreateBoss1()
	#await WaveOfEnemies_and_Market("Wave of Enemies N°1", Stage1_Wave1_UM1, 30)
	#await WaveOfEnemies_and_Market("Wave of Enemies N°2", Stage1_Wave2_UM1, 30)
	await StageCommon("Stage 1 Completed",1,0)
#-------------------------------------------------------------------------------
func CreateBoss1() -> void:
	await ShowBanner("Enter Boss 1")
	#-------------------------------------------------------------------------------
	myGAME_STATE = GAME_STATE.IN_DIALOGUE
	dialogueMenu.OpenDialogue()
	await dialogueMenu.ReadDialogue()
	#-------------------------------------------------------------------------------
	var _boss: Enemy = CreateBoss(0, 0)
	await Move_Towards_Old(_boss, width*0.5, height*0.25, 30)
	#-------------------------------------------------------------------------------
	await dialogueMenu.ReadDialogue()
	dialogueMenu.CloseDialogue()
	Enter_GameState()
	#-------------------------------------------------------------------------------
	singleton.PlayBGM(singleton.bgmBoss1)
	await BossAttack(_boss, 60, "Boss Attack 1", Stage1_Boss1_UM1_SubAttack1, 5)
	await BossAttack_and_Market(_boss, 60, "Boss SpellCard 1", Stage1_Boss1_UM1_SubAttack1, 10)
	
	#await BossAttack(_boss, 20, "Boss Attack 1", Stage1_Boss1_UM1_SubAttack1, 5)
	#await BossAttack_and_Market(_boss, 30, "Boss SpellCard 2", Stage1_Boss1_UM1_SubAttack1, 10)
	
	#await BossAttack(_boss, 20, "Boss Attack 3", Stage1_Boss1_UM1_SubAttack1, 15)
	#await BossAttack_and_Market(_boss, 15, "Boss SpellCard 3", Stage1_Boss1_UM1_SubAttack1, 15)
	
	await BossAttack(_boss, 22, "Boss Attack 4", Stage1_Boss1_UM1_SubAttack1, 15)
	await BossAttack(_boss, 20, "Boss SpellCard 4", Stage1_Boss1_UM1_SubAttack1, 15)
	#-------------------------------------------------------------------------------
	myGAME_STATE = GAME_STATE.IN_CUTIN
	await Frame(60)
	await Move_Towards_Old(_boss, width, 0, 30)
	#-------------------------------------------------------------------------------
	Death_Enemy(_boss)
#-------------------------------------------------------------------------------
func Stage1_Wave1_UM1():
	while(myGAME_STATE == GAME_STATE.IN_GAMEPLAY):
		await Stage1_Wave1_UM1_Enemies(-height*0.1*2, 1)
		await Frame_InGame(60)
		await Stage1_Wave1_UM1_Enemies(-height*0.1*2, -1)
		await Frame_InGame(60)
#-------------------------------------------------------------------------------
func Stage1_Wave1_UM1_Enemies(_y:float, _mirror:float):
	var _max: float = 5
	var _pendiente: float = width/(_max+1)*_mirror
	var _origen: float = width*0.5 - width*0.5*_mirror-_pendiente*0.25
	for _i in _max:
		Stage1_Wave1_UM1_Enemy1(_origen+_pendiente*(_i+1), _y, _mirror)
		await Frame_InGame(15)
#-------------------------------------------------------------------------------
func Stage1_Wave1_UM1_Enemy1(_x:float, _y:float, _mirror:float):
	if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
		return
	#-------------------------------------------------------------------------------
	var _enemy: Enemy = CreateEnemy(_x, _y, 10)
	Stage1_Wave1_UM1_Enemy1_Fire1(_enemy)
	await Move_VDir_VAccel(_enemy, 5, 90, -0.05, 0)
	await Move_VDir_DirAccel(_enemy, _enemy.vel, _enemy.dir, 0.2*_mirror, 120)
	await Move_VDir_DirAccel_VAccel(_enemy, _enemy.vel, _enemy.dir, -0.2*_mirror, 0.05, 4)
	await Move_VDir_DirAccel(_enemy, _enemy.vel, _enemy.dir, -0.2*_mirror, 180)
	#-------------------------------------------------------------------------------
	var _revenge: Callable = func():Stage1_Wave1_UM1_Enemy1_Fire2(_enemy, _mirror)
	DestroyEnemy_WithRevenge(_enemy, 5, _revenge)
#-------------------------------------------------------------------------------
func Stage1_Wave1_UM1_Enemy1_Fire1(_enemy:Enemy):
	await Frame_InGame(60)
	for _i in 7:
		if(!Obj2D_IsInGame(_enemy)):
			return
		CreateShotA1(_enemy.position.x, _enemy.position.y, 6, AngleToPlayer(_enemy), 1)
		await Frame_InGame(10)
#-------------------------------------------------------------------------------
func Stage1_Wave1_UM1_Enemy1_Fire2(_enemy:Enemy, _mirror:float):
	var _max: float = 3
	var _cone: float = 20
	var _origen: float = AngleToPlayer(_enemy)-_cone/2*_mirror
	var _pendiente: float = _cone/(_max+1)*_mirror
	for _i in _max:
		var _dir: float = _origen+_pendiente*(_i+1)
		CreateShotA1(_enemy.position.x, _enemy.position.y, 3+0.3*_i, _dir, 0)
#-------------------------------------------------------------------------------
func Stage1_Wave2_UM1():
	while(myGAME_STATE == GAME_STATE.IN_GAMEPLAY):
		Stage1_Wave2_UM1_Enemies(-height*0.1, 1)
		await Stage1_Wave2_UM1_Enemies(-height*0.1, -1)
		await Frame_InGame(120)
#-------------------------------------------------------------------------------
func Stage1_Wave2_UM1_Enemies(_y:float, _mirror:float):
	var _max1: float = 6
	var _max2: float = 2
	var _origen1: float = width*0.5 - width*0.5 * _mirror * 1
	var _origen2: float = width*0.5 - width*0.5 * _mirror * 0.25
	var _pendiente: float = abs(_origen1 - _origen2) * _mirror / (_max2+1)
	for _i in _max1:
		for _j in _max2:
			Stage1_Wave2_UM1_Enemy1(_origen1+_pendiente*(_j+1), _y-height*0.1*0.5*_j, _mirror)
		await Frame_InGame(30)
#-------------------------------------------------------------------------------
func Stage1_Wave2_UM1_Enemy1(_x:float, _y:float, _mirror:float):
	if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
		return
	#-------------------------------------------------------------------------------
	var _enemy: Enemy = CreateEnemy(_x, _y, 10)
	Stage1_Wave2_UM1_Enemy1_Fire1(_enemy, _mirror)
	await Move_VDir_DirAccel(_enemy, 2, 90, 0, 60)
	await Move_VDir_DirAccel(_enemy, _enemy.vel, _enemy.dir, -0.5*_mirror, 120)
	await Move_VDir_DirAccel_VAccel(_enemy, _enemy.vel, _enemy.dir, -0.01*_mirror, 0.01, 4)
	await Move_VDir_DirAccel(_enemy, _enemy.vel, _enemy.dir, -0.01*_mirror, 60)
	#-------------------------------------------------------------------------------
	DestroyEnemy(_enemy, 5)
#-------------------------------------------------------------------------------
func Stage1_Wave2_UM1_Enemy1_Fire1(_enemy:Enemy, _mirror:float):
	await Frame_InGame(50)
	var _max1: float = 3
	var _max2: float = 3
	var _cone: float = 150
	var _origen: float
	var _pendiente: float = _cone/(_max2+1)*_mirror
	for _i in _max1:
		if(!Obj2D_IsInGame(_enemy)):
			return
		for _j in _max2:
			_origen = AngleToPlayer(_enemy)-_cone/2*_mirror
			CreateShotA1(_enemy.position.x, _enemy.position.y, 5, _origen+_pendiente*(_j+1), 2)
		await Frame_InGame(60)
#-------------------------------------------------------------------------------
func Stage1_Boss1_UM1_SubAttack1(_boss:Enemy):
	Stage1_Boss1_UM1_SubAttack1_Fire1(_boss)
#-------------------------------------------------------------------------------
func Stage1_Boss1_UM1_SubAttack1_Fire1(_boss:Enemy):
	var _max1: float = 10
	var _max2: float = 36
	var _dir: float = 0
	var _rad: float = width*0.1
	var _mirror: float = 1
	var _vel: float
	var _dV: float
	while(Obj2D_IsInGame(_boss)):
		_vel = 6
		_dV = (1-_vel)/_max1
		for _i in _max1:
			if(!Obj2D_IsInGame(_boss)):
				return
			#-------------------------------------------------------------------------------
			for _j in _max2:
				var _dir2: float = deg_to_rad(_dir)
				var _x: float = _boss.position.x + _rad * cos(_dir2)
				var _y: float = _boss.position.y + _rad * sin(_dir2)
				CreateShotA2(_x, _y, _vel, _dir+90*_mirror,0.2*_mirror, 600, 2)
				_dir += 360/_max2
				#-------------------------------------------------------------------------------
			_vel += _dV
			await Frame_InGame(5)
			#-------------------------------------------------------------------------------
		_mirror *=-1
		await Frame_InGame(120)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Stage1_Wave1_BlackMarket():
	while(myGAME_STATE == GAME_STATE.IN_GAMEPLAY):
		await Stage1_Enemies1_BlackMarket(1)
		await Stage1_Enemies1_BlackMarket(-1)
#-------------------------------------------------------------------------------
func InfiniteEnemySpawn():
	while(myGAME_STATE == GAME_STATE.IN_GAMEPLAY):
		await InfiniteEnemySpawn2()
		await Frame_InGame(15)
#-------------------------------------------------------------------------------
func InfiniteEnemySpawn2():
	var _enemy: Enemy = CreateEnemy(0, 0, 10)
	Move_Towards(_enemy, width*0.5, height*0.2, 30)
	await WaitEnemyDeath(_enemy)
	DestroyEnemy(_enemy, 20)
#-------------------------------------------------------------------------------
func Stage1_Enemies1_BlackMarket(_mirror:float):
	for _i in 12:
		if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
			return
		var _radX: float = width*0.1/2
		var _x: float = width*0.5-(width*0.5+width*0.1)*_mirror+randf_range(-_radX, _radX)
		var _y: float = height*0.5+randf_range(-height*0.1, height*0.1)
		Stage1_Enemy1_BlackMarket(_x, _y, _mirror)
		await Frame_InGame(20)
#-------------------------------------------------------------------------------
func Stage1_Enemy1_BlackMarket(_x:float, _y:float, _mirror:float):
	if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
		return
	#-------------------------------------------------------------------------------
	var _enemy: Enemy = CreateEnemy(_x, _y, 25)
	Stage1_Enemy1_Fire1_BlackMarket(_enemy)
	await Move_VDir_DirAccel(_enemy, 5, 90-90*_mirror, -0.1*_mirror, 60*1)
	await Move_VDir_DirAccel_VAccel(_enemy, _enemy.vel, _enemy.dir, -0.1*_mirror, -0.05, 1)
	await Move_VDir_DirAccel(_enemy, _enemy.vel, _enemy.dir, -1.5*_mirror, 60*1)
	await Move_VDir_DirAccel_VAccel(_enemy, _enemy.vel, _enemy.dir, -0.1*_mirror, 0.06, 3)
	await Move_VDir_DirAccel(_enemy, _enemy.vel, _enemy.dir, -0.1*_mirror, 60*1)
	await Move_VDir(_enemy, _enemy.vel, _enemy.dir, 60*2)
	#-------------------------------------------------------------------------------
	DestroyEnemy(_enemy, 20)
#-------------------------------------------------------------------------------
func Stage1_Enemy1_Fire1_BlackMarket(_enemy:Enemy):
	await Frame_InGame(100)
	for _i in 4:
		if(!Obj2D_IsInGame(_enemy)):
			return
		CreateShotA1(_enemy.position.x, _enemy.position.y, randf_range(3,4), 90+randf_range(-5,5), 1)
		await Frame_InGame(10)
#-------------------------------------------------------------------------------
func Stage1_Wave1():
	for _j in 2:
		for _i in 4:
			Stage1_Enemy1(width*0.1*_i*0.75, height, -1)
			await Frame_InGame(15)
			Stage1_Enemy1(width-width*0.1*_i*0.75, height, 1)
			await Frame_InGame(15)
#-------------------------------------------------------------------------------
func Stage1_Enemy1(_x:float, _y:float, _mirror:float) -> void:
	if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
		return
	#-------------------------------------------------------------------------------
	var _enemy: Enemy = CreateEnemy(_x, _y, 5)
	await Move_Towards(_enemy, _x-width*0.1*_mirror, CenterY(-0.8), 60)
	await Frame_InGame(60)
	await Stage1_Enemy1_Fire(_enemy, 5)
	await Frame_InGame(60)
	await Move_Towards(_enemy, CenterX(-1*_mirror), CenterY(-0.4), 60)
	DestroyEnemy(_enemy, 20)
#-------------------------------------------------------------------------------
func Stage1_Enemy1_Fire(_enemy:Enemy, _num:int) -> void:
	var _dir: float
	var _cone: float = 20
	for _i in 3:
		if(Obj2D_IsInGame(_enemy)):
			return
		#-------------------------------------------------------------------------------
		_dir = -_cone/2
		for _j in _num:
			var _bullet: Bullet = CreateShotA1(_enemy.position.x, _enemy.position.y, 4, AngleToPlayer(_enemy)+_dir, 1)
			#Move_Vaccel(_bullet, -0.04, 1)
			_dir += _cone/float(_num-1)
		await Frame_InGame(15)
#-------------------------------------------------------------------------------
func Stage1_Enemy2(_x:float, _y:float, _mirror:float) -> void:
	var _enemy: Enemy = CreateEnemy(_x, _y, 5)
	#Set_VDir(_enemy, 5, 90+90*_mirror)
	#await Move_Vaccel(_enemy, -0.05, 1)
	#await Move_VDir(_enemy, 60)
	await Stage1_Enemy1_Fire(_enemy, 36)
	#await Set_Dir_Rot(_enemy, 6*_mirror, 30)
	#await Move_VDir(_enemy, 15)
	#await Move_Vaccel(_enemy, 0.05, 5)
	#await Move_VDir(_enemy, 60)
	DestroyEnemy(_enemy, 20)
#-------------------------------------------------------------------------------
func Stage1_Wave3():
	var _radX: float = width*0.1*2.5
	var _rotX: float = 190
	var _x2: float = 0
	for _i in 20:
		if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
			return
		#-------------------------------------------------------------------------------
		_rotX += 20
		_x2 = width*0.5+_radX*sin(deg_to_rad(_rotX))
		Stage1_Enemy3(_x2, 0, -1)
		await Frame(15)
#-------------------------------------------------------------------------------
func Stage1_Enemy3(_x:float, _y:float, _mirror:float) -> void:
	var _enemy: Enemy = CreateEnemy(_x, _y, 25)
	var _radX: float = width*0.1*2.5
	var _rotX: float = 90+90*_mirror
	var _x2: float = 0
	while(_enemy != null):
		if(_y < height and Obj2D_IsInGame(_enemy)):
			_rotX += 4 * deltaTimeScale
			_x2 = _x+_radX*sin(deg_to_rad(_rotX))
			_y += 1 * deltaTimeScale
			_enemy.position = Vector2(_x2, _y)
		else:
			DestroyEnemy(_enemy, 20)
			return
		await frame
#endregion
#-------------------------------------------------------------------------------
#region STAGE 2
func Stage2():
	await StageCommon("Stage 2 Completed",2,1)
#-------------------------------------------------------------------------------
func Stage3():
	await StageCommon("Stage 3 Completed",3,2)
#-------------------------------------------------------------------------------
func Stage4():
	await StageCommon("Stage 4 Completed",4,3)
#-------------------------------------------------------------------------------
func Stage5():
	await StageCommon("Stage 5 Completed",5,4)
#-------------------------------------------------------------------------------
func Stage6():
	await StageCommon("Stage Final Completed",6,5)
#-------------------------------------------------------------------------------
func Stage7():
	await StageCommon("Stage Extra Completed",7,6)
#-------------------------------------------------------------------------------
func Stage8():
	await StageCommon("Rogue-Like Mode Completed",8,7)
#-------------------------------------------------------------------------------
func Stage9():
	await StageCommon("Boss-Rush Mode Completed",8,8)
#-------------------------------------------------------------------------------
func StageCommon(_s:String, _enabled:int, _completed:int):
	await ShowBanner(_s)
	EnableStage(_enabled)
	CompletedStage(_completed)
	singleton.Save_SaveData_Json(singleton.optionMenu.optionSaveData_Json["saveIndex"])
	singleton.CommonSubmited()
	GoToMainScene()
#-------------------------------------------------------------------------------
func EnableStage(_i:int):
	var _playerIndex: StringName = str(singleton.currentSaveData_Json["playerIndex"])
	var _difficultyIndex: StringName = str(singleton.currentSaveData_Json["difficultyIndex"])
	if(singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] == singleton.STAGE_STATE.DISABLED):
		singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] = singleton.STAGE_STATE.ENABLED
#-------------------------------------------------------------------------------
func CompletedStage(_i:int):
	var _playerIndex: StringName = str(singleton.currentSaveData_Json["playerIndex"])
	var _difficultyIndex: StringName = str(singleton.currentSaveData_Json["difficultyIndex"])
	singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] = singleton.STAGE_STATE.COMPLETED
#-------------------------------------------------------------------------------
func GoToMainScene():
	singleton.PlayBGM(singleton.bgmTitle)
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file(singleton.mainScene_Path)
#endregion
#-------------------------------------------------------------------------------
#region STAGE FUNCTIONS
func WaveOfEnemies_and_Market(_s:String, _c:Callable, _time:int):
	await WaveOfEnemies(_s, _c, _time)
	await OpenMarket()
	Enter_GameState()
#-------------------------------------------------------------------------------
func WaveOfEnemies(_s:String, _c:Callable, _time:int):
	await ShowBanner(_s)
	_c.call()
	await StartTimer(_time)
#-------------------------------------------------------------------------------
func BossAttack_and_Market(_boss:Enemy, _hp:int, _s:String, _c:Callable, _timer:int):
	await BossAttack(_boss, _hp, _s, _c, _timer)
	await OpenMarket()
	Enter_GameState()
#-------------------------------------------------------------------------------
func BossAttack(_boss:Enemy, _hp:int, _s:String, _c1:Callable, _timer:int):
	myGAME_STATE = GAME_STATE.IN_CUTIN
	await ShowBanner(_s)
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	Activate_Enemy(_boss, _hp)
	_c1.call(_boss)
	await StartTimer_WithBoss(_boss, _timer)
	Deactivate_Enemy(_boss)
	Enemy_SpawnItems(_boss, _boss.position.x, _boss.position.y, 20)
#-------------------------------------------------------------------------------
func StartTimer(_time:int):
	var _maxTimer: String = "s / "+str(_time)+"s"
	_time+=1
	timerLabel.show()
	#-------------------------------------------------------------------------------
	while(_time > 0):
		if(myGAME_STATE != GAME_STATE.IN_GAMEOVER):
			_time -=1
			timerLabel.text = str(_time)+_maxTimer
		#-------------------------------------------------------------------------------
		await Frame(60)
	#-------------------------------------------------------------------------------
	timerLabel.text = ""
	timerLabel.hide()
#-------------------------------------------------------------------------------
func StartTimer_WithBoss(_boss:Enemy, _time:int):
	var _maxTimer: String = "s / "+str(_time)+"s"
	_time+=1
	timerLabel.show()
	#-------------------------------------------------------------------------------
	while(_time > 0):
		if(_boss.myOBJECT2D_STATE == Enemy.OBJECT2D_STATE.DEATH):
			break
		#-------------------------------------------------------------------------------
		if(myGAME_STATE != GAME_STATE.IN_GAMEOVER):
			_time -=1
			timerLabel.text = str(_time)+_maxTimer
		#-------------------------------------------------------------------------------
		await Frame_WithBoss(_boss, 60)
	#-------------------------------------------------------------------------------
	timerLabel.text = ""
	timerLabel.hide()
#-------------------------------------------------------------------------------
func ShowBanner(_s:String):
	await Frame(60)
	await ShowBanner2(_s)
#-------------------------------------------------------------------------------
func ShowBanner2(_s:String):
	completedPanel.show()
	completedLabel.text = _s
	await Frame(120)
	completedLabel.text = ""
	completedPanel.hide()
#-------------------------------------------------------------------------------
func OpenMarket():
	myGAME_STATE = GAME_STATE.IN_CUTIN
	await ShowBanner2("Flea Market has being Open")
	myGAME_STATE = GAME_STATE.IN_MARKET
	await marketMenu.OpenMarket()
#-------------------------------------------------------------------------------
func Enter_GameState():
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	PlayerShoot()
#endregion
#-------------------------------------------------------------------------------
#region CREATE ENEMY BULLET
func CreateShotA1(_x:float, _y:float, _vel:float, _dir:float, _frame:int) -> Bullet:
	var _bullet: Bullet = CreateEnemyBullet(_x, _y, _vel, _dir, _frame)
	return _bullet
#-------------------------------------------------------------------------------
func CreateShotA2(_x:float, _y:float, _vel:float, _dir:float, _dirAccel:float, _maxTimer:float, _frame:int) -> Bullet:
	var _bullet: Bullet = CreateEnemyBullet(_x, _y, _vel, _dir, _frame)
	await Move_VDir_DirAccel(_bullet, _vel, _dir, _dirAccel, _maxTimer)
	return _bullet
#-------------------------------------------------------------------------------
func CreateShotA3(_x:float, _y:float, _vel:float, _dir:float, _vAccel:float, _VLimit:float, _frame:int) -> Bullet:
	var _bullet: Bullet = CreateEnemyBullet(_x, _y, _vel, _dir, _frame)
	await Move_VDir_VAccel(_bullet, _vel, _dir, _vAccel, _VLimit)
	return _bullet
#-------------------------------------------------------------------------------
func CreateShotA4(_x:float, _y:float, _vel:float, _dir:float, _dirAccel:float, _vAccel:float, _VLimit:float, _frame:int) -> Bullet:
	var _bullet: Bullet = CreateEnemyBullet(_x, _y, _vel, _dir, _frame)
	await Move_VDir_DirAccel_VAccel(_bullet, _vel, _dir, _dirAccel, _vAccel, _VLimit)
	return _bullet
#endregion
#-------------------------------------------------------------------------------
#region ENEMY BULLET FUNCTIONS
func CreateDisabledEnemyBullets(_num:int):
	for _i in _num:
		var _bullet: Bullet = enemyBullet_Prefab.instantiate() as Bullet
		_bullet.myOBJECT2D_STATE = Bullet.OBJECT2D_STATE.DEATH
		enemyBulletsDisabled.push_back(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
#-------------------------------------------------------------------------------
func CreateEnemyBullet(_x:float, _y:float, _vel:float, _dir:float, _frame:int) -> Bullet:
	var _bullet: Bullet
	if(enemyBulletsDisabled.size()>0):
		_bullet = enemyBulletsDisabled[0]
		enemyBulletsDisabled.erase(_bullet)
		_bullet.show()
	else:
		_bullet = enemyBullet_Prefab.instantiate() as Bullet
		content.add_child(_bullet)
	enemyBulletsEnabled.push_back(_bullet)
	_bullet.position = Vector2(_x, _y)
	_bullet.rotation = deg_to_rad(_dir + 90.0)
	_bullet.vel = _vel
	_bullet.dir = _dir
	_bullet.frame = _frame
	_bullet.myOBJECT2D_STATE = Bullet.OBJECT2D_STATE.ALIVE
	#-------------------------------------------------------------------------------
	Bullet_Movement_VDir(_bullet)
	#-------------------------------------------------------------------------------
	return _bullet
#-------------------------------------------------------------------------------
func Bullet_Movement_VDir(_bullet:Bullet) -> void:
	Bullet_Movement_Update(_bullet, Bullet_Movement_VDir_Set)
#-------------------------------------------------------------------------------
func Bullet_Movement_VDir_Set(_bullet:Bullet):
	Obj2D_Set_Common_VDir(_bullet)
	Bullet_Movement_Set(_bullet)
#-------------------------------------------------------------------------------
func Bullet_Movement_VXY(_bullet:Bullet) -> void:
	Bullet_Movement_Update(_bullet, Bullet_Movement_VXY_Set)
#-------------------------------------------------------------------------------
func Bullet_Movement_VXY_Set(_bullet:Bullet):
	Obj2D_Set_Common_VXY(_bullet)
	Bullet_Movement_Set(_bullet)
#-------------------------------------------------------------------------------
func Bullet_Movement_Set(_bullet:Bullet):
	_bullet.position += Vector2(_bullet.velX, _bullet.velY) * deltaTimeScale
	_bullet.rotation = deg_to_rad(_bullet.dir + 90.0)
#-------------------------------------------------------------------------------
func Bullet_Movement_Update(_bullet:Bullet, _callable: Callable) -> void:
	var _isGrazed: bool = false
	while(Obj2D_IsInGame(_bullet)):
		if(0 <= _bullet.position.x and _bullet.position.x <= width):
			if(0 <= _bullet.position.y and _bullet.position.y <= height):
				if(!_isGrazed):
					var _resultB: Array[Dictionary] = Colliding(_bullet, grazeLayer)
					if(_resultB):
						SpawnItem(_bullet.position.x, _bullet.position.y, -4)
						_isGrazed = true
				#-------------------------------------------------------------------------------
				var _result: Array[Dictionary] = Colliding(_bullet, playerLayer)
				if(_result):
					ShootedPlayer(_result[0]["collider"].get_parent(), _bullet)
					break
				#-------------------------------------------------------------------------------
				_callable.call(_bullet)
				#-------------------------------------------------------------------------------
				await frame
			else:
				break
		else:
			break
	#-------------------------------------------------------------------------------
	Destroy_EnemyBullet(_bullet)
#-------------------------------------------------------------------------------
func Destroy_EnemyBullet(_bullet:Bullet) -> void:
	_bullet.hide()
	_bullet.position = Vector2.ZERO
	_bullet.myOBJECT2D_STATE = Bullet.OBJECT2D_STATE.DEATH
	enemyBulletsEnabled.erase(_bullet)
	enemyBulletsDisabled.push_back(_bullet)
#-------------------------------------------------------------------------------
func ShootedPlayer(_player:Player, _bullet:Bullet) -> void:
	match(player.myPLAYER_STATE):
		Player.PLAYER_STATE.ALIVE:
			if(lifePoints > 0):
				await PlayerRespawn(_player)
			else:
				await PlayerGameOver(_player)
#-------------------------------------------------------------------------------
func PlayerRespawn(_player:Player):
	lifePoints -= 1
	SetInfoText_Life()
	PlayerDeath(_player)
	await Frame(15)
	#-------------------------------------------------------------------------------
	var _timer: float = 30
	PlayerInvincible(_player, _timer)
	await MovePlayer_Towards(player, _timer*2)
	#-------------------------------------------------------------------------------
	_player.myPLAYER_STATE = Player.PLAYER_STATE.INVINCIBLE
	_player.magnet.shape.disabled = false
	_player.graze.shape.disabled = false
	_player.show()
	await PlayerInvincible(_player, 60)
	#-------------------------------------------------------------------------------
	_player.hitBox.shape.disabled = false
	_player.myPLAYER_STATE = Player.PLAYER_STATE.ALIVE
#-------------------------------------------------------------------------------
func MovePlayer_Towards(_player:Player, _maxTimer:float) -> void:
	player.position = Vector2(width*0.5, height*1.2)
	player.show()
	var _dx: float = (width*0.5-_player.position.x)/float(_maxTimer)
	var _dy: float = (height*0.85-_player.position.y)/float(_maxTimer)
	var _timer: float = 0
	while(_timer < _maxTimer):
		_timer += deltaTimeScale
		_player.position += Vector2(_dx, _dy) * deltaTimeScale
		await frame
#-------------------------------------------------------------------------------
func PlayerInvincible(_player:Player, _maxTimer: float) -> void:
	var _b: bool = true
	var _timer: float = 0
	while(_timer < _maxTimer):
		SetPlayerInvisible(_player, _b)
		_timer += deltaTimeScale
		_b = !_b
		await Frame(2)
#-------------------------------------------------------------------------------
func SetPlayerInvisible(_player:Player, _b:bool) -> void:
	if(_b):
		_player.self_modulate.a = 0
		_player.hitBox.sprite.self_modulate.a = 0
	else:
		_player.self_modulate.a = 1
		_player.hitBox.sprite.self_modulate.a = 1
#-------------------------------------------------------------------------------
func PlayerGameOver(_player:Player) -> void:
	myGAME_STATE = GAME_STATE.IN_GAMEOVER
	SetInfoText_Death()
	PlayerDeath(_player)
	#-------------------------------------------------------------------------------
	await Frame(120)
	StopTime()
	gameoverMenu.show()
	singleton.MoveToButton(gameoverMenu.retry)
#-------------------------------------------------------------------------------
func PlayerDeath(_player:Player) -> void:
	_player.myPLAYER_STATE = Player.PLAYER_STATE.DEATH
	PlayerExplotion(_player)
	_player.hide()
	_player.magnet.shape.disabled = true
	_player.graze.shape.disabled = true
	_player.hitBox.shape.disabled = true
	#-------------------------------------------------------------------------------
	for _item in itemsEnabled:
		if(_item.myITEM_STATE == Item.ITEM_STATE.IMANTED):
			_item.velY = -4
			_item.myITEM_STATE = Item.ITEM_STATE.SPIN
#-------------------------------------------------------------------------------
func PlayerExplotion(_node2D:Node2D):
	var _particle: GPUParticles2D = playerExplotion.instantiate() as GPUParticles2D
	_particle.position = _node2D.position
	_particle.rotation = _node2D.rotation
	_particle.emitting = true
	content.add_child(_particle)
#endregion
#-------------------------------------------------------------------------------
#region ENEMY FUNCTIONS
func CreateEnemy(_x:float, _y:float, _hp: int) -> Enemy:
	var _enemy = enemy_Prefab.instantiate() as Enemy
	_enemy.position = Vector2(_x, _y)
	_enemy.maxHp = _hp
	_enemy.hp = _hp
	_enemy.myOBJECT2D_STATE = Enemy.OBJECT2D_STATE.ALIVE
	SetHp(_enemy)
	_enemy.collider.disabled = false
	_enemy.label.show()
	content.add_child(_enemy)
	#-------------------------------------------------------------------------------
	Enemy_Movement(_enemy)
	#-------------------------------------------------------------------------------
	return _enemy
func CreateBoss(_x:float, _y:float) -> Enemy:
	var _boss = enemy_Prefab.instantiate() as Enemy
	_boss.position = Vector2(_x, _y)
	_boss.canBeHit = false
	_boss.collider.disabled = true
	_boss.label.hide()
	content.add_child(_boss)
	#-------------------------------------------------------------------------------
	return _boss
#-------------------------------------------------------------------------------
func Activate_Enemy(_boss: Enemy, _hp: int):
	_boss.maxHp = _hp
	_boss.hp = _hp
	_boss.myOBJECT2D_STATE = Enemy.OBJECT2D_STATE.ALIVE
	SetHp(_boss)
	_boss.canBeHit = true
	_boss.collider.disabled = false
	_boss.label.show()
	Enemy_Movement(_boss)
#-------------------------------------------------------------------------------
func Deactivate_Enemy(_boss: Enemy):
	_boss.hp = _boss.maxHp
	#_boss.myOBJECT2D_STATE = Enemy.OBJECT2D_STATE.ALIVE
	_boss.canBeHit = false
	_boss.collider.disabled = true
	_boss.label.hide()
#-------------------------------------------------------------------------------
func Enemy_Movement(_enemy:Enemy):
	while(Obj2D_IsInGame(_enemy)):
		Obj2D_Set_Common_VDir(_enemy)
		_enemy.position += Vector2(_enemy.velX, _enemy.velY) * deltaTimeScale
		#-------------------------------------------------------------------------------
		await frame
#-------------------------------------------------------------------------------
func SetHp(_enemy:Enemy) -> void:
	_enemy.label.text = str(_enemy.hp)+"/"+str(_enemy.maxHp)+" HP"
#-------------------------------------------------------------------------------
func DestroyEnemy(_enemy:Enemy, _num:int) -> void:
	Enemy_SpawnItems(_enemy, _enemy.position.x, _enemy.position.y, _num)
	Death_Enemy(_enemy)
#-------------------------------------------------------------------------------
func DestroyEnemy_WithRevenge(_enemy:Enemy, _num:int, _callable:Callable) -> void:
	if(_enemy.myOBJECT2D_STATE == Enemy.OBJECT2D_STATE.DEATH):
		SpawnItems(_enemy.position.x, _enemy.position.y, 40.0, _num)
		_callable.call()
	Death_Enemy(_enemy)
#-------------------------------------------------------------------------------
func Death_Enemy(_enemy:Enemy) -> void:
	_enemy.queue_free()
#-------------------------------------------------------------------------------
func Enemy_SpawnItems(_enemy:Enemy, _x:float, _y:float, _num:int):
	if(_enemy.myOBJECT2D_STATE == Enemy.OBJECT2D_STATE.DEATH):
		SpawnItems(_x, _y, float(_num)*2, _num)
#endregion
#-------------------------------------------------------------------------------
#region OBJECT2D FUNCTIONS
func Move_Towards(_obj2D:Object2D, _x2:float, _y2:float, _maxTimer:float) -> void:
	if(!Obj2D_IsInGame(_obj2D)):
		return
	var _x1: float = _obj2D.position.x
	var _y1: float = _obj2D.position.y
	if(_x2 == _x1 and _y2 == _y1):
		return
	var _dx: float = _x2 - _x1
	var _dy: float = _y2 - _y1
	_obj2D.vel = Vector2(_dx, _dy).length() / _maxTimer
	_obj2D.dir = GetAngleXY(_dx, _dy)
	#-------------------------------------------------------------------------------
	var _timer: float = 0
	while(_timer < _maxTimer):
		if(!Obj2D_IsInGame(_obj2D)):
			return
		_timer += deltaTimeScale
		await frame
	_obj2D.vel = 0
#-------------------------------------------------------------------------------
func Move_Towards_Old(_obj2D:Object2D, _x:float, _y:float,_maxTimer:float) -> void:
	var _dx: float = (_x-_obj2D.position.x)/float(_maxTimer)
	var _dy: float = (_y-_obj2D.position.y)/float(_maxTimer)
	var _timer: float = 0
	while(_timer < _maxTimer):
		_timer += deltaTimeScale
		_obj2D.position += Vector2(_dx, _dy) * deltaTimeScale
		await frame
#-------------------------------------------------------------------------------
func Move_VDir(_obj2D:Object2D, _vel:float, _dir:float, _maxTimer:float) -> void:
	if(!Obj2D_IsInGame(_obj2D)):
		return
	_obj2D.vel = _vel
	_obj2D.dir = _dir
	#-------------------------------------------------------------------------------
	var _timer: float = 0
	while(_timer < _maxTimer):
		if(!Obj2D_IsInGame(_obj2D)):
			return
		_timer += deltaTimeScale
		await frame
#-------------------------------------------------------------------------------
func Move_VDir_DirAccel(_obj2D:Object2D, _vel:float, _dir:float, _dirAccel:float, _maxTimer:float) -> void:
	if(!Obj2D_IsInGame(_obj2D)):
		return
	_obj2D.vel = _vel
	_obj2D.dir = _dir
	#-------------------------------------------------------------------------------
	var _timer: float = 0
	while(_timer < _maxTimer):
		if(!Obj2D_IsInGame(_obj2D)):
			return
		_timer += deltaTimeScale
		_obj2D.dir += _dirAccel * deltaTimeScale
		await frame
#-------------------------------------------------------------------------------
func Move_VDir_VAccel(_obj2D:Object2D, _vel:float, _dir:float, _velAccel:float, _velLimit:float) -> void:
	if(!Obj2D_IsInGame(_obj2D)):
		return
	_obj2D.vel = _vel
	_obj2D.dir = _dir
	#-------------------------------------------------------------------------------
	if(_velAccel < 0):
		while(Obj2D_IsInGame(_obj2D)):
			if(_obj2D.vel < _velLimit):
				_obj2D.vel = _velLimit
				return
			else:
				_obj2D.vel += _velAccel * deltaTimeScale
			await frame
	elif(_velAccel > 0):
		while(Obj2D_IsInGame(_obj2D)):
			if(_obj2D.vel > _velLimit):
				_obj2D.vel = _velLimit
				return
			else:
				_obj2D.vel += _velAccel * deltaTimeScale
			await frame
#-------------------------------------------------------------------------------
func Move_VDir_DirAccel_VAccel(_obj2D:Object2D, _vel:float, _dir:float, _dirAccel:float, _velAccel:float, _velLimit:float) -> void:
	if(!Obj2D_IsInGame(_obj2D)):
		return
	_obj2D.vel = _vel
	_obj2D.dir = _dir
	#-------------------------------------------------------------------------------
	if(_velAccel < 0):
		while(Obj2D_IsInGame(_obj2D)):
			if(_obj2D.vel < _velLimit):
				_obj2D.vel = _velLimit
				return
			else:
				_obj2D.dir += _dirAccel * deltaTimeScale
				_obj2D.vel += _velAccel * deltaTimeScale
			await frame
	elif(_velAccel > 0):
		while(Obj2D_IsInGame(_obj2D)):
			if(_obj2D.vel > _velLimit):
				_obj2D.vel = _velLimit
				return
			else:
				_obj2D.dir += _dirAccel * deltaTimeScale
				_obj2D.vel += _velAccel * deltaTimeScale
			await frame
#-------------------------------------------------------------------------------
func Obj2D_Set_Common_VDir(_obj2D:Object2D) -> void:
	var _dir: float = deg_to_rad(_obj2D.dir)
	_obj2D.velX = _obj2D.vel*cos(_dir)
	_obj2D.velY = _obj2D.vel*sin(_dir)
#-------------------------------------------------------------------------------
func Obj2D_Set_Common_VXY(_obj2D:Object2D) -> void:
	_obj2D.dir = GetAngleXY(_obj2D.velX, _obj2D.velY)
	_obj2D.vel = Vector2(_obj2D.velX, _obj2D.velY).length()
#-------------------------------------------------------------------------------
#NOTA IMPORTANTE: _obj2D no lo puedo definir porque aveces toma valor Null, y Godot no sabe que hacer cuando un parametro definido toma valor Null
func Obj2D_IsInGame(_obj2D) -> bool:
	if(_obj2D != null):
		if(_obj2D.myOBJECT2D_STATE == Object2D.OBJECT2D_STATE.ALIVE and myGAME_STATE == GAME_STATE.IN_GAMEPLAY):
			return true
		else:
			return false
	else:
		return false
#endregion
#-------------------------------------------------------------------------------
#region MATH FUNCTIONS
func AngleToPlayer(_obj: Node2D) -> float:
	var _f: float = rad_to_deg(atan2(player.position.y-_obj.position.y, player.position.x-_obj.position.x))
	return _f
#-------------------------------------------------------------------------------
func GetAngleFromTo(_obj1: Node2D, _obj2: Node2D) -> float:
	var _f: float = rad_to_deg(atan2(_obj2.position.y-_obj1.position.y, _obj2.position.x-_obj1.position.x))
	return _f
#-------------------------------------------------------------------------------
func GetAngleXY(_dx: float, _dy: float) -> float:
	var _f: float = rad_to_deg(atan2(_dy, _dx))
	return _f
#endregion
#-------------------------------------------------------------------------------
#region COMMON FUNCTIONS
func Colliding(_sprite:Sprite2D, _layer) -> Array[Dictionary]:
	var _shape_rid :RID = PhysicsServer2D.rectangle_shape_create()
	var _half_extents :Vector2 = _sprite.size
	PhysicsServer2D.shape_set_data(_shape_rid, _half_extents)
	#-------------------------------------------------------------------------------
	var _query :PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	_query.shape_rid = _shape_rid
	_query.collide_with_bodies = true
	_query.collision_mask = _layer
	_query.transform = _sprite.get_global_transform()
	#-------------------------------------------------------------------------------
	#var _direct_space_state :PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var _result :Array[Dictionary] = _direct_space_state.intersect_shape(_query, 1)
	#-------------------------------------------------------------------------------
	PhysicsServer2D.free_rid(_shape_rid)
	return _result
#-------------------------------------------------------------------------------
func Frame(_maxTimer:int) -> void:
	var _timer: float = 0
	while(_timer < _maxTimer):
		_timer += deltaTimeScale
		await frame
#-------------------------------------------------------------------------------
func Frame_WithBoss(_boss:Enemy, _maxTimer:int) -> void:
	var _timer: float = 0
	while(_timer < _maxTimer):
		_timer += deltaTimeScale
		if(_boss.myOBJECT2D_STATE == Enemy.OBJECT2D_STATE.DEATH):
			return
		await frame
#-------------------------------------------------------------------------------
func Frame_InGame(_maxTimer:int) -> void:
	var _timer: float = 0
	while(_timer < _maxTimer):
		_timer += deltaTimeScale
		if(myGAME_STATE != GAME_STATE.IN_GAMEPLAY):
			return
		await frame
#-------------------------------------------------------------------------------
func WaitEnemyDeath(_enemy:Enemy):
	while(Obj2D_IsInGame(_enemy)):
		await frame
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	singleton.DisconnectAll(singleton.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	singleton.optionMenu.idiomeChange.connect(pauseMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(SetIdiome2)
	#-------------------------------------------------------------------------------
	pauseMenu.SetIdiome()
	SetIdiome2()
#-------------------------------------------------------------------------------
func SetIdiome2():
	maxScoreLabel_title.text = "[u]"+tr("gameUI_maxScore")+":[/u]"
	scoreLabel_title.text = "[u]"+tr("gameUI_score")+":[/u]"
	livesLabel_title.text = "[u]"+tr("gameUI_lives")+":[/u]"
	powerLabel_title.text = "[u]"+tr("gameUI_power")+":[/u]"
#endregion
#-------------------------------------------------------------------------------
