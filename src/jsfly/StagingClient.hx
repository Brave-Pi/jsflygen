package jsfly;

import tink.tcp.nodejs.NodejsConnector;
import tink.core.Disposable.SimpleDisposable;
import asys.io.File;
import asys.FileSystem;
import haxe.io.BytesOutput;
import tink.io.Sink;
import tink.streams.Stream.IdealizeStream;
import tink.io.Source;

using StringTools;
using tink.CoreApi;

class StagingClient extends SimpleDisposable {
	var name:String;
	var template:String;
	var templateDir(get, never):String;
	var args:Promise<Array<String>>;
	var dir:String;

	function get_templateDir()
		return 'templates/$template';

	var path(get, never):Array<String>;

	function get_path()
		return name.split('.');

	var module(get, never):String;

	function get_module() {
		var modName = path.pop();
		var firstLetter = modName.substring(0, 1);
		return firstLetter.toUpperCase() + modName.substring(1);
	}

	public function new(name, template, sourceCode:IdealSource) {
		super(cleanup);
		this.name = name;
		this.template = template;
		var output = new haxe.io.BytesOutput();
		var sink = Sink.ofOutput('$template/$name stream', output);
		this.args = sourceCode.pipeTo(sink).next(this.boot.bind(output));
	}

	function boot(output:BytesOutput, _)
		return getTmpDir().next(tmpDir -> {
			var sourceCode = output.getBytes().toString();
			var tmpPack = tmpDir.split('/').pop();
			File.saveContent('$tmpDir/$module.hx', ['package $tmpPack;', sourceCode].join('\n'));
			([
				'--cwd ${haxe.io.Path.join([Sys.getCwd(), templateDir])}',
				'-D tmp-path=$tmpPack',
				'-D gen-pack=$name',
				'build.hxml'
			] : Array<String>);
		});

	function cleanup()
		return FileSystem.exists(dir).next(dirExists -> {
			if (dir != null && dirExists) {
				FileSystem.readDirectory(dir).next(dirs -> {
					Promise.inParallel(dirs.map(file -> FileSystem.deleteFile('$dir/$file')));
				}).next(_ -> {
					FileSystem.deleteDirectory(dir).eager();
				});
			} else
				Noise;
		}).eager();

	/**
	 * Connect to the given compilation server and compile, return an API for moving or discaring the results
	 * @param server
	 * @return Promise<{moveTo:(outputDir:String)->Void}, discard:()->Void}>
	 */
	public function connect(server:CompilerServer)
		return this.args.next(args -> {
			var port = server.port;
			new Future(cb -> {
				NodejsConnector.connect({host: "127.0.0.1", port: port}, incoming -> {
					incoming.closed.handle(cb.invoke);
					return ({
						stream: args.map(v -> v + '\n').concat(["\x00"]).map(tink.Chunk.ofString).iterator(),
						allowHalfOpen: true
					} : tink.tcp.Outgoing);
				});
				function() {}
			});
		}).next(_ -> {
			new Future(cb -> {
				var watcher = null;
				watcher = js.node.Fs.watch(dir, {recursive: false, persistent: false}, (blah, f) -> {
					var filename:String = f;
					if (filename.toLowerCase().indexOf(name.toLowerCase()) != -1) {
						FileSystem.exists('$dir/$name.js').handle(_ -> {
							watcher.close();
							cb.invoke(Noise);
						});
					}
				});
				function() watcher.close();
			});
		}).next(_ -> {
			moveTo: function moveTo(outputDir) {
				return FileSystem.rename('$dir/${name.toLowerCase()}.js', outputDir)
					.next(r -> {
						cleanup().next(_ -> {
							'cleaned up';
						}).recover(err -> '$err');
					})
					.tryRecover(err -> {
						moveTo(outputDir);
					})
					.eager();
			},
			discard: cleanup,
		});

	function getTmpDir():Promise<String> {
		return new Future(cb -> {
			var current = 0;
			var exists = dirName -> FileSystem.exists(dirName);
			function check()
				exists(dir = './$templateDir/tmp${current++}').next(exists -> {
					if (disposed) {
						cb.invoke(Failure(new Error('terminated')));
						Noise;
					} else if (!exists) {
						FileSystem.createDirectory(dir).next(_ -> {
							cb.invoke(Success(dir));
							Noise;
						});
					} else {
						check();
						Noise;
					}
				}).eager();
			check();
			dispose;
		});
	}
}
