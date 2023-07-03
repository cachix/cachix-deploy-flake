{

 inputs = {
   darwin.url = "github:LnL7/nix-darwin";
   home-manager.url = "github:nix-community/home-manager";
   home-manager.inputs.nixpkgs.follows = "nixpkgs";
   nixos-anywhere.url = "github:numtide/nixos-anywhere";
   nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
   nixos-anywhere.inputs.disko.follows = "disko";
   disko.url = "github:nix-community/disko";
   disko.inputs.nixpkgs.follows = "nixpkgs";
 };

 outputs = { self, nixpkgs, darwin, home-manager, nixos-anywhere, disko, ... }: {

   packages = let 
       forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
     in forAllSystems (system: let 
         pkgs = nixpkgs.legacyPackages.${system};
       in {
        bootstrapHetzner = pkgs.writeScriptBin "bootstrap-hetzner" ''
          #!${pkgs.runtimeShell}

          set -e

          # error out if not two arguments are given
          if [ "$#" -ne 3 ]; then
            echo "Usage: $0 <IP> <agent-hostname> <cachix-agent-token-path>"
            echo "Example: $0 1.1.1.1 myagent ./mytoken.secret"
            exit 1
          fi

          echo "Bootstrapping $2 on $1 ..."
          echo "Make sure your ssh key is added to the ssh-agent to prevent multiple password prompts."

          IP="$1"
          agent="$2"
          agenttokenpath="$3"

          ${nixos-anywhere.packages.${system}.default}/bin/nixos-anywhere "root@$IP" --flake ".#$agent"

          echo 
          echo "Waiting for machine to reboot..."
          sleep 20
          until scp -o ConnectTimeout=60 $agenttokenpath root@$IP:/etc/cachix-agent.token; do sleep 5; done
          ssh root@$IP systemctl restart cachix-agent

          echo "Done."
        '';
     });
    lib = pkgs: {
     # TODO: validate opts
     spec = opts: pkgs.writeText "cachix-deploy.json" (builtins.toJSON opts);
     nixos = module: (pkgs.nixos module).toplevel;
     darwin = module: (darwin.lib.darwinSystem {
       system = pkgs.system;
       inherit pkgs;
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

     bootstrapNixOS = { system, hostname, grubDevices ? [], diskoDevices ? import ./disko-raid1-uefi.nix { disks = grubDevices; inherit (pkgs) lib; }, sshPubKey, imports ? [] }: 
      let 
        module = { pkgs, ... }: {
            imports = [
              disko.nixosModules.disko
              diskoDevices
            ] ++ imports;

            config = {
              services.cachix-agent.enable = true;
              networking.hostName = hostname;
              boot.loader.grub.devices = grubDevices;
              # enable nvme https://github.com/nix-community/disko/issues/96
              boot.initrd.availableKernelModules = [ "nvme" "md_mod" "raid1" ];
              
              # add root ssh key
              users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];
              # enable ssh
              services.openssh.enable = true;
              # enable passwordless ssh for root 
              services.openssh.permitRootLogin = "without-password";
            };
          };
      in {
        module = module;
        nixos = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [ module ];
        };
  };
};
 };
}

