package;

import jsfly.*;
import tink.unit.*;
// import tink.unit.Assert;
import tink.testrunner.*;
import Utils.attempt;
import tink.CoreApi;

// import asys.io.Process;
using Utils;

class RunTests {
	static function main() {
		Runner.run(TestBatch.make([new Test(),])).handle(Runner.exit);
	}
}

@:asserts
class Test {
	public function new() {}

	var server:CompilerServer;
	var client:StagingClient;

	public function test_create_server()
		return asserts.assert((server = new CompilerServer()).attempt());

	public function test_create_client()
		return asserts.assert((client = new StagingClient("test.Router", "tink_web", "
class Router {
	public function new() {}
	@:get('/')
	public function test() return 'hello';
}
    ")).attempt());

	var generatedJs:String;

	@:timeout(10000)
	public function test_connect() {
		function run():Promise<String>
			return client.connect(server).next(result -> {
				trace('done: $result');
				result.moveTo("./output.js");
			}).next(s -> {
				trace('result: $s');
				try {
					var content = js.node.Fs.readFileSync('./output.js').toString();
					// trace(content);
					content;
				} catch (e) {
					Error.withData("Error", e);
				}
			});
		asserts.assert((run().next(js -> generatedJs = js).next(_ -> {
			asserts.done();
		}).eager()).attempt());
		return asserts;
	}

	@:variant(3)
	@:variant(10)
	@:variant(100)
	@:variant(1000)
	@:timeout(10000)
	public function benchmark(_methods:Int) {
		var methods = [for (i in 0..._methods) i];
		var start = haxe.Timer.stamp();
		var body = 'class Router {
			public function new() {}
			${methods.map(i -> ' @:get(${'"/test$i"'}) public function test$i() return "test $i"; ').join('\n\n')}
		}';
		var client = new StagingClient("many.method.Router", "tink_web", body);
		client.connect(server).next(r -> {
			r.moveTo('./benchmark-${_methods}routes.js');
		}).next(s -> {
			trace('Done! Took ${haxe.Timer.stamp() - start}s');
			asserts.done();
		}).eager();
		return asserts;
	}

	@:teardown
	public function shutdown_server() {
		return server.kill().next(code -> {
			server.dispose();
			trace('shutting down server');
			Noise;
		});
	}
}
