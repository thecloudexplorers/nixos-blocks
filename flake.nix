{
	description = "nixos-blocks";

	outputs = _: {
		nixosModules = let
			# Needed to allow the module system to import these modules
			import = path: path;
		in {
            kanidm = import ./blocks/kanidm;
		};
	};
}
