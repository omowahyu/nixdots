{ pkgs, ... }:

{
  boot.kernel.sysctl = {
    # Optimasi buffer DNS
    "net.core.rmem_max" = 2500000;
    "net.core.netdev_max_backlog" = 16384;
    "net.ipv4.udp_rmem_min" = 8192;
    
    # IPv6 optimizations
    "net.ipv6.udp_rmem_min" = 8192;
  };
}
