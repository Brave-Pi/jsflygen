package jsfly;

using tink.MacroApi;

import haxe.macro.Type;
import haxe.macro.Expr;

// import haxe.macro.Field;
class Exporter {
	#if macro
	public static function export(tmpDir:String, className:String, createTypeDef:String->String->TypeDefinition /* , superClass = "BaseCl" */) {
		var path = className.split('.');
		var typeName = path.pop();
		haxe.macro.Compiler.include(tmpDir);
		var def = createTypeDef(tmpDir, typeName);
		def.name = typeName;
		def.pack = path;
		var p:haxe.macro.Position = null;
		def.meta = {
			(def.meta == null ? def.meta = [] : def.meta).push({name: ':expose', pos: p.sanitize(), params: null});
			def.meta;
		};
		haxe.macro.Context.defineModule(className, [def], null, null);
		haxe.macro.Compiler.include(className);
		trace('output dir: ${tmpDir + '/' + className.toLowerCase() + '.js'}');
		haxe.macro.Compiler.setOutput(tmpDir + '/' + className.toLowerCase() + '.js');
	}
	#end
}
