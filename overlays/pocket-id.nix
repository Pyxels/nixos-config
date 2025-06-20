(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.4.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-2wwqvxr1YmfMFhfmx8rTClv+2ug493rl/L/xklEHnUw=";
    };
    vendorHash = "sha256-9zPajwpfjsItAx3WAk4JiVlraTGHmYhLJ6VKRulPFOI=";

    frontend = oldAttrs.frontend.overrideAttrs (oldFrontend: {
      inherit src version;
      npmDeps = oldFrontend.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-Ge3+IaffW8jCfUwj2FOt0GR0HbVy70EXel9TN2zVrB4=";
      });
    });
  });
})
