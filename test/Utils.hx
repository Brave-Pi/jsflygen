package;

class Utils {
	public static macro function attempt(expr:haxe.macro.Expr) {
		return macro try {
			$expr;
			true;
		} catch (e) {
			trace(e);
			false;
		};
	}
}
