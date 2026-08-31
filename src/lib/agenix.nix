{ lib }:
let
  # Derive a stable secret name from a path inside the repo's `src/` tree.
  #
  # During evaluation, `file` may be either a source path or a store path. We
  # normalize by extracting the trailing `src/...` part when present.
  keyFor = file:
    let
      s = toString file;
      m = builtins.match ".*/src/(.*)" s;
    in
    if m != null then builtins.elemAt m 0 else s;
in
{
  agenixName = file: "secret-" + builtins.substring 0 16 (builtins.hashString "sha256" (keyFor file));
}
