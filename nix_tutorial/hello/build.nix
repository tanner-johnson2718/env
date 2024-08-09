# Build with 'nix-build'

{ stdenv, lib } :
let
    fs = lib.fileset;
    sourceFiles = ./hello.c;
    exeName = "hello";
in

# Print the source files
fs.trace sourceFiles

stdenv.mkDerivation {
    name = "hello";
    pname = "hello";
    version = "0.0.1";
    src = fs.toSource {
        root = ./.;
        fileset = sourceFiles;
    };

    buildPhase = ''
        gcc hello.c -o ${exeName}
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp ${exeName} $out/bin
    '';
    
    shellHook = ''
    echo "Nix Shell Starting up!"
    '';

    # builder = builder.sh   -> Can also overwrite the default build script 
    # with this
}