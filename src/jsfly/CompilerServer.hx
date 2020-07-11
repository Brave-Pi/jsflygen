package jsfly;

import tink.CoreApi.Future;
import tink.core.Disposable;
import asys.io.Process;
import tink.streams.Stream;
import tink.io.Source;
import tink.io.Sink;
import tink.CoreApi;

class CompilerServer extends SimpleDisposable {
	var process:Process;
	var alive = true;

	public var port:Int;

	static var portMin = 3000;
	static var currentPort = 3000;
	static var portMax = 9000;

	public function new() {
		super(kill);
		this.port = Std.int(Math.min((currentPort++) % portMax, portMin));
		this.getProcess();
	}

	function getProcess() {
		if (alive)
			this.process = {
				var ret = new asys.io.Process('npx.cmd', ['haxe', '-v', '--wait', '${++port}']);
				ret.exitCode().next(code -> {
					getProcess();
					Noise;
				}).eager();
				ret;
			}
	}

	public function kill() {
		if (alive) {
			this.alive = false;
			if (Sys.systemName() == 'Windows') {
				var pid = this.process.getPid();

				return new asys.io.Process('taskkill', ['/pid', '$pid', '/f', '/t']).exitCode().next(code -> code == 0);
			} else {
				this.process.kill();
				return true;
			}
		} else
			return true;
	}
}
