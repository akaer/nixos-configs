let
  tpt470  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILR5cHQufRBSP/uY0+eb1AjrzH2yMp+gihO+hV/NfUhb";
  andrer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINDi6dNptXoujIJY0j5k5yFQLF0ygSfUFWM8sfGYU/2B";
in
{
  "claude-env.age".publicKeys = [ tpt470 andrer ];
}
