use JSON::API::Resource;
unit class Account does JSON::API::Resource;
subset Email of Str where /^ <+[\w+.-]>+ '@' <+[\w+-]>+ % '.' [\w ** 2..3]+ % '.' $/;

has UInt	$.id		is json-api-id;
has Str 	$.name		is json-api-attr<fullname>	is rw;
has	Str		$.nickname	is json-api-attr			is rw = ($!name // "").words.first: * >= 3;
has Email	$.email		is json-api-attr			is rw;

multi method load(::?CLASS:D:) {
	say "load";
}

multi method save(::?CLASS:D:) {
	say "save";
}
