
Import globals
Import vector

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class DeathAnimation

	Field position:Vector	
	
	Field started:Bool
	Field finished:Bool
	
	Field image:GameImage
	Field index:Int
		
	'--------------------------------------------------------------------------
	Method New()
		position = New Vector()
		
		image = gGame.images.Find("explosion")		
		index = 0
		
		started = False 
		finished = False 
	End
	
	'--------------------------------------------------------------------------
	Method Begin:Void(p:Vector)
		position.Set( p.X, p.Y )
		started = True		
	End
		
	'--------------------------------------------------------------------------
	Method Update:Void()
		index += 1
		If index >= 34 Then
			finished = True
		End
	End
	
	'--------------------------------------------------------------------------
	Method Render:Void()
		If index < 34 Then
			DrawImage(image.image, position.X, position.Y, 0, 1.5, 1.5, index)
		End
	End
End
