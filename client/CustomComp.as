package {
	import mx.controls.Label;
	
	public class CustomComp extends Label {
		override public function set data(value:Object):void {
			if(value != null) {
				super.data = value;
				
				if(value.team == "A") {
					setStyle("color", 0xFF0000);
				} else if(value.team == "B") {
					setStyle("color", 0x0000FF);
				} else {
					setStyle("color", 0x000000);
				}
			}
		}
	}
}
