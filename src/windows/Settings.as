package windows 
{
	import flash.display.*;
	import flash.events.*;
	import com.bit101.components.*;
	/**
	 * ...
	 * @author Romain Théry
	 */
	public class Settings extends Window 
	{
		public var nativeWindow:NativeWindow;
		
		public var opacitySlider:HUISlider;
		
		public var OKButton:PushButton;
		public var cancelButton:PushButton;
		
		public function Settings(parent:DisplayObjectContainer = null, pNativeWindow:NativeWindow = null, xpos:Number = 0, ypos:Number = 0) 
		{
			Component.initStage(parent.stage);
			super(parent, xpos, ypos);
			nativeWindow = pNativeWindow;
			setSize(280, 280);
			hasMinimizeButton = false;
			hasCloseButton = true;
			addEventListener(Event.CLOSE, closeWindow);
			draggable = false;
			title = "Settings";
			titleBar.addEventListener(MouseEvent.MOUSE_DOWN, startMoveDrag);
			
			opacitySlider = new HUISlider(this, 10, 10, "Opacity (%)", onOpacityChange);
			opacitySlider.setSliderParams(10, 100, Main.SO.data.settings.alpha * 100);
			
			OKButton = new PushButton(this, 0, 0, "OK", applySettings);
			cancelButton = new PushButton(this, 0, 0, "Cancel", closeWindow);
			OKButton.move((width - OKButton.width - cancelButton.width) / 2, height - OKButton.height - 28);
			cancelButton.move((width - cancelButton.width + OKButton.width) / 2, height - cancelButton.height - 28);
		}
		
		private function onOpacityChange(pEvt:Event):void
		{
			Main.APP.alpha = opacitySlider.value / 100;
		}
		
		private function startMoveDrag(pEvt:MouseEvent):void
		{
			nativeWindow.startMove();
		}
		
		private function applySettings(pEvt:MouseEvent):void
		{
			Main.SO.data.settings.alpha = opacitySlider.value / 100;
			Main.APP.alpha = Main.SO.data.settings.alpha;
			closeWindow();
		}
		
		private function closeWindow(pEvt:Object = null):void
		{
			nativeWindow.close();
		}
		
	}

}