{
  virtualisation.oci-containers.containers = {
    homeassistant = {
      autoStart = true;
      volumes = ["home-assistant:/config"];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/home-assistant/home-assistant:2025.9.4";
      extraOptions = [
        "--network=host"
        "--privileged"
        "--device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_862df52f3380ef118515181cedd322a4-if00-port0:/dev/ttyUSB0"
      ];
    };
    esphome = {
      autoStart = true;
      volumes = ["/var/lib/esp-home:/config"];
      environment.TZ = "Europe/Berlin";
      image = "ghcr.io/esphome/esphome:2025.9.1";
      extraOptions = [
        "--network=host"
      ];
    };
  };
}
