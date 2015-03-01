Strict

Import globals
Import vector
Import diddy

Class Thumbstick

	Field x:Int
	Field y:Int
	Field bgImage:Image
	Field handleImage:Image
	Field radius:Float
	Field radiusSquared:Float
	Field isActive:Bool = False
	Field registeredIndex:Int = -1
	Field handleX:Int
	Field handleY:Int
	Field normal:Vector
	Field inside:Bool = True
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
		handleX = x
		handleY = y
		bgImage = gGame.images.Find("ThumbstickBG").image
		handleImage = gGame.images.Find("Handle").image
		radius = bgImage.Width() / 2
		radiusSquared = radius * radius
		
		normal = New Vector()
	End

	Method Register:Void(x:Int, y:Int, index:Int)
		Local vector:Vector = New Vector(x - Self.x, y - Self.y)

		If vector.LengthSquared() <= radiusSquared
			registeredIndex = index
			handleX = x
			handleY = y
		End	
		
	End
	
	Method Unregister:Void()
		registeredIndex = -1
		handleX = x
		handleY = y
		normal.Set(0,0)
		inside = True
	End

	Method Update:Void(x:Int, y:Int)
		Local vector:Vector = New Vector(x - Self.x, y - Self.y)
		
		inside = (vector.LengthSquared() <= radiusSquared)
	

		vector.Normalize()
		normal.Set(vector.X, vector.Y)
		
		If inside
			'Print "Inside"
			handleX = x
			handleY = y
		Else
			'Print "Outside"
			vector.ScaleLocal(radius)
			handleX = Self.x + vector.X
			handleY = Self.y + vector.Y
		End
	End

	Method Render:Void()
		If isActive
			DrawImage(bgImage, x, y)
			DrawImage(handleImage, handleX, handleY);
		End
	End
End


