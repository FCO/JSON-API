role JSON::API::Attr {
	method json-api-attr {True}
}

role JSON::API::Id {
	method json-api-id {True}
}

multi trait_mod:<is>(Attribute $attr, :json-api-id($)!)		is export {
	$attr does JSON::API::Id;
}

multi trait_mod:<is>(Attribute $attr, :json-api-attr($)!)	is export {
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

	multi method json-api-attrs {
		|self.^attributes(:all).grep(JSON::API::Attr | JSON::API::Id)
	}

	method !id-attr {
		state $id = self.^attributes(:all).first(JSON::API::Id)
	}

	method resource-id {self!id-attr.get_value(self)}
}
