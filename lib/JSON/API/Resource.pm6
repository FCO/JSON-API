use JSON::API::Document;
role JSON::API::Attr {
	has Str		$.json-api-attr-name is rw	= self.name.subst(/^ <[$%@&]> '!'/, "");
}

role JSON::API::Id does JSON::API::Attr {}

multi trait_mod:<is>(Attribute $attr, :json-api-id($)!)				is export {
	$attr does JSON::API::Id;
}

multi trait_mod:<is>(Attribute $attr, Str :json-api-attr($name)!)	is export {
	trait_mod:<is>($attr, :json-api-attr);
	$attr.json-api-attr-name = $name with $name
}

multi trait_mod:<is>(Attribute $attr, Bool :json-api-attr($)!)		is export {
	$attr does JSON::API::Attr;
}

role JSON::API::Resource {
	method JSON-API(::CLASS:D:) {
		$.json-api-attrs-hash
	}

	multi method load(::?CLASS:U: $id) {
		my \obj = ::?CLASS.new: :$id;
		obj.load;
		obj
	}

	multi method list(::?CLASS:U:)	{…}

	multi method load(::?CLASS:D:)	{…}

	multi method save(::?CLASS:D:)	{…}

	method json-api-data(|req) {
		JSON::API::Document.FromJSONAPI( {:data([self.json-api-request(|req).map(*.JSON-API)])}).to-json
	}

	multi method json-api-request(::?CLASS:U: "GET") {
		|gather for |::?CLASS.list -> $id {
			take ::?CLASS.load($id)
		}
	}

	multi method json-api-request(::?CLASS:U: "GET", $id) {
		::?CLASS.load($id)
	}

	multi method json-api-attrs {
		|self.^attributes(:all).grep(JSON::API::Attr)
	}

	multi method json-api-attrs(Bool :$changed! where ?*) {
		|self.^attributes(:all).grep({$_ ~~ JSON::API::Attr && .has_changed})
	}

	method !id-attr {
		state $id = self.^attributes(:all).first(JSON::API::Id)
	}

	method resource-id {self!id-attr.get_value(self)}

	method json-api-attrs-hash {
		do for $.json-api-attrs -> $attr {
			my \value = $attr.get_value(self);
			$attr.json-api-attr-name => value if value.defined
		}.Hash
	}
}
