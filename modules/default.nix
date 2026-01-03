{ config, lib, pkgs, ... }:

{
  # Import all shared modules
  imports = [
    ./git
    ./shell
    ./development
  ];

  # This default module can be used to enable common configurations
  # Users can override these settings in their own configurations
}
