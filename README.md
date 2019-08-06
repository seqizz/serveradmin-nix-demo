Easiest way to run a [Serveradmin](https://github.com/innogames/serveradmin) instance.

This demo deploys serveradmin as a VirtualBox instance,
refer to NixOps documentation for more deployment options (AWS, Azure, DigitalOcean etc.)

## Installation
- Install [NixOps](https://nixos.org/nixops/manual/#chap-installation) if you don't have it
- Checkout this repo and navigate into
- Run `nixops create demo.nix`, this will create the definition under nixops
- Deploy the server via `nixops deploy`
- After it's done, you need to SSH into the machine via `nixops ssh serveradmin` and run `initialize_serveradmin` _once_
- It's ready! Check the machine IP via `nixops info` and visit via your browser

Default username & password is `test`.
