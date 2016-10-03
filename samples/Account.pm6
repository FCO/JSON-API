use JSON::API::Resource;
unit class Account does JSON::API::Resource;
subset Email of Str where /^ <+[\w+.-]>+ '@' <+[\w+-]>+ % '.' [\w ** 2..3]+ % '.' $/;

has UInt	$.id		is json-api-id;
has Str 	$.name		is json-api-attr;
has	Str		$.nickname	is json-api-attr = ($!name // "").words.first: * >= 3;
has Email	$.email		is json-api-attr;

multi method load(::?CLASS:D:) {
	say "load";
}

multi method save(::?CLASS:D:) {
	say "save";
}
