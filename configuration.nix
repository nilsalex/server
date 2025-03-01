{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [
    "vfat"
    "nls_cp437"
    "nls_iso8859-1"
    "usbhid"
  ];

  boot.initrd.luks = {
    yubikeySupport = true;
    devices = {
      crypt = {
        device = "/dev/disk/by-uuid/44617fa0-e314-409e-849f-3a501f9d8b36";
        preLVM = true;
        yubikey = {
          slot = 2;
          twoFactor = false;
          storage = {
            device = "/dev/disk/by-uuid/AAAA-2492";
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
  networking.hostId = "1aebc26d";

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  users.users = {
    nils = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
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

  networking.firewall.enable = true;

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
