{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      inetutils = prev.inetutils.overrideAttrs (oldAttrs: rec {
        version = "2.6";
        src = prev.fetchurl {
          url = "mirror://gnu/inetutils/inetutils-${version}.tar.xz";
          hash = "sha256-aL7b/q9z99hr4qfZm8+9QJPYKfUncIk5Ga4XTAsjV8o=";
        };
      });
    })
  ];
}
