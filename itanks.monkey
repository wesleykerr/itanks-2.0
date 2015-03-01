Strict

Import mojo
Import diddy

Import input
Import screens
Import game_screen
Import tank
Import thumbstick
Import vector

' The overall Game object, handling loading, mouse position, high-level game control and rendering...
Class iTanks Extends DiddyApp

	Method OnCreate:Int()
		Super.OnCreate()
		
		inputCache.monitorTouch = True
		inputCache.monitorMouse = True
		
		SetScreenSize(960, 640)
		
		debugOn = False
		debugKeyOn = False
		drawFPSOn = False

		gDebug = True
		
		Print "Starting the game!"		
		gZoneCount = 4
		LoadAssets()
		
		gTitleScreen = New TitleScreen()
		gGameScreen = New GameScreen()

		gLevelScreens = New ArrayList<LevelSelectScreen>()
		For Local i:=0 Until gZoneCount
			gLevelScreens.Add(New LevelSelectScreen(i))
		End

		gCreditsScreen = New BackgroundScreen("CreditsScreen")

		' now we need to load in the current state.
		'  For now the current state is just the maximum state completed 
		'  successfully and the type of input preferred...
		gGameSaveState = New GameSaveState()
		gGameSaveState.Load()

		gTitleScreen.PreStart()
		Return 0
	End
	
	'This method loads in all of the assets, including images, animations and sounds.
	Method LoadAssets:Void()
		Local tmpImage:Image		
		images.Load("Projectile.png")
		images.LoadAnim("TankBase.png", 64, 64, 16, tmpImage)
		images.LoadAnim("TankExplode.png", 64, 64, 1, tmpImage)
		images.LoadAnim("Weapon.png", 64, 64, 16, tmpImage)
		images.LoadAnim("TankBaseBlue.png", 64, 64, 16, tmpImage)
		images.LoadAnim("TankExplodeBlue.png", 64, 64, 1, tmpImage)
		images.LoadAnim("WeaponBlue.png", 64, 64, 16, tmpImage)
		images.LoadAnim("numbers.png", 350, 300, 4, tmpImage)
		images.Load("Health.png")
		images.Load("HealthBG.png")
		images.Load("ThumbstickBG.png")
		images.Load("Handle.png")

		images.LoadAnim("explosion.png", 64, 64, 34, tmpImage)
		images.LoadAnim("hudButtons.png", 64, 64, 6, tmpImage)
		images.LoadAnim("progressButtons.png", 224, 96, 6, tmpImage)
		
		images.Load("CreditsScreen.png")
		
		images.Load("LevelSelectBG.png")
		images.LoadAnim("arrows.png", 64, 128, 4, tmpImage)
		images.LoadAnim("button_details.png", 256, 160, 3, tmpImage)
		
		images.Load("Win.png")
		images.Load("Fail.png")
		
		sounds.Load("bounce")
		sounds.Load("shoot")
		sounds.Load("explosion")
		sounds.Load("tankExplosion")
		
		For Local i:=0 Until gZoneCount
			images.Load("worldTitle" + i + ".png")
			images.LoadAnim("world" + i + ".png", 192, 128, 6, tmpImage)
		End

		gTextFont = New ftFont()
		gTextFont.Load("fonts/impact32")		
	End
	
	Method ExitApp:Void()
		Print "clean up"
	End
End

' Here we go!
Function Main:Int ()
	gGame = New iTanks()	
	Return 0
End