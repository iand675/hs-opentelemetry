{
  pkgs,
  src,
}: let
  version = "0.28.0";
  archives = {
    x86_64-linux = {
      platform = "x86_64-unknown-linux-musl";
      sha256 = "69069769ec3509c358ddbfbc29ff9965590fe4f8dd8b03e1c1e1be1ae56122e8";
    };
    aarch64-linux = {
      platform = "aarch64-unknown-linux-musl";
      sha256 = "55a47e3d6226a372570b65853e56413266c149aaa7716172bdffb0dc8422d544";
    };
    x86_64-darwin = {
      platform = "x86_64-apple-darwin";
      sha256 = "40dd65d72b43bc97041b849203e450b322cd786629af8f926cfd2d05798d9ca4";
    };
    aarch64-darwin = {
      platform = "aarch64-apple-darwin";
      sha256 = "b334b37372325f77374b461fd6a11d38bc050122832eb83a9732fcd6831a5ab1";
    };
  };
  archive = archives.${pkgs.stdenv.hostPlatform.system};
  weaver = pkgs.stdenvNoCC.mkDerivation {
    pname = "opentelemetry-weaver";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/open-telemetry/weaver/releases/download/v${version}/weaver-${archive.platform}.tar.xz";
      inherit (archive) sha256;
    };
    sourceRoot = "weaver-${archive.platform}";
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 weaver "$out/bin/weaver"
      runHook postInstall
    '';
  };
  # CI checkouts need not initialize the submodule. Fetch the same immutable
  # release that it pins, rather than following upstream main or a moving tag.
  model =
    pkgs.runCommand "semconv-model-1.45.0" {
      src = pkgs.fetchurl {
        url = "https://github.com/open-telemetry/semantic-conventions/archive/fb30ca17193b551473b1f43c315482918ab6987c.tar.gz";
        hash = "sha256-rv14AIY4kDTUkvPL5S4YDddOYFdwDOFmPFnSHIpJeBg=";
      };
    } ''
      mkdir -p "$out"
      tar -xzf "$src" -C "$out" --strip-components=1
    '';
  tools = [
    (pkgs.haskell.packages.ghc910.ghc.withPackages (hpkgs: with hpkgs; [aeson directory filepath text unordered-containers vector yaml]))
    pkgs.haskellPackages.fourmolu
    pkgs.gnumake
    weaver
  ];
in {
  inherit tools;
  check =
    pkgs.runCommand "semconv-generated" {
      nativeBuildInputs = tools;
    } ''
      cp -R ${src} source
      chmod -R u+w source
      rm -rf source/semantic-conventions/model
      ln -s ${model} source/semantic-conventions/model
      cd source
      make -B -C semantic-conventions generate 'HASKELL_RENDERER=runghc dev/generate.hs'
      for artifact in \
        semantic-conventions/src/OpenTelemetry/SemanticConventions.hs \
        semantic-conventions-metrics/src/OpenTelemetry/SemanticConventions/Metrics.hs \
        semantic-conventions-metrics/docs/metrics.md; do
        diff -u "${src}/$artifact" "$artifact"
      done
      touch "$out"
    '';
}
