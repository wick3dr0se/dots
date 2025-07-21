<div align="center">
<h1>⚫ dots</h1>
<p>My minimalist Arch Linux dotfile configs for Niri & Hyprland </p>
<a href='#'><img src="https://img.shields.io/badge/Maintained%3F-Yes-green.svg?style=flat-square&labelColor=232329&color=5277C3"></img></a>
<a href="https://opensourceforce.net/discord">
<img src="https://discordapp.com/api/guilds/913584348937207839/widget.png?style=shield"/></a>
</div>

## Structure
dots/  
├── [config](config)/ - Common config files to symlink/copy into ~/.config/  
├── [env](env/)/ - Env-specific configurations & scripts  
│ ├── [hyprland](env/hyprland/)/  
│ │ ├── bin/ - Scripts only used for Hyprland  
│ │ ├── config)/ - Hyprland-specific configs (waybar, wofi)  
│ │ └── packages.txt) - Packages used with Hyprland  
│ └── [niri](env/niri/)/  
│ │ ├── bin/ - Scripts only used for Niri  
│ │ ├── config/ - Niri-specific configs (niri, quickshell)  
│ │ └── packages.txt - Packages used with Niri  
├── [home](home/)/ - Common files to symlink/copy into ~/  
└── install.sh - Main setup script (links/copies files, installs packages, ..)

## Environment Specific Configurations
<div align="center">
<h3>Hyprland</h3>
<a href="env/hyprland/"><img src="captures/hyprland.png"/></a>

<h3>Niri</h3>
<a href="env/niri"><img src="captures/niri.png"/></a>
</div>

> [!NOTE]
> I’ve switched to Niri (love it). Hyprland configs *may* not get as much love
