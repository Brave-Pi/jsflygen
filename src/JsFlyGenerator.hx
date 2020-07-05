package;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.*;

#if macro
using tink.MacroApi;
#end

import test.Test;
import StringTools;

class JsFlyGenerator {
	#if macro
	@:persistent static var gen:ExampleJSGenerator;
	@:persistent static var val:Int;

	public static function use() @:privateAccess {
		val = 5;
		// var test = macro new Test();
		Compiler.setCustomJSGenerator(api -> {
			gen = new ExampleJSGenerator(api);
			var exprs = [
				macro new test.Test(),
				macro haxe.io.Bytes.ofString(''),
				macro new haxe.io.StringInput('')
			];
			for (cl in exprs) {
				var type = cl.typeof().sure();
				gen.genType(type);
			}
			sys.io.File.saveContent("./bytes.js", gen.buf.toString());
			while (true) {
				Sys.sleep(1.0);
			}
		});
	}
	#end

	public static macro function test() {
		trace(gen);
		trace(val);
		// var cl = macro(new Test());
		// var type = cl.typeof().sure();
		// trace(type);
		// gen.genType(type);
		// trace(gen.buf.toString());
		// while (true) {
		// 	Sys.sleep(1.0);
		// }

		return macro {}
	}

	public static function main() {
		new Test();
		test();
	}
}
