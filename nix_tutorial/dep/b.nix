{ stdenv, lib, a } :
let
    b_ver = a.version;
    fs = lib.fileset;
    sourceFiles = ./b.nix;
in
stdenv.mkDerivation {
    name = "b";
    pname = "b";
    version = "1.0";
    src = fs.toSource {
        root = ./.;
        fileset = sourceFiles;
    };

    buildPhase = ''
        echo "b building with dep a.v${b_ver} ... " 
        touch b.out
    '';

    installPhase = ''
        echo "b installing ... " 
        mkdir -p $out/bin
        cp b.out $out/bin
    '';
}