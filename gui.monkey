

Class ITButton Extends Sprite
	Field useVirtualRes:Bool = False
	
	Method Precache:Void()
		If image<>Null
			Super.Precache()
		End
	End
	
	Method Draw:Void()
		If active = 0 Then Return
		SetAlpha Self.alpha
		If mouseOver
			DrawImage Self.imageMouseOver.image, x, y
		Else
			DrawImage Self.image.image, x, y
		Endif
		SetAlpha 1
	End
	
	Method Click:Void()
		If clicked = 0
			clicked = 1
			If soundClick <> Null
				soundClick.Play()
			End
		End
	End
	
	Method CentreX:Void(yCoord:Int)
		If useVirtualRes
			MoveTo((SCREEN_WIDTH-image.w)/2, yCoord)
		Else
			MoveTo((DEVICE_WIDTH-image.w)/2, yCoord)
		End
		
	End
	
	Method MoveBy:Void(dx:Float,dy:Float)
		x+=dx
		y+=dy
	End Method

	Method MoveTo:Void(dx:Float,dy:Float)
		x=dx
		y=dy
	End Method
		
	Method Load:Void(buttonImage:String, mouseOverImage:String = "", soundMouseOverFile:String="", soundClickFile:String="")
		Self.image = New GameImage
		image.Load(game.images.path + buttonImage, False)
		
		If  mouseOverImage <> ""
			imageMouseOver = New GameImage
			imageMouseOver.Load(game.images.path + mouseOverImage, False)
		End
		
		name = StripAll(buttonImage.ToUpper())
		
		If soundMouseOverFile<>"" Then
			soundMouseOver = New GameSound
			soundMouseOver.Load(soundMouseOverFile)
		End
		If soundClickFile<>"" Then
			soundClick = New GameSound
			soundClick.Load(soundClickFile)
		End
	End
	
	Method Update:Void()
		If active = 0 Or disabled Then Return
		Local mx:Int = game.mouseX
		Local my:Int = game.mouseY
		If Not useVirtualRes
			mx = MouseX()
			my = MouseY()
		End
		If mx >= x And mx < x+image.w And my >= y And my < y+image.h Then
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

