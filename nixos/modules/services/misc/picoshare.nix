{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.picoshare;
in
{
  options.services.picoshare = {
    enable = mkEnableOption "PicoShare";

    package = mkPackageOption pkgs "picoshare" { };

    databasePath = mkOption {
      type = types.str;
      default = "/var/lib/picoshare/picoshare.db";
      description = "Path to the backing SQLite database should be storing.";
    };

    vacuum = mkOption {
      type = types.bool;
      default = false;
      description = "Vacuum database periodically to reclaim disk space (increases RAM usage).";
    };

    port = mkOption {
      type = types.port;
      description = "The port to listen on.";
      default = 4001;
    };

    behindProxy = mkOption {
      type = types.bool;
      description = "Set to `true` for better logging when PicoShare is running behind a reverse proxy.";
      default = false;
    };

    sharedSecret = mkOption {
      type = types.str;
      description = "Specifies a passphrase for the admin user to log in to PicoShare.";
    };

    litestream = {
      bucket = mkOption {
        type = with types; nullOr str;
        description = "Litestream-compatible cloud storage bucket where Litestream should replicate data.";
      };

      endpoint = mkOption {
        type = with types; nullOr str;
        description = "Litestream-compatible cloud storage endpoint where Litestream should replicate data.";
      };

      accessKeyId = mkOption {
        type = with types; nullOr str;
        description = "Litestream-compatible cloud storage access key ID to the bucket where you want to replicate data.";
      };

      secretAccessKey = mkOption {
        type = with types; nullOr str;
        description = "Litestream-compatible cloud storage secret access key to the bucket where you want to replicate data.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.picoshare = {
      description = "PicoShare minimalistic file sharing server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig.Documentation = "https://github.com/mtlynch/picoshare/tree/master";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/picoshare -db ${cfg.databasePath} ${optionalString cfg.vacuum "-vacuum"}";
        User = "picoshare";
        DynamicUser = true;

        StateDirectory = "picoshare";
        StateDirectoryMode = "0700";

        AmbientCapabilities = [];
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        UMask = "0077";
      };
    };
  };
}
