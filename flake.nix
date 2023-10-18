{
  description = "docker xo/c++ builder (using nix)";

  # dependencies
  inputs = rec {
    #nixpkgs.url = "github:nixos/nixpkgs/23.05"; # asof release date ~ may 2023
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/fac3684647cc9d6dfb2a39f3f4b7cf5fc89c96b6.tar.gz"; # asof 17oct2023
  };

  outputs = { self, nixpkgs } :
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      docker_builder_deriv =
        pkgs.dockerTools.buildLayeredImage {
          name = "docker-xo-builder";
          tag = "v1";
          contents = [ self.packages.${system}.git
                       self.packages.${system}.cacert
                       self.packages.${system}.pybind11
                       self.packages.${system}.python
                       self.packages.${system}.libwebsockets
                       self.packages.${system}.catch2
                       self.packages.${system}.cmake
                       self.packages.${system}.gnumake
                       self.packages.${system}.gcc
                       self.packages.${system}.binutils
                       self.packages.${system}.bash
                       self.packages.${system}.coreutils ];
        };

    in rec {
      packages.${system} = {
        # from cmdline,  can build member foo of packages.${system}:
        #   $ nix build .#foo

        default = docker_builder_deriv;
        docker_builder = docker_builder_deriv;

        git = pkgs.git;
        cacert = pkgs.cacert;
        pybind11 = pkgs.python311Packages.pybind11;
        # note: pybind11 doesn't pin a python dependency,
        #       presumably because doesn't know which python311 version we want
        python = pkgs.python311;
        libwebsockets = pkgs.libwebsockets;
        catch2 = pkgs.catch2;
        cmake = pkgs.cmake;
        gnumake = pkgs.gnumake;
        gcc = pkgs.gcc;
        binutils = pkgs.binutils;
        bash = pkgs.bash;
        coreutils = pkgs.coreutils;
      };
    };
}
