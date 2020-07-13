package;

import tink.http.Header.HeaderField;
import tink.io.Source.IdealSource;
import tink.http.Method;
import jsfly.*;
import tink.unit.*;
// import tink.unit.Assert;
import tink.testrunner.*;
import Utils.attempt;
import tink.streams.Stream;
import tink.CoreApi;
import tink.http.Response;
import tink.http.Request;

using Lambda;
// import asys.io.Process;
using Utils;

class RunTests {
	static function main() {
		Runner.run(TestBatch.make([new Test(),])).handle(Runner.exit);
	}
}

extern class Router {
	function route(ctx:tink.web.routing.Context):Promise<tink.http.Response.OutgoingResponse>;
}

@:asserts
class Test {
	public function new() {}

	var server:CompilerServer;
	var client:StagingClient;

	public function test_create_server()
		return asserts.assert((server = new CompilerServer()).attempt());

	public function test_create_client()
		return asserts.assert((client = new StagingClient("test.Router", "test/tink_web", "
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
				result.moveTo("./output.js");
			}).next(_ -> {
				var setup = get_test_setup('./output.js', "test.Router");
				setup.client.request(mk_req(GET, "/", [], ""));
			}).next(r -> {
				var responseBody = "";
				r.body.chunked().forEach(c -> {
					responseBody += c.toString();
					Resume;
				}).next(_ -> {
					asserts.assert(responseBody == "hello");
				});
			}).next(_ -> {
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
		var client = new StagingClient("many.method.Router", "test/tink_web", body);
		client.connect(server).next(r -> {
			r.moveTo('./benchmark-${_methods}routes.js');
		}).next(_ -> {
			var setup = get_test_setup('./benchmark-${_methods}routes.js', "many.method.Router");
			Promise.inSequence(methods.map(i -> setup.client.request(mk_req(GET, '/test$i', [], ""))));
		}).next(responses -> {
			var i = 0;
			Promise.inSequence(responses.map(response -> {
				var responseBody = "";
				response.body.chunked().forEach(c -> {
					responseBody += c.toString();
					Resume;
				}).next(_ -> {
					asserts.assert(responseBody == 'test ${i++}');
				});
			}));
		}).next(s -> {
			trace('Done! Took ${haxe.Timer.stamp() - start}s');
			asserts.done();
		}).eager();
		return asserts;
	}

	function get_test_setup(path:String, routerPath:String) {
		var module = js.Lib.require(path);

		var container = new tink.http.containers.LocalContainer();
		var client = new tink.http.clients.LocalContainerClient(container);
		var ctr:Class<Router> = {
			routerPath.split('.').fold((prop, obj) -> {
				return js.Syntax.field(obj, prop);
			}, module);
		};
		var router:Router = js.Syntax.construct(ctr, []);
		container.run(req -> router.route(tink.web.routing.Context.ofRequest(req)).recover(tink.http.Response.OutgoingResponse.reportError));
		return {
			client: client,
			container: container
		};
	}

	function mk_req(?method = GET, ?path:String, ?headers:Array<HeaderField>, ?body:IdealSource) {
		if (body == null)
			body = "";
		return new OutgoingRequest(new OutgoingRequestHeader(method, path, HTTP2, headers), body);
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
