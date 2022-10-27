{

 inputs = {
   darwin.url = "github:LnL7/nix-darwin";
   home-manager.url = "github:nix-community/home-manager";
 };

 outputs = { self, darwin, home-manager }: {
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

     homeManager = { extraSpecialArgs ? { } }: module: let
       result = home-manager.lib.homeManagerConfiguration {
         inherit pkgs extraSpecialArgs;
         modules = [ module ];
       };
     in result.config.home.activationPackage;
   };
 };

}
