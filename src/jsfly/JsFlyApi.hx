package jsfly;

import tink.io.Source;

class JsFlyApi implements IJsFlyApi {
	var compiler:CompilerServer;

	public function new() {
        compiler = new CompilerServer();
	}

	@:get('/$name')
	public function get(name:String):tink.web.Response<RealSource> {
		return null;
	}

	@:post('/$name')
	@:params(hxmlTemplate = query['template'])
	@:params(sourceCode = body)
	public function post(name:String, template:String, sourceCode:IdealSource):tink.web.Response<RealSource> {
		return null;
	}

	@:patch('/$name')
	@:params(sourceCode = body)
	public function patch(name:String, sourceCode:IdealSource):tink.web.Response<RealSource> {
		return null;
	}
}
