package jsfly;

import tink.io.Source;


interface IJsFlyApi {
    @:get('/$name')
    function get(name:String):tink.web.Response<RealSource>;

    @:post('/$name')
    @:params(hxmlTemplate = query['hxml'])
    @:params(sourceCode = body)
    function post(name:String, hxmlTemplate:String, sourceCode:IdealSource):tink.web.Response<RealSource>;

    @:patch('/$name')
    @:params(sourceCode = body)
    function patch(name:String, sourceCode:IdealSource):tink.web.Response<RealSource>;
}