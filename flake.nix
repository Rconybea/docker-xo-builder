# To (re)build:
#   $ cd ~/proj/docker-xo-builder   # this directory
#   $ nix build

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
      env = pkgs.stdenv;

      # 1. The purpose of this derivation is to let us put development packages in our docker image
      #    (see docker_builder_deriv below).
      #    if we write
      #      docker_builder_deriv = pkgs.dockerTools.buildLayeredImage {
      #        ...
      #        contents = [ self.packages.${system}.libwebsockets ]
      #        ...
      #      };
      #    then we get get libwebsockets.so,   but not the c++/cmake support libwebSockets-config.cmake etc.
      #
      # 2. Note that listing deps on docker image doesn't work because the the "development version"
      #    of a package doesn't seem to have a well-known name (at least not one known to nix-env -qaP)
      #
      xo_shim_env_deriv =
        pkgs.stdenv.mkDerivation {
          name = "xo-shim";
          builder = "self.packages.${system}.bash}/bin/bash";
          args = [ ./xo-shim-builder.sh ];
          nativeBuildInputs = [ pkgs.coreutils ];
        };

      docker_builder_deriv =
        pkgs.dockerTools.buildLayeredImage {
          name = "docker-xo-builder";
          tag = "v1";
          created = "now";    # warning: breaks deterministic output!
          #copyToRoot = with pkgs.dockerTools;
          #  [
          #    usrBinEnv       # provide /usr/bin/env
          #    binSh           # provide /bin/sh (really bashInteractive)
          #    caCertificates  # provide /etc/ssl/certs/ca-certificates.crt
          #    fakeNss         # provide /etc/passwd, /etc/group containing root + nobody
          #  ];
          contents = [ self.packages.${system}.xo_shim_env
                       self.packages.${system}.git
                       #self.packages.${system}.cacert
                       self.packages.${system}.pybind11
                       self.packages.${system}.python
                       self.packages.${system}.libwebsockets
                       self.packages.${system}.catch2
                       self.packages.${system}.cmake
                       self.packages.${system}.gnumake
                       self.packages.${system}.gcc
                       self.packages.${system}.binutils
                       self.packages.${system}.bash
                       self.packages.${system}.tree
                       self.packages.${system}.coreutils ];
        };

    in rec {
      packages.${system} = {
        # from cmdline,  can build member foo of packages.${system}:
        #   $ nix build .#foo

        default = docker_builder_deriv;
        xo_shim_env = xo_shim_env_deriv;
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
        tree = pkgs.tree;
        coreutils = pkgs.coreutils;
      };
    };
}
