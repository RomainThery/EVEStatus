package display 
{
	import flash.display.*;
	import com.greensock.*;
	/**
	 * ...
	 * @author Romain Théry
	 */
	public class RotatorCore extends Sprite 
	{
		public var rotatorLED:RotatorLED = new RotatorLED();
		public var rotatorLEDFrame:RotatorLEDFrame = new RotatorLEDFrame();
		public var glowSprite:Sprite = new Sprite();
		public var isOnline:Boolean = false;
		
		public function RotatorCore() 
		{
			addChild(rotatorLEDFrame);
			addChild(rotatorLED);
			rotatorLED.x = rotatorLED.y = 4;
			addChild(glowSprite);
			glowSprite.graphics.beginFill(0xFFFFFF, 1);
			glowSprite.graphics.drawCircle(12, 12, 8);
			glowSprite.blendMode = BlendMode.MULTIPLY;
			glowSprite.doubleClickEnabled = true;
			buttonMode = true;
		}
		
		public function setUpdateStatus():void
		{
			TweenMax.to(rotatorLED, 1, { repeat: -1, alpha:0.2, yoyo:true } );
		}
		
		public function setOnlineStatus():void
		{
			TweenMax.to(rotatorLED, 1, { repeat:0, alpha: 1, colorTransform: { tint:0x008000, tintAmount:0.6 }, glowFilter: { color:0x008000, alpha:1, blurX:60, blurY:60 } } );
			TweenMax.to(glowSprite, 1, { glowFilter: { color:0x008000, alpha:1, blurX:14, blurY:14 } });
		}
		
		public function setOfflineStatus():void
		{
			TweenMax.to(rotatorLED, 1, { repeat:0, alpha: 1, colorTransform: { tint:0x800000, tintAmount:0.6 } } );
			TweenMax.to(glowSprite, 1, { glowFilter: { color:0x800000, alpha:1, blurX:14, blurY:14 } });
		}
		
	}

}