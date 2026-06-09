{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
	device = "/dev/nvme0n1";
	content = {
	  type = "gpt";
	  partitions = {
	    boot = {
	      size = "512M";
	      type = "EF00";
	      content = {
	        type = "filesystem";
		format = "vfat";
		mountpoint = "/boot";
		mountOptions = [ "umask=0077" ];
	      };
	    };
	    luks = {
	      size = "100%";
	      content = {
	        type = "luks";
		name = "crypted";
		settings = { allowDiscards = true; };
		content = {
		  type = "lvm_pv";
		  vg = "pool";
		};
	      };
	    };
	  };
	};
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "32G";
            content = {
              type = "swap";
      	resumeDevice = true;
            };
          };
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
      	      extraArgs = [ "-f" ];
      	      subvolumes = {
      	        "/root" = { mountpoint = "/"; };
      	        "/home" = { mountpoint = "/home"; };
      	        "/nix" = { mountpoint = "/nix"; };
      	      };
            };
          };
        };
      };
    };
  };
}
