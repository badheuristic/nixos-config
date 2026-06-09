{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "z13ctl";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "dahui";
    repo = "z13ctl";
    rev = "v${version}";
    hash = "sha256-21mdAzbw8JISDLG7iSEI4VCephDTtbioN0/RRxvCLR8=";
  };

  subPackages = [ "." ];

  vendorHash = "sha256-ftkcianIR36PNAoMOVuk4lUr7goWUcHhjyNseUraJU0=";

  meta = with lib; {
    description = "Utility for ASUS ROG Flow Z13 (2025)";
    homepage = "https://github.com/dahui/z13ctl";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}

