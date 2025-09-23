{
  virtualisation.oci-containers.containers.homeassistant = {
    autoStart = true;
    volumes = ["home-assistant:/config"];
    environment.TZ = "Europe/Berlin";
    image = "ghcr.io/home-assistant/home-assistant:2025.9.4";
    extraOptions = [
      "--network=host"
      "--privileged"
    ];
  };
}
