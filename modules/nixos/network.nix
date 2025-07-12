# modules/nixos/network.nix - Network optimizations
{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.kernel.sysctl = {
    # Modern TCP optimizations
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
  };

  # Faster DNS resolution
  services.resolved = {
    enable = true;
    dnssec = "false"; # Slight performance boost
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
      DNSOverTLS=yes
      Cache=yes
    '';
  };
}
