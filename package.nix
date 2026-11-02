{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  curl,
  jdk25,
  sbt,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eezo";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Eezo-framework";
    repo = "eezo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OClzzb21hxWyLUKdIv3nZr6RSi1+tDEIFPKgZSxiD1k=";
  };

  pom = fetchurl {
    url = "https://repo1.maven.org/maven2/io/eezo/eezo_3/${finalAttrs.version}/eezo_3-${finalAttrs.version}.pom";
    hash = "sha256-17gojRprKeKoJmR+OAsVlvPjXtqR2XSGXN/FmrF+wA0=";
  };

  patches = [ ./patches/upgrade-nix.patch ];

  # jdk25 and sbt only satisfy install.sh's toolchain check; nothing is compiled.
  # curl is how install.sh reads the file:// mirror.
  nativeBuildInputs = [
    makeWrapper
    curl
    jdk25
    sbt
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p mirror/maven/eezo_3/$version mirror/site/install
    cp $pom mirror/maven/eezo_3/$version/eezo_3-$version.pom
    cp bin/eezo mirror/site/install/eezo

    EEZO_VERSION=$version \
    EEZO_HOME=$out/share/eezo \
    EEZO_BIN=$out/bin \
    EEZO_SITE=file://$PWD/mirror/site \
    EEZO_MAVEN=file://$PWD/mirror/maven \
      bash site/src/main/resources/assets/install.sh

    wrapProgram $out/bin/eezo \
      --set EEZO_HOME $out/share/eezo \
      --prefix PATH : ${lib.makeBinPath [ curl ]}

    runHook postInstall
  '';

  meta = {
    description = "CLI for eezo, a Scala 3 web framework";
    homepage = "https://eezo.io";
    license = lib.licenses.mit;
    mainProgram = "eezo";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
