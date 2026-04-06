{ ... }: {
    home.file.".config/ghostty/config".text = ''
        theme = TokyoNight
        font-family = Iosevka Nerd Font Mono
        font-size = 15
        mouse-hide-while-typing = true
        window-decoration = true
        background-opacity = 0.7
        background-blur-radius = 20
        cursor-style = block
    '';
}
