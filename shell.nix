{ lib
, fetchFromGitHub
, cmake
, llvmPackages
, libxml2
, zlib
}:

let
  inherit (llvmPackages) stdenv;
in
stdenv.mkDerivation rec {
  pname = "zig";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "ziglang";
    repo = pname;
    rev = version;
    hash = "sha256-ad3341fff667f374966f880976f255e5e09fa04ea8a44f5f6a47a28abcc4e291";
  };

  nativeBuildInputs = [
    cmake
    llvmPackages.llvm.dev
  ];

  buildInputs = [
    libxml2
    zlib
  ] ++ (with llvmPackages; [
    libclang
    lld
    llvm
  ]);

  preBuild = ''
    export HOME=$TMPDIR;
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ./zig test --cache-dir "$TMPDIR" -I $src/test $src/test/behavior.zig
    runHook postCheck
  '';

  meta = with lib; {
    homepage = "https://ziglang.org/";
    description =
      "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
    license = licenses.mit;
    maintainers = with maintainers; [ andrewrk AndersonTorres ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # See https://github.com/NixOS/nixpkgs/issues/86299
  };
}
}
