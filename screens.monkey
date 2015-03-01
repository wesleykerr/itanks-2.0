Strict

Import diddy
Import itanks

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class iTanksScreen Extends Screen
	Field menu:iTanksMenu
	
	' screen...
	Field backScreen:Screen
	
	'----------------------------------------------------------------------
	Method New()
		menu = New iTanksMenu("ButtonOver", "ButtonClick", True)		
	End
	
	'----------------------------------------------------------------------
	Method Start:Void()
		gGame.screenFade.Start(50, False)
	End
	
	'----------------------------------------------------------------------
	' The back button will take you back to some screen.	
	'----------------------------------------------------------------------
	Method AddBackButton:Void(screen:Screen)
		Local back:GameImage = gGame.images.Find("hudButtons")
		Local backBtn:iTanksButton = New iTanksButton(back, 75, 75, 0, 1)
		backBtn.name = "back".ToUpper()
		menu.AddButton(backBtn)
		
		backScreen = screen
	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		menu.Draw()
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		menu.Update()
		
		If menu.Clicked("back") Or KeyHit(KEY_ESCAPE) Then
			gGame.screenFade.Start(10, True)
			gGame.nextScreen = backScreen
		End		
	End	
	
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class TitleScreen Extends Screen

	Field playMenu:SimpleMenu
	Field leftMenu:SimpleMenu
	Field rightMenu:SimpleMenu
	
	Field bgImage:Image
	
	Method New()
		name = "TitleScreen"
		bgImage = LoadImage("graphics/mainMenu.png")

		playMenu = New SimpleMenu("ButtonOver", "ButtonClick", 480-174, 400, 10, True)
		playMenu.AddButton("playMenuButton.png", "playMenuButtonHover.png")
		
		leftMenu = New SimpleMenu("ButtonOver", "ButtonClick", 20, 430, 10, True)
		leftMenu.AddButton("creditsMenuButton.png", "creditsMenuButtonHover.png")

		rightMenu = New SimpleMenu("ButtonOver", "ButtonClick", 750, 430, 30, True)
		rightMenu.AddButton("quitInGameButton.png", "quitInGameButtonHover.png")
	End
	
	Method Start:Void()
		gGame.screenFade.Start(50, False)
	End
	
	Method Render:Void()
		Cls
		
		DrawImage(bgImage, 0, 0, 0)
		playMenu.Draw()
		leftMenu.Draw()
		rightMenu.Draw()
		
				
		'DrawText("Game Size: " + DEVICE_WIDTH + " " + DEVICE_HEIGHT, 10, 50)
		'DrawText("Game Size: " + SCREEN_WIDTH + " " + SCREEN_HEIGHT, 10, 60)

		gTextFont.Draw("Version 1.0", 10, SCREEN_HEIGHT-60)
	End
	
	Method Update:Void()
		playMenu.Update()
		leftMenu.Update()
		rightMenu.Update()
		
		If playMenu.Clicked("playMenuButton") Then
			gGame.screenFade.Start(50, True)
			gGame.nextScreen = gLevelScreens.Get(0) 'gGameScreen
		End
		
		If leftMenu.Clicked("creditsMenuButton") Then
			gGame.screenFade.Start(50, True)
			gGame.nextScreen = gCreditsScreen
		End
		
		If KeyHit(KEY_ESCAPE) Or rightMenu.Clicked("menuExitButton")
			gGame.screenFade.Start(50, True)
			gGame.nextScreen = gGame.exitScreen
		End
	End
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class LevelSelectScreen Extends iTanksScreen
	
	Field worldId:Int
	Field levelCount:Int
	
	Field bgImage:GameImage
	Field nameImage:GameImage
	
	Field tutorial:Bool
	
	Method New(worldId:Int)
		Super.New()
		name = "LevelSelect" + worldId
		
		Self.worldId = worldId
		If Self.worldId = 0 Then
			tutorial = True 
		End
		
		bgImage = gGame.images.Find("levelSelectBG")
		nameImage = gGame.images.Find("worldTitle" + worldId)

		AddBackButton(gTitleScreen)		
		
		Local arrows:GameImage = gGame.images.Find("arrows")
		If worldId > 0 Then
			Local leftBtn:iTanksButton = New iTanksButton(arrows, 64, 416, 0, 2)
			leftBtn.name = "leftArrow".ToUpper()
			menu.AddButton(leftBtn)
		End
		
		If worldId < gZoneCount-1
			Local rightBtn:iTanksButton = New iTanksButton(arrows, 896, 416, 1, 3)
			rightBtn.name= "rightArrow".ToUpper()
			menu.AddButton(rightBtn)
		End
		AddLevelButtons()
	End
	
	'----------------------------------------------------------------------
	Method AddLevelButtons:Void()
		Local btnDetails:GameImage = gGame.images.Find("button_details")
		Local levelsImage:GameImage = gGame.images.Find("world" + worldId)
	
		Local x:Float = 256
		Local y:Float = 320

		levelCount = 6
		If tutorial Then
			levelCount = 3
			y = 416
		End

		For Local i:=0 Until levelCount
			If i Mod 3 = 0 Then
				x = 256
			End
			
			If i / 3 = 1 Then
				y = 480
			End
		
			Local b:iTanksButton = New iTanksButton(levelsImage, x, y, i, -1)
			b.name = ("levels"+i).ToUpper()
			b.SetBorder(btnDetails, 1, 2)
			b.SetOverlay(btnDetails, 0)
			
			menu.AddButton(b)
			
			x += 224
		End
	End

	'----------------------------------------------------------------------
	Method Start:Void()
		Super.Start()
		
		If Not tutorial Then
			For Local i:=0 Until levelCount
				Local b:iTanksButton = menu.FindButton("levels"+i)
				If worldId < gGameSaveState.zoneCompleted
					b.UpdateOverlay(False, True)
				Else If worldId > gGameSaveState.zoneCompleted
					b.UpdateOverlay(True, True)
				Else If i <= gGameSaveState.levelCompleted 
					b.UpdateOverlay(False, True)
				Else
					b.UpdateOverlay(True, True)
				End
			End
		End		

	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		Cls
		DrawImage(bgImage.image, SCREEN_WIDTH2, SCREEN_HEIGHT2)
		DrawImage(nameImage.image, SCREEN_WIDTH2, 100)
		Super.Render()
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		Super.Update()
				
		For Local i:=0 Until levelCount
			If menu.Clicked("levels"+i) Then
				gGameScreen.zone = worldId
				gGameScreen.level = i
				gGame.screenFade.Start(50, True)
				gGame.nextScreen = gGameScreen				
			End
		End
		
		If menu.Clicked("leftArrow") Then
			gGame.screenFade.Start(5, True)
			gGame.nextScreen = gLevelScreens.Get(worldId-1)
		End
		
		If menu.Clicked("rightArrow") Then
			gGame.screenFade.Start(5, True)
			gGame.nextScreen = gLevelScreens.Get(worldId+1)
		End
	End	
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class BackgroundScreen Extends iTanksScreen

	Field imageName:String
	Field image:GameImage
	
	'----------------------------------------------------------------------
	Method New(imageName:String)
		Super.New()
		Self.imageName = imageName
		name = imageName + "screen"

		image = gGame.images.Find(imageName)

		AddBackButton(gTitleScreen)
	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		Cls
		DrawImage(image.image, image.w2, image.h2, 0)
		Super.Render()
	End
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class OptionsScreen Extends iTanksScreen

	'----------------------------------------------------------------------
	Method New()
		Super.New()
		Self.imageName = imageName
		name = imageName + "screen"

		image = gGame.images.Find(imageName)

		AddBackButton(gTitleScreen)
	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		Cls
		DrawImage(image.image, image.w2, image.h2, 0)
		Super.Render()
	End
	

End


'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class iTanksMenu Extends List<iTanksButton>
	Field mouseOverName:String = ""
	Field clickedName:String = ""
	Field clearClickedName:Int = 1 

	Field soundMouseOver:GameSound
	Field soundClick:GameSound
	Field useVirtualRes:Bool = False
	
	Method New()
		Error "Please use a different constructor"
	End
	
	Method New(soundMouseOverFile$, soundClickFile$, useVirtualRes:Bool)
		Init(soundMouseOverFile, soundClickFile, useVirtualRes)
	End
	
	Method Init:Void(soundMouseOverFile:String="", soundClickFile:String="", useVirtualRes:Bool)
		Self.Clear()
		Self.useVirtualRes = useVirtualRes
		mouseOverName = ""
		clickedName = ""
		If soundMouseOverFile<>"" Then
			soundMouseOver = New GameSound
			soundMouseOver.Load(soundMouseOverFile)
		End
		If soundClickFile<>"" Then
			soundClick = New GameSound
			soundClick.Load(soundClickFile)		
		End
	End

	Method SetMenuAlpha:Void(alpha:Float)
		Local b:SimpleButton
		For b = Eachin Self
			b.alpha = alpha
		Next
	End

	Method AddButton:Void(button:iTanksButton)
		button.useVirtualRes = Self.useVirtualRes
		button.soundMouseOver = soundMouseOver
		button.soundClick = soundClick
		
		AddLast(button)
	End

	Method FindButton:iTanksButton(name:String)
		name = name.ToUpper()
		Local b:iTanksButton
		For b = Eachin Self
			If b.name = name Then Return b
		Next	
		Return Null
	End
	
	Method Clicked:Int(name:String)
		name = name.ToUpper()
		If name = clickedName
			If clearClickedName Then clickedName = ""
			Return 1		
		Else
			Return 0
		End
	End
	
	Method Update:Int()
		If gGame.screenFade.active
			Return 0
		Endif
		clickedName = ""
		Local b:iTanksButton
		For b = Eachin Self
			b.Update()
			If b.mouseOver Then mouseOverName = b.name
			If b.clicked Then clickedName = b.name	
		Next
		Return 1
	End
	
	Method Precache:Void()
		For Local b:iTanksButton = Eachin Self
			b.Precache()
		Next
	End
	
	Method Draw:Void()
		For Local b:iTanksButton = Eachin Self
			b.Draw()
		Next
	End
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class iTanksButton Extends Sprite
	Field active:Int = 1
	Field clicked:Int = 0
	Field mouseOver:Int = 0
	Field disabled:Bool = False
	Field soundMouseOver:GameSound
	Field soundClick:GameSound

	Field regularFrame:Int
	Field mouseOverFrame:Int
	
	Field border:GameImage
	Field borderFrame:Int
	Field borderMouseOver:Int
	
	Field overlayImage:GameImage
	Field overlayFrame:Int
	Field displayOverlay:Bool
	Field blockMouseOver:Bool

	Field useVirtualRes:Bool = False
	
	' Sprite has a constructor that takes a game image and
	' an x and a y which is pretty nice so we will be using that.
	'----------------------------------------------------------------------
	Method New(image:GameImage, x:Float, y:Float, regularFrame:Int=0, mouseOverFrame:Int=-1)
		Super.New(image, x, y)
		
		Self.regularFrame=regularFrame
		Self.mouseOverFrame=mouseOverFrame
		
		border = Null
		borderFrame = 0
		borderMouseOver = 0		
		
		overlayImage = Null
		overlayFrame = 0
		blockMouseOver = False
	End
	
	'----------------------------------------------------------------------
	Method SetBorder:Void(border:GameImage, borderFrame:Int, borderMouseOver:Int)
		Self.border = border
		Self.borderFrame = borderFrame
		Self.borderMouseOver = borderMouseOver
	End
	
	'----------------------------------------------------------------------
	Method SetOverlay:Void(overlay:GameImage, overlayFrame:Int)
		Self.overlayImage = overlay
		Self.overlayFrame = overlayFrame
	End
	
	'----------------------------------------------------------------------
	Method UpdateOverlay:Void(displayOverlay:Bool, blockMouseOver:Bool)
		Self.displayOverlay = displayOverlay
		If displayOverlay And blockMouseOver
			Self.blockMouseOver = blockMouseOver	
			Self.disabled = True
		Else
			Self.blockMouseOver = False 
			Self.disabled = False 
		End		
	End
		
	'----------------------------------------------------------------------
	Method Precache:Void()
		If image<>Null
			Super.Precache()
		End
	End
	
	'----------------------------------------------------------------------
	Method Draw:Void()
		If active = 0 Then Return
		SetAlpha Self.alpha
		
		If border <> Null Then
			If mouseOver And Not blockMouseOver Then
				DrawImage(border.image, x, y, borderMouseOver)
			Else 
				DrawImage(border.image, x, y, borderFrame)
			End
		End
		
		If mouseOver And mouseOverFrame >= 0 And Not blockMouseOver Then
			DrawImage(Self.image.image, x, y, mouseOverFrame)
		Else
			DrawImage(Self.image.image, x, y, regularFrame)
		Endif
		
		If overlayImage <> Null And displayOverlay Then
			DrawImage(overlayImage.image, x, y, overlayFrame)
		End
		SetAlpha 1
	End
	
	'----------------------------------------------------------------------
	Method Click:Void()
		If clicked = 0
			clicked = 1
			If soundClick <> Null
				soundClick.Play()
			End
		End
	End

	'----------------------------------------------------------------------
	Method SetSound:Void(soundMouseOverFile:String="", soundClickFile:String="")
		If soundMouseOverFile<>"" Then
			soundMouseOver = New GameSound
			soundMouseOver.Load(soundMouseOverFile)
		End
		If soundClickFile<>"" Then
			soundClick = New GameSound
			soundClick.Load(soundClickFile)
		End
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		If active = 0 Or disabled Then Return
		Local mx:Int = gGame.mouseX
		Local my:Int = gGame.mouseY
		If Not useVirtualRes
			mx = MouseX()
			my = MouseY()
		End
		If mx >= (x-image.w2) And mx < (x+image.w2) And my >= (y-image.h2) And my < (y+image.h2) Then
			If mouseOver = 0
				If soundMouseOver <> Null
					soundMouseOver.Play()
				End
			End
			mouseOver = 1
			If MouseHit() Then
				Click()
			Else
				clicked = 0
			End
		Else
			mouseOver = 0	
			clicked = 0
		End
	End
End

