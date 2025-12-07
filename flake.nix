{
  description = "A white hat flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
    nixosConfigurations."USER" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
    };

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        sherlock
        john
        python314
        python313Packages.pip
        pyenv
        rockyou
        sqlmap
        wordlists
        hashcat
        hashcat-utils
        opencl-headers
        ocl-icd
        pocl
        thc-hydra
        nmap
        #wpscan
        aircrack-ng
        #metasploit
        #maltego
        audiness
        apk-tools
        snort
      ];
      
      shellHook = ''
        # OpenCL configuration
        export OCL_ICD_VENDORS=${nixpkgs.legacyPackages.x86_64-linux.pocl}/etc/OpenCL/vendors
        export LD_LIBRARY_PATH=${nixpkgs.legacyPackages.x86_64-linux.pocl}/lib:$LD_LIBRARY_PATH
        
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
  };
}