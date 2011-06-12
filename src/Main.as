package 
{
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.errors.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import com.bit101.components.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	import display.*;
	import windows.*;
	/**
	 * ...
	 * @author Romain Théry
	 */
	public class Main extends Sprite 
	{
		[Embed(source="../lib/visitor.ttf", embedAsCFF="false", fontName="Visitor", mimeType="application/x-font")]
		protected var VisitorFont:Class;
		
		public static var SO:SharedObject = SharedObject.getLocal("EVEStatus");
		public static var MAIN_APP:Main;
		public static var APP:Sprite;
		
		public var rotatorInnerContainer:Sprite = new Sprite();
		public var rotatorInner:RotatorInner = new RotatorInner();
		public var rotatorOuterContainer:Sprite = new Sprite();
		public var rotatorOuter:RotatorOuter = new RotatorOuter();
		public var rotatorCore:RotatorCore = new RotatorCore();
		public var rotatorAdd:RotatorAdd = new RotatorAdd();
		
		public var urlLoader:URLLoader;
		public var urlRequest:URLRequest;
		public var xmlData:XML;
		
		public var updateTimer:Timer = new Timer(150000, 0);
		
		public var appWindow:NativeWindow;
		public var settingsWindow:NativeWindow;
		public var creditsWindow:NativeWindow;
		public var appContainer:Sprite = new Sprite();
		
		public var rightClickMenu:NativeMenu;
		public var alwaysOnTop:NativeMenuItem;
		public var opacitySubMenu:NativeMenu;
		
		public function Main()
		{
			NativeApplication.nativeApplication.autoExit = false;
			stage.nativeWindow.close();
			MAIN_APP = this;
			
			// Setting up the SO if it's the first time the app is run
			if (SO.size == 0)
			{
				var settingsObj:Object = new Object();
				SO.data.settings = settingsObj;
				SO.data.settings.alwaysOnTop = false;
				SO.data.settings.alphaDefault = 60;
				SO.data.settings.alpha = SO.data.settings.alphaDefault;
			}
			
			var appWindowOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			appWindowOptions.type = NativeWindowType.LIGHTWEIGHT;
			appWindowOptions.transparent = true;
			appWindowOptions.systemChrome = NativeWindowSystemChrome.NONE;
			appWindow = new NativeWindow(appWindowOptions);
			appWindow.width = 180;
			appWindow.height = 130;
			appWindow.activate();
			
			Component.initStage(appWindow.stage);
			appWindow.stage.addChild(appContainer);
			appContainer.alpha = SO.data.settings.alpha / 100;
			APP = appContainer;
			
			appContainer.addChild(rotatorOuterContainer);
			rotatorOuterContainer.addChild(rotatorOuter);
			rotatorOuter.x = rotatorOuter.y = - rotatorOuter.width / 2;
			rotatorOuterContainer.x = rotatorOuterContainer.y = rotatorOuter.width / 2;
			
			appContainer.addChild(rotatorInnerContainer);
			rotatorInnerContainer.addChild(rotatorInner);
			rotatorInner.x = rotatorInner.y = - rotatorInner.width / 2;
			rotatorInnerContainer.x = rotatorInnerContainer.y = rotatorInner.width / 2 + 8;
			
			appContainer.addChild(rotatorCore);
			rotatorCore.x = rotatorCore.y = 20;
			rotatorCore.addEventListener(MouseEvent.MOUSE_OVER, onCoreOver);
			rotatorCore.addEventListener(MouseEvent.MOUSE_OUT, onCoreOut);
			rotatorCore.addEventListener(MouseEvent.MOUSE_DOWN, startMoveDrag);
			rotatorCore.addEventListener(MouseEvent.MOUSE_UP, reopenRotator);
			rotatorCore.addEventListener(MouseEvent.DOUBLE_CLICK, openSettings, true, 1);
			
			appContainer.addChild(rotatorAdd);
			rotatorAdd.x = rotatorAdd.y = 32;
			
			TweenMax.to(rotatorOuterContainer, 3, { repeat: -1, rotation: 360, ease: Linear.easeNone } );
			TweenMax.to(rotatorInnerContainer, 3, { repeat: -1, rotation: -360, ease: Linear.easeNone } );
			urlRequest = new URLRequest("http://apitest.eveonline.com/server/ServerStatus.xml.aspx");
			//urlRequest = new URLRequest("https://api.eveonline.com/server/ServerStatus.xml.aspx");
			urlRequest.method = URLRequestMethod.POST;
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, updateData);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			try
			{
				urlLoader.load(urlRequest);
			}
			catch (pError:Error)
			{
				trace(pError.errorID + ": " + pError.message)
				rotatorAdd.notification.text = "Connection Failure";
			}
			
			
			updateTimer.start();
			updateTimer.addEventListener(TimerEvent.TIMER, checkUpdate);
			
			// Context menu when right-clicking rotatorCore or the systray icon
			var rightClickMenu:NativeMenu = new NativeMenu();
			rotatorCore.contextMenu = rightClickMenu;
			//// Always on top option
			alwaysOnTop = new NativeMenuItem("Always on top");
			alwaysOnTop.addEventListener(Event.SELECT, toggleAlwaysOnTop);
			rightClickMenu.addItem(alwaysOnTop);
			//// Submenu to manage the application opacity
			opacitySubMenu = new NativeMenu();
			rightClickMenu.addSubmenu(opacitySubMenu, "Opacity");
			var opacityChoice:NativeMenuItem;
			for (var i:int = 0; i < 5; i++) 
			{
				opacityChoice = new NativeMenuItem(String(i * 20 + 20) + "%");
				opacityChoice.name = String(i * 20 + 20);
				opacityChoice.addEventListener(Event.SELECT, onOpacityPicked);
				opacitySubMenu.addItem(opacityChoice);
			}
			////// Checked the current opacity level in the opacity submenu
			opacitySubMenu.getItemByName(String(Main.SO.data.settings.alpha)).checked = true;
			var separatorA:NativeMenuItem = new NativeMenuItem("A", true);
			rightClickMenu.addItem(separatorA);
			var settings:NativeMenuItem = new NativeMenuItem("Settings");
			settings.addEventListener(Event.SELECT, openSettings);
			rightClickMenu.addItem(settings);
			var credits:NativeMenuItem = new NativeMenuItem("About...");
			credits.addEventListener(Event.SELECT, openCredits);
			rightClickMenu.addItem(credits);
			var separatorB:NativeMenuItem = new NativeMenuItem("B", true);
			rightClickMenu.addItem(separatorB);
			var exit:NativeMenuItem = new NativeMenuItem("Close");
			exit.addEventListener(Event.SELECT, closeApp);
			rightClickMenu.addItem(exit);
			
			// Enable the Systray / Dock icon depending on the OS running the app
            var icon:Loader = new Loader();
            if (NativeApplication.supportsSystemTrayIcon)
			{
                icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
                icon.load(new URLRequest("icons/EVEStatus_16.png"));
                
                var systray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
                systray.tooltip = "EVEStatus";
                systray.menu = rightClickMenu;
            }
			
            if (NativeApplication.supportsDockIcon)
			{
                icon.contentLoaderInfo.addEventListener(Event.COMPLETE,iconLoadComplete);
                icon.load(new URLRequest("icons/EVEStatus_128.png"));
                var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon; 
                dock.menu = rightClickMenu;
            }
		}
		
        private function iconLoadComplete(pEvt:Event):void
        {
            NativeApplication.nativeApplication.icon.bitmaps = [pEvt.target.content.bitmapData];
        }
		
		private function onIOError(pEvt:IOErrorEvent):void
		{
			trace(pEvt.errorID + ": " + pEvt.text)
			rotatorAdd.notification.text = "Connection Failure";
		}
		
		private function checkUpdate(pEvt:TimerEvent):void
		{
			TweenMax.to(rotatorOuterContainer, 3, { repeat: -1, rotation:360, ease:Linear.easeNone } );
			TweenMax.to(rotatorInnerContainer, 3, { repeat: -1, rotation:-360, ease:Linear.easeNone } );
			rotatorCore.setUpdateStatus();
			
			urlLoader.load(urlRequest);
		}
		
		private function updateData(pEvt:Event):void
		{
			xmlData = new XML(urlLoader.data);
			rotatorAdd.notification.text = "";
			
			if (xmlData.result.serverOpen == "True")
			{
				TweenMax.to(rotatorOuterContainer, 1, { repeat: 0, shortRotation: { rotation:360 }, ease:Linear.easeNone } );
				TweenMax.to(rotatorInnerContainer, 2, { repeat: 0, rotation: -360, ease:Linear.easeNone } );
				rotatorCore.setOnlineStatus();
				rotatorAdd.serverStatus.text = "Server Online";
				rotatorAdd.serverStatus.textField.textColor = 0x008000;
				rotatorAdd.currentPlayers.text = xmlData.result.onlinePlayers + " players";
			}
			else 
			{
				TweenMax.to(rotatorOuterContainer, 1, { repeat: 0, shortRotation: { rotation:360 }, ease:Linear.easeNone } );
				TweenMax.to(rotatorInnerContainer, 2, { repeat: 0, rotation: -360, ease:Linear.easeNone } );
				rotatorCore.setOfflineStatus();
				rotatorAdd.serverStatus.text = "Server Offline";
				rotatorAdd.serverStatus.textField.textColor = 0x800000;
			}
		}
		
		private function onCoreOver(pEvt:MouseEvent):void
		{
			rotatorAdd.open();
			TweenMax.to(appContainer, 0.5, { alpha: 1 } );
		}
		
		private function onCoreOut(pEvt:MouseEvent):void
		{
			rotatorAdd.close();
			TweenMax.to(appContainer, 0.5, { alpha: SO.data.settings.alpha / 100 } );
		}
		
		private function startMoveDrag(pEvt:MouseEvent):void
		{
			TweenMax.to(rotatorOuterContainer, 0.3, { scaleX: 0, scaleY: 0 } );
			TweenMax.to(rotatorInnerContainer, 0.3, { scaleX: 0, scaleY: 0 } );
			rotatorAdd.close();
			
			appWindow.startMove();
		}
		
		private function reopenRotator(pEvt:MouseEvent):void
		{
			TweenMax.to(rotatorOuterContainer, 0.3, { scaleX: 1, scaleY: 1 } );
			TweenMax.to(rotatorInnerContainer, 0.3, { scaleX: 1, scaleY: 1 } );
			rotatorAdd.open();
		}
		
		private function openSettings(pEvt:Object = null):void
		{
			if (settingsWindow == null || settingsWindow.closed)
			{
				var settingsWindowOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
				settingsWindowOptions.type = NativeWindowType.LIGHTWEIGHT;
				settingsWindowOptions.systemChrome = NativeWindowSystemChrome.NONE;
				settingsWindowOptions.transparent = true;
				settingsWindow = new NativeWindow(settingsWindowOptions);
				settingsWindow.width = 300;
				settingsWindow.height = 300;
				new Settings(settingsWindow.stage, settingsWindow);
				settingsWindow.x = (Capabilities.screenResolutionX - settingsWindow.width) / 2;
				settingsWindow.y = (Capabilities.screenResolutionY - settingsWindow.height) / 2;
				settingsWindow.activate();
			}
			else settingsWindow.activate()
		}
		
		private function openCredits(pEvt:Event):void
		{
			if (creditsWindow == null || creditsWindow.closed)
			{
				var creditsWindowOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
				creditsWindowOptions.type = NativeWindowType.LIGHTWEIGHT;
				creditsWindowOptions.systemChrome = NativeWindowSystemChrome.NONE;
				creditsWindowOptions.transparent = true;
				creditsWindow = new NativeWindow(creditsWindowOptions);
				creditsWindow.width = 300;
				creditsWindow.height = 300;
				new Credits(creditsWindow.stage, creditsWindow);
				creditsWindow.x = (Capabilities.screenResolutionX - creditsWindow.width) / 2;
				creditsWindow.y = (Capabilities.screenResolutionY - creditsWindow.height) / 2;
				creditsWindow.activate();
			}
			else creditsWindow.activate()
		}
		
		public function toggleAlwaysOnTop(pEvt:Object = null):void
		{
			if (alwaysOnTop.checked)
			{
				alwaysOnTop.checked = false
				appWindow.alwaysInFront = false;
			}
			else
			{
				alwaysOnTop.checked = true;
				appWindow.alwaysInFront = true;
			}
		}
		
		private function onOpacityPicked(pEvt:Event):void
		{
			opacitySubMenu.getItemByName(String(Main.SO.data.settings.alpha)).checked = false;
			NativeMenuItem(pEvt.currentTarget).checked = true;
			Main.SO.data.settings.alpha = int(NativeMenuItem(pEvt.currentTarget).name);
			APP.alpha = Main.SO.data.settings.alpha / 100;
		}
		
		private function closeApp(pEvt:Event):void
		{
			rotatorCore.removeEventListener(MouseEvent.MOUSE_OVER, onCoreOver);
			rotatorCore.removeEventListener(MouseEvent.MOUSE_OUT, onCoreOut);
			rotatorCore.removeEventListener(MouseEvent.MOUSE_DOWN, startMoveDrag);
			rotatorCore.removeEventListener(MouseEvent.MOUSE_UP, reopenRotator);
			updateTimer.removeEventListener(TimerEvent.TIMER, checkUpdate);
			
			if (settingsWindow != null && !settingsWindow.closed) settingsWindow.close();
			if (creditsWindow != null && !creditsWindow.closed) creditsWindow.close();
			
			TweenMax.to(rotatorOuterContainer, 0.5, { scaleX: 0, scaleY: 0, onComplete:killApp} );
			TweenMax.to(rotatorInnerContainer, 0.5, { scaleX: 0, scaleY: 0 } );
			TweenMax.to(this, 0.5, { alpha: 0 });
			rotatorAdd.close();
		}
		
		private function killApp():void
		{
			NativeApplication.nativeApplication.icon.bitmaps = [];
			NativeApplication.nativeApplication.exit();
		}
	}
	
}