{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    kernelModules = [
      "vfat"
      "nls_cp437"
      "nls_iso8859-1"
      "usbhid"
    ];

    luks = {
      yubikeySupport = true;

      devices = {
        "nixos-enc" = {
          device = "/dev/disk/by-uuid/905ee60f-3941-4c86-8bb0-5353c0239f65";
          preLVM = true;
          yubikey = {
            slot = 2;
            twoFactor = false;
            storage = {
              device = "/dev/disk/by-uuid/12CE-A600";
            };
          };
        };
      };
    };
  };

  boot.supportedFilesystems = {
    zfs = true;
  };

  boot.zfs.extraPools = [ "tank" ];

  networking.hostName = "server";
  networking.hostId = "7c08a933";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  users.groups = {
    jn = {
      gid = 1002;
    };
  };

  users.users = {
    nils = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [
        "jn"
        "wheel"
      ];
      shell = pkgs.bash;
      home = "/home/nils";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRbrP4JAS0nwv2CAUDkijy2F7T1h3vajps0KIUwFVRM nils"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEr83cbWuqMV29/6egRJFnd/Bn0+FyAwLCtHWRtF+bK1 nils"
      ];
    };
    jenny = {
      uid = 1001;
      isNormalUser = true;
      extraGroups = [ "jn" ];
      home = "/home/jenny";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "nils" ];
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server role" = "standalone server";
        "security" = "user";
      };
      jenny = {
        "comment" = "Jenny";
        "path" = "/tank/enc/home/jenny";
        "valid users" = "jenny";
        "create mask" = "0660";
        "directory mask" = "0770";
        "guest ok" = "no";
        "browseable" = "yes";
        "read only" = "no";
      };
      nils = {
        "comment" = "Nils";
        "path" = "/tank/enc/home/nils";
        "valid users" = "nils";
        "create mask" = "0660";
        "directory mask" = "0770";
        "guest ok" = "no";
        "browseable" = "yes";
        "read only" = "no";
      };
      paperless = {
        "comment" = "paperless";
        "path" = "/tank/enc/paperless/consume";
        "valid users" = "@jn";
        "force group" = "paperless";
        "create mask" = "0660";
        "directory mask" = "0770";
        "guest ok" = "no";
        "browseable" = "yes";
        "read only" = "no";
      };
      photos = {
        "comment" = "Photos";
        "path" = "/tank/enc/photos";
        "valid users" = "@jn";
        "force group" = "jn";
        "create mask" = "0660";
        "directory mask" = "0770";
        "guest ok" = "no";
        "browseable" = "yes";
        "read only" = "no";
      };
      media = {
        "comment" = "Media";
        "path" = "/tank/enc/media";
        "valid users" = "@jn";
        "force group" = "jn";
        "create mask" = "0660";
        "directory mask" = "0770";
        "guest ok" = "no";
        "browseable" = "yes";
        "read only" = "no";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.paperless = {
    enable = true;
    dataDir = "/tank/enc/paperless";
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_URL = "https://doc.ernj.me";
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
    exporter.enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nils@famalex.de";
    certs."doc.ernj.me" = {
      dnsProvider = "route53";
      group = "nginx";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "doc.ernj.me" = {
        forceSSL = true;
        useACMEHost = "doc.ernj.me";
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:28981/";
          };
        };
      };
    };
  };

  services.zfs.autoScrub.enable = true;

  programs.mosh.enable = true;

  nix.settings.trusted-users = [ "nils" ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
