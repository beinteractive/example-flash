package
{
	import flash.utils.Dictionary;
	import com.perfume.utils.bvh.Bvh;	import com.perfume.utils.bvh.BvhBone;
	import com.perfume.utils.bvh.prfmbvh;

	use namespace prfmbvh;
	public class BlendedBvh extends Bvh
	{
		protected static const M_2PI:Number = Math.PI * 2;

		public function BlendedBvh(originals:Array)
		{
			try {
				super("");
			}
			catch (e:Error) {
				// This error is expected.
			}
			
			_originals = originals;

			setupBones();
			setupFrameTime();
		}

		private var _originals:Array;

		protected function setupBones():void
		{
			var originalBones:Array = allOriginalBones;
			createNewBones(originalBones);
			copyFamilyRelations(originalBones);
		}

		protected function get allOriginalBones():Array
		{
			var bones:Array = [];
			var addedNames:Dictionary = new Dictionary();

			for each (var original:Bvh in _originals) {
				for each (var bone:BvhBone in original.bones) {
					if (addedNames[bone.name]) {
						continue;
					}
					bones.push(bone);
					addedNames[bone.name] = true;
				}
			}

			return bones;
		}

		protected function createNewBones(originalBones:Array):void
		{
			bones.length = 0;
			for each (var originalBone:BvhBone in originalBones) {
				bones.push(newBone(originalBone));
			}
		}

		protected function copyFamilyRelations(originalBones:Array):void
		{
			for each (var originalBone:BvhBone in originalBones) {
				var selfBone:BvhBone = lookupBone(this, originalBone.name);
				selfBone.parent = originalBone.parent != null ? lookupBone(this, originalBone.parent.name) : null;
				for each (var originalChild:BvhBone in originalBone.children) {
					selfBone.children.push(lookupBone(this, originalChild.name));
				}
			}
		}

		protected function newBone(template:BvhBone):BvhBone
		{
			var bone:BvhBone = new BvhBone();

			bone.name = template.name;
			bone.isEnd = template.isEnd;

			return bone;
		}

		protected function setupFrameTime():void
		{
			frameTimeInternal = 0;

			for each (var original:Bvh in _originals) {
				frameTimeInternal = Math.max(frameTime, original.frameTime);
			}
		}

		override public function gotoFrame(f:uint):void
		{
			updateOriginals(f);
			blendBones();
		}

		protected function updateOriginals(f:uint):void
		{
			for each (var original:Bvh in _originals) {
				original.gotoFrame(f);
			}
		}

		protected function blendBones():void
		{
			for each (var bone:BvhBone in bones) {
				blendBone(bone);
			}
		}

		protected function lookupBone(bvh:Bvh, boneName:String):BvhBone
		{
			for each (var bone:BvhBone in bvh.bones) {
				if (bone.name == boneName) {
					return bone;
				}
			}
			return null;
		}

		protected function blendBone(selfBone:BvhBone):void
		{
			selfBone.offsetX = 0;
			selfBone.offsetY = 0;
			selfBone.offsetZ = 0;

			selfBone.endOffsetX = 0;
			selfBone.endOffsetY = 0;
			selfBone.endOffsetZ = 0;

			selfBone.Xposition = 0;
			selfBone.Yposition = 0;
			selfBone.Zposition = 0;

			selfBone.Xrotation = 0;
			selfBone.Yrotation = 0;
			selfBone.Zrotation = 0;

			var c:Number = 0;

			for each (var original:Bvh in _originals) {

				var bone:BvhBone = lookupBone(original, selfBone.name);
				if (bone == null) {
					continue;
				}

				c += 1.0;

				selfBone.offsetX += bone.offsetX;
				selfBone.offsetY += bone.offsetY;
				selfBone.offsetZ += bone.offsetZ;
	
				selfBone.endOffsetX += bone.endOffsetX;
				selfBone.endOffsetY += bone.endOffsetY;
				selfBone.endOffsetZ += bone.endOffsetZ;
	
				selfBone.Xposition += bone.Xposition;
				selfBone.Yposition += bone.Yposition;
				selfBone.Zposition += bone.Zposition;
	
				selfBone.Xrotation += bone.Xrotation;
				selfBone.Yrotation += bone.Yrotation;
				selfBone.Zrotation += bone.Zrotation;
			}

			selfBone.offsetX /= c;
			selfBone.offsetY /= c;
			selfBone.offsetZ /= c;

			selfBone.endOffsetX /= c;
			selfBone.endOffsetY /= c;
			selfBone.endOffsetZ /= c;

			selfBone.Xposition /= c;
			selfBone.Yposition /= c;
			selfBone.Zposition /= c;

			selfBone.Xrotation /= c;
			selfBone.Yrotation /= c;
			selfBone.Zrotation /= c;
		}
	}}