{
  description = "A white hat flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          isLinux = pkgs.stdenv.isLinux;

          commonPackages = with pkgs; [
            sherlock
            john
            python314
            python313Packages.pip
            pyenv
            rockyou
            sqlmap
            # wordlists  # broken upstream: pulls wfuzz, which fails on python 3.14
            hashcat
            hashcat-utils
            thc-hydra
            nmap
            aircrack-ng
            #wpscan
            #metasploit
            #maltego
            #audiness
          ];

          # Linux-only tooling.
          # - snort / apk-tools are not packaged for darwin.
          # - the OpenCL ICD stack (ocl-icd/pocl/headers) is the Linux path;
          #   on macOS OpenCL is provided by the system framework and hashcat
          #   uses it directly, so these are unnecessary there.
          linuxOnlyPackages = with pkgs; [
            opencl-headers
            ocl-icd
            pocl
            apk-tools
            snort
          ];
        in {
          default = pkgs.mkShell {
            packages = commonPackages ++ lib.optionals isLinux linuxOnlyPackages;

            shellHook = ''
              ${lib.optionalString isLinux ''
                # OpenCL configuration (Linux only)
                export OCL_ICD_VENDORS=${pkgs.pocl}/etc/OpenCL/vendors
                export LD_LIBRARY_PATH=${pkgs.pocl}/lib:$LD_LIBRARY_PATH
              ''}

              # Python venv configuration
              VENV_DIR=".venv"

              if [ ! -d "$VENV_DIR" ]; then
                echo "🐍 Creating Python virtual environment..."
                python -m venv "$VENV_DIR"
                echo "✅ Virtual environment created at $VENV_DIR"
              fi

              echo "🔧 Activating Python virtual environment..."
              source "$VENV_DIR/bin/activate"

              # Upgrade pip and install common tools
              pip install --upgrade pip > /dev/null 2>&1

              # Install hashid if not present
              if ! pip show hashid > /dev/null 2>&1; then
                echo "📦 Installing hashid..."
                pip install hashid > /dev/null 2>&1
              fi

              echo ""
              echo "🎯 White Hat Environment Ready!"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "Python: $(python --version)"
              echo "Pip: $(pip --version | cut -d' ' -f1-2)"
              echo "Hashcat: $(hashcat --version | head -n1)"
              echo "Virtual env: $VENV_DIR"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo ""
            '';
          };
        });
    };
}
