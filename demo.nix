{
  network = {
    description = "Serveradmin Demo Instance";
    enableRollback = true;
  };

  serveradmin = {resources, config, pkgs, ... }:
  {
    # Definition of the VM
    imports = [
      ./vm/serveradmin.nix
    ];

    # Networking
    networking.hostName = "serveradmin-demo";
    networking.firewall.enable = false;
    services.openssh.enable = true;

    # Deployment
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox.memorySize = 1024; # megabytes
    deployment.virtualbox.vcpu = 2; # number of cpus
    deployment.virtualbox.headless = true;

  };
}
