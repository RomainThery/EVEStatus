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
		
		private var _roundedOpacity:Number;
		
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
			opacitySlider.setSliderParams(20, 100, Main.SO.data.settings.alpha);
			opacitySlider.labelPrecision = 0;
			
			OKButton = new PushButton(this, 0, 0, "OK", applySettings);
			cancelButton = new PushButton(this, 0, 0, "Cancel", cancelSettings);
			OKButton.move((width - OKButton.width - cancelButton.width) / 2, height - OKButton.height - 28);
			cancelButton.move((width - cancelButton.width + OKButton.width) / 2, height - cancelButton.height - 28);
			
			opacitySlider.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp(pEvt:MouseEvent):void
		{
			opacitySlider.value = _roundedOpacity * 10;
		}
		
		private function onOpacityChange(pEvt:Event):void
		{
			_roundedOpacity = Math.round(opacitySlider.value / 10);
			if (_roundedOpacity % 2 != 0) _roundedOpacity++;
			Main.APP.alpha = _roundedOpacity / 10;
		}
		
		private function roundDec(numIn:Number, decimalPlaces:int):Number {
		var nExp:int = Math.pow(10,decimalPlaces) ;
		var nRetVal:Number = Math.round(numIn * nExp) / nExp
		return nRetVal;
		} 
		
		private function startMoveDrag(pEvt:MouseEvent):void
		{
			nativeWindow.startMove();
		}
		
		private function applySettings(pEvt:MouseEvent):void
		{
			// Apply change if the application opacity has been changed
			if (Main.SO.data.settings.alpha != opacitySlider.value)
			{
				// Store the opacity submenu in variable for easy reference
				var opacityMenu:NativeMenu = Main.MAIN_APP.opacitySubMenu;
				// Uncheck the previous opacity value selected in the submenu
				opacityMenu.getItemByName(String(Main.SO.data.settings.alpha)).checked = false;
				// Save opacity level in its dedicated SO variable
				Main.SO.data.settings.alpha = opacitySlider.value;
				// Check the new opacity value in the submenu
				opacityMenu.getItemByName(String(Main.SO.data.settings.alpha)).checked = true;
			}
			
			closeWindow();
		}
		
		private function cancelSettings(pEvt:MouseEvent):void
		{
			Main.APP.alpha = Main.SO.data.settings.alpha / 100;
			closeWindow();
		}
		
		private function closeWindow(pEvt:Object = null):void
		{
			nativeWindow.close();
		}
		
	}

}