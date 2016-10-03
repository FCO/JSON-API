role JSON::API::Attr {
	has Str $.json-api-attr-name is rw = self.name.subst(/^ <[$%@&]> '!'/, "");
}

role JSON::API::Id does JSON::API::Attr {}

multi trait_mod:<is>(Attribute $attr, :json-api-id($)!)	is export {
	$attr does JSON::API::Id;
}

multi trait_mod:<is>(Attribute $attr, :json-api-attr($)!)			is export {
	$attr does JSON::API::Attr;
}

role JSON::API::Resource {
	multi method load(::?CLASS:U: $id) {
		my \obj = ::?CLASS.new: :$id;
		obj.load;
		obj
	}

	multi method load(::?CLASS:D:)		{…}

	multi method save(::?CLASS:D:)		{…}

	method !json-api-attrs {
		|self.^attributes(:all).grep(JSON::API::Attr)
	}

	method !id-attr {
		state $id = self.^attributes(:all).first(JSON::API::Id)
	}

	method resource-id {self!id-attr.get_value(self)}

	method json-api-attrs-hash {
		do for self!json-api-attrs -> $attr {
			my \value = $attr.get_value(self);
			$attr.json-api-attr-name => value if value.defined
		}.Hash
	}
}
