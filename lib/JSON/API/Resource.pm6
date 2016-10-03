role JSON::API::Attr {
	has Str		$.json-api-attr-name is rw	= self.name.subst(/^ <[$%@&]> '!'/, "");

	method set_value(|) {
		my \ret = nextsame;
		note "set_value";
		ret
	}
}

role JSON::API::Id does JSON::API::Attr {}

multi trait_mod:<is>(Attribute $attr, :json-api-id($)!)				is export {
	note $attr;
	$attr does JSON::API::Id;
}

multi trait_mod:<is>(Attribute $attr, Str :json-api-attr($name)!)	is export {
	trait_mod:<is>($attr, :json-api-attr);
	$attr.json-api-attr-name = $name if $name.defined
}

multi trait_mod:<is>(Attribute $attr, Bool :json-api-attr($)!)		is export {
	note $attr;
	$attr does JSON::API::Attr
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
		|self.^attributes(:all).grep(JSON::API::Attr)
	}

	multi method json-api-attrs(:$changed! where -> $v {?$v}) {
		|self.^attributes(:all).grep(-> $par {$par ~~ JSON::API::Attr && $par.has_changed})
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
