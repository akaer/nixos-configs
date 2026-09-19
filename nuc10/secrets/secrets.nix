let
  nuc10  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEyjEqAPk/EhSPrdYQUO2oMXGtMtJn348xMpmTk9jcv";
  andrer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMNPncCBc9Dms0+sCeKQHcLUgzl4/AUsPheIkubdlQ7";
in
{
  "claude-env.age".publicKeys = [ nuc10 andrer ];
}
