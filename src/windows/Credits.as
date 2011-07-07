package windows 
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import com.bit101.components.*;
	/**
	 * ...
	 * @author Romain Théry
	 */
	public class Credits extends Window 
	{
		public var nativeWindow:NativeWindow;
		
		public var textArea:Panel;
		public var closeButton:PushButton;
		
		public function Credits(parent:DisplayObjectContainer = null, pNativeWindow:NativeWindow = null, xpos:Number = 0, ypos:Number = 0) 
		{
			Component.initStage(parent.stage);
			super(parent, xpos, ypos);
			nativeWindow = pNativeWindow;
			setSize(280, 280);
			hasMinimizeButton = false;
			hasCloseButton = true;
			addEventListener(Event.CLOSE, closeWindow);
			draggable = false;
			title = "About EVEStatus";
			titleBar.addEventListener(MouseEvent.MOUSE_DOWN, startMoveDrag);
			
			textArea = new Panel(this, 10, 10);
			textArea.setSize(width - 20, 212);
			textArea.color = 0xFFFFFF;
			var appName:Label = new Label(textArea, 6, 2, "EVEStatus");
			appName.textField.defaultTextFormat = new TextFormat(null, 18, 0x000000);
			appName.textField.antiAliasType = AntiAliasType.ADVANCED;
			var appDescription:Label = new Label(textArea, appName.x + 8, appName.y + appName.height + 10, "Widget monitoring EVE Online live server, Tranquility.\nVersion 1.0.5\n    By Romain Théry");
			appDescription.textField.defaultTextFormat = new TextFormat(null, null, 0x454545);
			appDescription.textField.multiline = true;
			var appCredits:Label = new Label(textArea, appName.x, appDescription.y + appDescription.height + 40);
			appCredits.textField.defaultTextFormat = new TextFormat(null, null, 0x4F4F4F);
			appCredits.textField.multiline = true;
			appCredits.text = "Font 'Visitor' by Brian Kent\nAS3 Library 'MinimalComps' by Keith Peters\nAS3 Library 'TweenMax' by Jack Doyle\n\nEVE Online Copyright CCP Games, used without\nauthorization."
			
			//EVEStatus
			//Widget monitoring EVE Online live server, Tranquility.
			//
			//AIR Application by Romain Théry in ActionScript 3.0
			//Font Visitor by Brian Kent
			//AS3 Library MinimalComps by Keith Peters
			//AS3 Library TweenMax by Jack Doyle
			//
			//EVE Online © Copyright CCP Games
			
			closeButton = new PushButton(this, 0, 0, "Close", closeWindow);
			closeButton.move((width - closeButton.width) / 2, height - closeButton.height - 28);
		}
		
		private function startMoveDrag(pEvt:MouseEvent):void
		{
			nativeWindow.startMove();
		}
		
		private function closeWindow(pEvt:Object = null):void
		{
			nativeWindow.close();
		}
		
	}

}