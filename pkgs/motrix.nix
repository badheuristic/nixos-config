{ lib, appimageTools, fetchurl }:

# Motrix from the upstream AppImage. nixpkgs is stuck on 1.8.19 with no
# maintainer while upstream moved to 2.x; bump `version` and `hash` here
# (nix store prefetch-file <url>) for new releases.
let
  pname = "motrix";
  version = "2.4.2";

  src = fetchurl {
    url = "https://github.com/agalwood/Motrix/releases/download/v${version}/Motrix-${version}-x86_64.AppImage";
    hash = "sha256-y9jAbJLzPSRUtzV4MdQHRiiZ2KoYRIVly/uQIiqanNk=";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${contents}/motrix.desktop -t $out/share/applications
    cp -r ${contents}/usr/share/icons $out/share
    substituteInPlace $out/share/applications/motrix.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=motrix'
  '';

  meta = {
    description = "Full-featured download manager";
    homepage = "https://motrix.app";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "motrix";
  };
}
