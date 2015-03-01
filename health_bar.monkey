Import globals

Class HealthBar

	Field imageWidth:Float
	Field image:GameImage
	Field bgImage:GameImage
	
	Method New()
		image = gGame.images.Find("Health")
		image.MidHandle(False)
		bgImage = gGame.images.Find("HealthBG")
		bgImage.MidHandle(False)
	End
	

	Method Render(position:Vector)
		If image And bgImage Then
			Local offset:Int = bgImage.w2
			DrawImage(bgImage.image, position.X - offset, position.Y - 40, 0, 1, 1, 0)
			DrawImageRect(image.image, position.X - offset, position.Y - 40, 0, 0, Int(imageWidth), image.h, 0)
		End
	End
	
	Method Update(currentHP:Float, hpMax:Float)
		imageWidth = image.w * (currentHP / hpMax)
	End
End
