{ config, pkgs, ... }:

{
  imports = [
  ./network-tweaks.nix
  ];

  # [1] DNS CRYPT PROXY CORE
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = ["127.0.0.1:53" "[::1]:53"];
      server_names = ["cloudflare" "quad9-doh-ip4-port443-filter-pri"];
      
      # Speed Tweaks
      lb_strategy = "fastest";  # Pilih resolver tercepat secara real-time  
      max_inflight_requests = 256;  # Tingkatkan paralelisasi  
      ignore_system_dns = true;  # Hindari kebocoran lewat /etc/resolv.conf  
      cache = true;
      cache_size = 10000;
      cache_min_ttl = 3600;
      cache_max_ttl = 86400;
      cache_neg_ttl = 60;
      tcp_fast_open = true;

      # Security
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = false;
      cloaking_rules = "${pkgs.dnscrypt-proxy2}/example-cloaking-rules.txt";
      block_ipv6 = true;  # Nonaktifkan jika tidak pakai IPv6  

      # Anonymization
      anonymized_dns = {
        routes = [
          { server_name = "*"; via = ["anon-cloudflare" "anon-quad9"]; }
        ];
      };

      # Logging
      log_level = 0;
      use_syslog = true;
    };

    # Blocklists
    upstreamDefaults = false;
    sources = {
      cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
        mypc.local 192.168.1.100
        nas.local 192.168.1.200
      '';
      malware = {
        urls = ["https://mirror.cedia.org.ec/malwaredomains/domains.txt"];
        cache_file = "malware.txt";
        format = "domains";
      };
      ads = {
        urls = ["https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"];
        cache_file = "ads.txt";
        format = "adblock";
      };
    };
  };

  # [2] SYSTEMD HARDENING
  systemd.services.dnscrypt-proxy2.serviceConfig = {
    MemoryDenyWriteExecute = true;
    RestrictSUIDSGID = true;
    NoNewPrivileges = true;
    CPUQuota = "30%";  # Batasi CPU usage  
    MemoryHigh = "500M";  # Batasi memori  
  };

  # [3] NETWORK CONFIG
  networking.nameservers = ["127.0.0.1" "::1"];
  services.resolved.enable = false;
  networking.networkmanager.dns = "none";

}


