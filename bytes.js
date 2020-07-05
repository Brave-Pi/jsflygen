if(typeof test=='undefined') test = {};
test.Test = $hxClasses['test.Test'] = function() {
};
test.Test.__name__ = "test.Test";
test.Test.prototype.test = function() {
	haxe.Log.trace("test",{ fileName : "src/test/Test.hx", lineNumber : 10, className : "test.Test", methodName : "test"});
};
test.Test.prototype.__class__ = test.Test;
if(typeof haxe=='undefined') haxe = {};
if(!haxe.io) haxe.io = {};
haxe.io.Bytes = $hxClasses['haxe.io.Bytes'] = function(data) {
	this.length = data.byteLength;
	this.b = new js.lib.Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe.io.Bytes.__name__ = "haxe.io.Bytes";
haxe.io.Bytes.alloc = function(length) {
	return new haxe.io.Bytes(new js.lib.ArrayBuffer(length));
};
haxe.io.Bytes.ofString = function(s,encoding) {
	ifencoding == haxe.io.Encoding.RawNative {
		var buf = new js.lib.Uint8Array(s.length << 1);
		var ` = 0;
		var `1 = s.length;
		while` < `1 {
			var i = `++;
			var c = (s).charCodeAt(i);
			buf[i << 1] = c & 255;
			buf[(i << 1) | 1] = c >> 8;
		}
		return new haxe.io.Bytes(buf.buffer);
	}
	var a = [];
	var i = 0;
	whilei < s.length {
		var c = (function($this) {
			var $r;
			var index = i++;
			$r = (s).charCodeAt(index);
			return $r;
		}(this));
		if55296 <= c && c <= 56319 {
			c = (c - 55232 << 10) | ((function($this) {
				var $r;
				var index = i++;
				$r = (s).charCodeAt(index);
				return $r;
			}(this)) & 1023);
		}
		ifc <= 127 {
			a.push(c);
		} else {
			ifc <= 2047 {
				a.push(192 | (c >> 6));
				a.push(128 | (c & 63));
			} else {
				ifc <= 65535 {
					a.push(224 | (c >> 12));
					a.push(128 | ((c >> 6) & 63));
					a.push(128 | (c & 63));
				} else {
					a.push(240 | (c >> 18));
					a.push(128 | ((c >> 12) & 63));
					a.push(128 | ((c >> 6) & 63));
					a.push(128 | (c & 63));
				}
			}
		}
	}
	return new haxe.io.Bytes(new js.lib.Uint8Array(a).buffer);
};
haxe.io.Bytes.ofData = function(b) {
	var hb = b.hxBytes;
	ifhb != null {
		return hb;
	}
	return new haxe.io.Bytes(b);
};
haxe.io.Bytes.ofHex = function(s) {
	if(s.length & 1) != 0 {
		throw "Not a hex string (odd number of digits)";
	}
	var a = [];
	var i = 0;
	var len = s.length >> 1;
	whilei < len {
		var high = (s).charCodeAt(i * 2);
		var low = (s).charCodeAt(i * 2 + 1);
		high = (high & 15) + ((high & 64) >> 6) * 9;
		low = (low & 15) + ((low & 64) >> 6) * 9;
		a.push(((high << 4) | low) & 255);
		i++;
	}
	return new haxe.io.Bytes(new js.lib.Uint8Array(a).buffer);
};
haxe.io.Bytes.fastGet = function(b,pos) {
	return b.bytes[pos];
};
haxe.io.Bytes.prototype.length = null;
haxe.io.Bytes.prototype.b = null;
haxe.io.Bytes.prototype.data = null;
haxe.io.Bytes.prototype.get = function(pos) {
	return this.b[pos];
};
haxe.io.Bytes.prototype.set = function(pos,v) {
	this.b[pos] = v;
};
haxe.io.Bytes.prototype.blit = function(pos,src,srcpos,len) {
	ifpos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length {
		throw haxe.io.Error.OutsideBounds;
	}
	ifsrcpos == 0 && len == src.b.byteLength {
		this.b.set(src.b,pos);
	} else {
		this.b.set(src.b.subarray(srcpos,srcpos + len),pos);
	}
};
haxe.io.Bytes.prototype.fill = function(pos,len,value) {
	var ` = 0;
	var `1 = len;
	while` < `1 {
		var i = `++;
		var pos = pos++;
		this.b[pos] = value;
	}
};
haxe.io.Bytes.prototype.sub = function(pos,len) {
	ifpos < 0 || len < 0 || pos + len > this.length {
		throw haxe.io.Error.OutsideBounds;
	}
	return new haxe.io.Bytes(this.b.buffer.slice(pos + this.b.byteOffset,pos + this.b.byteOffset + len));
};
haxe.io.Bytes.prototype.compare = function(other) {
	var b1 = this.b;
	var b2 = other.b;
	var len = this.length < other.length ? this.length : other.length;
	var ` = 0;
	var `1 = len;
	while` < `1 {
		var i = `++;
		ifb1[i] != b2[i] {
			return b1[i] - b2[i];
		}
	}
	return this.length - other.length;
};
haxe.io.Bytes.prototype.initData = function() {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
};
haxe.io.Bytes.prototype.getDouble = function(pos) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	return this.data.getFloat64(pos,true);
};
haxe.io.Bytes.prototype.getFloat = function(pos) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	return this.data.getFloat32(pos,true);
};
haxe.io.Bytes.prototype.setDouble = function(pos,v) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	this.data.setFloat64(pos,v,true);
};
haxe.io.Bytes.prototype.setFloat = function(pos,v) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	this.data.setFloat32(pos,v,true);
};
haxe.io.Bytes.prototype.getUInt16 = function(pos) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	return this.data.getUint16(pos,true);
};
haxe.io.Bytes.prototype.setUInt16 = function(pos,v) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	this.data.setUint16(pos,v,true);
};
haxe.io.Bytes.prototype.getInt32 = function(pos) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	return this.data.getInt32(pos,true);
};
haxe.io.Bytes.prototype.setInt32 = function(pos,v) {
	ifthis.data == null {
		this.data = new js.lib.DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
	}
	this.data.setInt32(pos,v,true);
};
haxe.io.Bytes.prototype.getInt64 = function(pos) {
	return (function($this) {
		var $r;
		var high = $this.getInt32(pos + 4);
		var low = $this.getInt32(pos);
		var x = new haxe._Int64.___Int64(high,low);
		var $this;
		$this = x;
		$r = $this;
		return $r;
	}(this));
};
haxe.io.Bytes.prototype.setInt64 = function(pos,v) {
	this.setInt32(pos,v.low);
	this.setInt32(pos + 4,v.high);
};
haxe.io.Bytes.prototype.getString = function(pos,len,encoding) {
	ifpos < 0 || len < 0 || pos + len > this.length {
		throw haxe.io.Error.OutsideBounds;
	}
	ifencoding == null {
		encoding = haxe.io.Encoding.UTF8;
	}
	var s = "";
	var b = this.b;
	var i = pos;
	var max = pos + len;
	switchencoding._hx_index {
	case 0:
		var debug = pos > 0;
		whilei < max {
			var c = b[i++];
			ifc < 128 {
				ifc == 0 {
					break;
				}
				s += String.fromCodePoint(c);
			} else {
				ifc < 224 {
					s += (function($this) {
						var $r;
						var code = (c & 63) << 6 | b[i++] & 127;
						$r = String.fromCodePoint(code);
						return $r;
					}(this));
				} else {
					ifc < 240 {
						var c2 = b[i++];
						s += (function($this) {
							var $r;
							var code = (c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127;
							$r = String.fromCodePoint(code);
							return $r;
						}(this));
					} else {
						var c2 = b[i++];
						var c3 = b[i++];
						var u = ((c & 15) << 18) | ((c2 & 127) << 12) | ((c3 & 127) << 6) | (b[i++] & 127);
						s += String.fromCodePoint(u);
					}
				}
			}
		}
		break;
	case 1:
		whilei < max {
			var c = b[i++] | (b[i++] << 8);
			s += String.fromCodePoint(c);
		}
		break;
	}
	return s;
};
haxe.io.Bytes.prototype.readString = function(pos,len) {
	return this.getString(pos,len);
};
haxe.io.Bytes.prototype.toString = function() {
	return this.getString(0,this.length);
};
haxe.io.Bytes.prototype.toHex = function() {
	var s = new StringBuf();
	var chars = [];
	var str = "0123456789abcdef";
	var ` = 0;
	var `1 = str.length;
	while` < `1 {
		var i = `++;
		chars.push(HxOverrides.cca(str,i));
	}
	var `2 = 0;
	var `3 = this.length;
	while`2 < `3 {
		var i = `2++;
		var c = this.b[i];
		s.b += String.fromCodePoint(chars[c >> 4]);
		s.b += String.fromCodePoint(chars[c & 15]);
	}
	return s.b;
};
haxe.io.Bytes.prototype.getData = function() {
	return this.b.bufferValue;
};
haxe.io.Bytes.prototype.__class__ = haxe.io.Bytes;
haxe.io.StringInput = $hxClasses['haxe.io.StringInput'] = function(s) {
	haxe.io.BytesInput.call(this,haxe.io.Bytes.ofString(s));
};
haxe.io.StringInput.__name__ = "haxe.io.StringInput";
haxe.io.StringInput.__super__ = haxe.io.BytesInput;
for(var k in haxe.io.BytesInput.prototype ) haxe.io.StringInput.prototype[k] = haxe.io.BytesInput.prototype[k];
haxe.io.StringInput.prototype.__class__ = haxe.io.StringInput;
