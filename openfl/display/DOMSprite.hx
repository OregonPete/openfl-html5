package openfl.display;


import flash.display.Sprite;
import flash.display.Stage;
import js.html.Element;


class DOMSprite extends Sprite {
	
	
	private var __active:Bool;
	private var __element:Element;
	
	
	public function new (element:Element) {
		
		super ();
		
		__element = element;
		
	}
	
	
	public override function __renderDOM (renderSession:RenderSession):Void {
		
		if (stage != null && __worldVisible && __renderable) {
			
			if (!__active) {
				
				__initializeElement (__element, renderSession);
				__active = true;
				
			}
			
			__applyStyle (renderSession, true, true, true);
			
		} else {
			
			if (__active) {
				
				renderSession.element.removeChild (__element);
				__active = false;
				
			}
			
		}
		
		super.__renderDOM (renderSession);
		
	}
	
}