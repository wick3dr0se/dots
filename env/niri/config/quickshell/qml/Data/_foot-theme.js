// plain JS helper – no QML imports
function apply(theme) {
    console.log("FootTheme: applying palette to foot …");

    const ini =
`foreground=${theme.base05}
background=${theme.base00}
color0=${theme.base00}
color1=${theme.base08}
color2=${theme.base0B}
color3=${theme.base0A}
color4=${theme.base0D}
color5=${theme.base0E}
color6=${theme.base0C}
color7=${theme.base05}
color8=${theme.base03}
color9=${theme.base08}
color10=${theme.base0B}
color11=${theme.base0A}
color12=${theme.base0D}
color13=${theme.base0E}
color14=${theme.base0C}
color15=${theme.base07}
`;

    /* ---------- writer process ---------- */
    const writer = Qt.createQmlObject(
        'import Quickshell.Io; Process {}',
        Qt.application,
        'FootThemeWriter'
    );
    writer.command = [
        "sh", "-c",
        "mkdir -p \"$HOME/.config/foot\" && " +
        // single‑quote the heredoc so no interpolation happens
        "cat > \"$HOME/.config/foot/foot.ini\" <<'END_FOOT'\n" +
        ini +
        "END_FOOT"
    ];
    writer.running = true;

    /* ---------- poke running foot ---------- */
    const poke = Qt.createQmlObject(
        'import Quickshell.Io; Process { running: true; command: ["pkill","-SIGUSR1","foot"] }',
        Qt.application,
        'FootThemePoke'
    );
}

