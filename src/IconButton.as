package
{
	import flash.display.Bitmap;
	
	import spark.components.Button;
	import spark.components.Image;
	
	public class IconButton extends Button
	{
		[Bindable]
		public var icon:Bitmap;
		public function IconButton()
		{
			super();
		}
	}
}