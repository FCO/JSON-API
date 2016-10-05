use JSON::Class;

role JSON::API::Class is JSON::Class {
	method to-json {
		nextwith(:skip-null) with self
	}
}

class JSON::API::Document does JSON::API::Class {
	role Pagination {
	}

	class Relationship does JSON::API::Class {}

	class Attributes does JSON::API::Class { }

	class Resource does JSON::API::Class {
		has $.id;
		has $.type;

		has Attributes		$.attributes;
		has Relationship	$.relationships;
		has $.links;
		has $.meta;

		method validate {
			so $!type.defined
		}
	}

	class Links does JSON::API::Class does Pagination {
		has $.self;
		has $.related;
	}

	has Resource $.data;
	has $.errors;
	has $.meta;

	has $.jsonapi;
	has $.links;
	has $.included;

	method validate {
		die "{self.gist}: data and error defined"				if all($!data.defined, $!errors.defined);
		die "{self.gist}: none defined: (data, errors, meta)"	if none($!data.defined, $!errors.defined, $!meta.defined);
		die "{self.gist}: included defined but not data"		if $!included.defined and not $!data.defined;

		True
	}
}
