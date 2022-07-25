{

 inputs = {
   darwin.url = "github:LnL7/nix-darwin";
 };

 outputs = { self, darwin }: {
   lib = pkgs: {
     # TODO: validate opts
     spec = opts: pkgs.writeText "cachix-deploy.json" (builtins.toJSON opts);
     nixos = module: (pkgs.nixos module).toplevel;
     darwin = module: (darwin.lib.darwinSystem {
       system = pkgs.system;
       modules = [
         (darwin + "/pkgs/darwin-installer/installer.nix") 
         module
       ];
     }).system;
   };
 };

}
