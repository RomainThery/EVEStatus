package display 
{
	import flash.display.*;
	import flash.text.*;
	import com.bit101.components.*;
	import com.greensock.*;
	/**
	 * ...
	 * @author Romain Théry
	 */
	public class RotatorAdd extends Sprite 
	{
		public var rotatorExtension:RotatorExtension = new RotatorExtension();
		public var serverStatus:Label;
		public var notification:Label;
		public var currentPlayers:Label;
		
		public function RotatorAdd() 
		{
			addChild(rotatorExtension);
			scaleX = 0.6;
			scaleY = 0.6;
			alpha = 0;
			
			serverStatus = new Label(this, 49, 3);
			serverStatus.textField.defaultTextFormat = new TextFormat("Visitor", 10, 0x000000, null, null, null, null, null, TextFormatAlign.RIGHT);
			serverStatus.textField.antiAliasType = AntiAliasType.ADVANCED;
			
			notification = new Label(this, 28, 22, "Connecting...");
			notification.textField.defaultTextFormat = new TextFormat("Visitor", 10, 0x000000, null, null, null, null, null, TextFormatAlign.CENTER);
			notification.textField.antiAliasType = AntiAliasType.ADVANCED;
			
			currentPlayers = new Label(this, 12, 35);
			currentPlayers.textField.defaultTextFormat = new TextFormat("Visitor", 15, 0x000000, null, null, null, null, null, TextFormatAlign.RIGHT);
			currentPlayers.textField.antiAliasType = AntiAliasType.ADVANCED;
		}
		
		public function open():void
		{
			TweenMax.to(this, 0.5, { scaleX: 1, scaleY: 1, alpha: 1 } );
		}
		
		public function close():void
		{
			TweenMax.to(this, 0.5, { scaleX: 0.6, scaleY: 0.6, alpha: 0 } );
		}
	}

}