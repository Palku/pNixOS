# home/terminal.nix - High-performance terminal configuration
{ config, pkgs, ... }:

{
  # Additional performance tools
  home.packages = with pkgs; [
    # Modern CLI tools for performance
    eza      # Better ls
    bat      # Better cat
    fd       # Better find
    ripgrep  # Better grep
    dust     # Better du
    duf      # Better df
    bottom   # Better top
    procs    # Better ps

    # Network tools
    bandwhich # Network usage
    dog       # Better dig

    # System monitoring
    btop     # Beautiful system monitor
    zenith   # System monitor
  ];
}
