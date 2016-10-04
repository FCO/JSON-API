use JSON::Fast;
role ToJSONAPI {
	method to-json {
		to-json $.ToJSONAPI.Hash
	}

	method from-json(Str \json) {
		::?CLASS.FromJSONAPI: from-json(json)
	}

	method !list-of-attr {
		|self.^attributes
	}

	method ToJSONAPI {
		die if self.^can("validate") and not self.validate;
		my %hash;
		|do for self!list-of-attr -> $attr {
			my $name = $attr.name.subst(/^ <[$%@&]> '!'/, "");
			my $value = $attr.get_value(self);
			$value .= ToJSONAPI if $value.^can("ToJSONAPI");
			with $value -> $val {
				if $val ~~ Positional {
					my %tmp;
					for @$val -> (:$key, :$value) {
						%tmp{$key} = $value
					}
					$name => %tmp
				} else {
					$name => $val
				}
			}
		}
	}

	multi method FromJSONAPI(::?CLASS:U: %data) {
		my $obj = ::?CLASS.new;
		$obj.FromJSONAPI(%data);
		$obj
	}

	multi method FromJSONAPI(::?CLASS:_: @data) {
		@data
	}

	multi method FromJSONAPI(::?CLASS:D: %data) {
		for self!list-of-attr -> $attr {
			my \key = $attr.name.subst(/^ <[$%@&]> '!'/, '');
			if %data{key}:exists {
				if $attr.get_value(self).^can("FromJSONAPI") {
					$attr.set_value: self, $attr.get_value(self).FromJSONAPI(%data{key})
				} else {
					$attr.set_value: self, %data{key}
				}
			}
		}
		if self.^can("validate") {
			die unless self.validate
		}
	}
}

class JSON::API::Document does ToJSONAPI {
	role Pagination {
	}

	class Resource does ToJSONAPI {
		has $.id;
		has $.type;

		has $.attributes;
		has $.relationships;
		has $.links;
		has $.meta;

		method validate {
			so $!type.defined
		}
	}

	class Links does ToJSONAPI does Pagination {
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
