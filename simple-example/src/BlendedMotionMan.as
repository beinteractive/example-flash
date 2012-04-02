package
{
	import flash.display.Sprite;
	public class BlendedMotionMan extends MotionMan
	{
		public function BlendedMotionMan(target:Sprite, originals:Array)
		{
			super(target, null);
			
			_originals = originals;
		}

		private var _originals:Array;

		override protected function load(_path:String, _fn:Function = null):void
		{
			// Nothing to do
		}		override public function update(t:Number):void
		{
			if (bvh == null) {
				createBlendedBvhIfCan();
			}
			
			super.update(t);
		}

		protected function createBlendedBvhIfCan():void
		{
			var originalBvhs:Array = [];
			for each (var original:MotionMan in _originals) {
				if (original.bvh != null) {
					originalBvhs.push(original.bvh);
				}
				else {
					return;
				}
			}
			bvh = new BlendedBvh(originalBvhs);
			createCircles(bvh.bones.length + 5);
		}	}}