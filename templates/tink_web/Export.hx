package;

using tink.MacroApi;

import haxe.macro.Type;
import haxe.macro.Expr;

class Export {
	#if macro
	public static function doExport(tmpDir:String, typeName:String):TypeDefinition {
		var routerPath = [tmpDir, typeName].join('.');
		var routerTp = {pack: [tmpDir], name: typeName};
		var routerType = haxe.macro.Context.getType(routerPath).toComplex();
		var def:TypeDefinition = macro class $typeName {
			var router:Dynamic;

			public function new() {
				this.router = new tink.web.routing.Router<$routerType>(new $routerTp());
			}

			public function route(ctx:tink.web.routing.Context) {
				return router.route(ctx);
			}
		};
		return def;
	}

	public static function export() {
		return jsfly.Exporter.export(haxe.macro.Context.definedValue('tmp-path'), haxe.macro.Context.definedValue('gen-pack'), doExport);
	}
	#end
}
