{ ... }: {
    home.file.".config/zed/settings.json".text = ''
        {
            "edit_predictions": {
                "provider": "zed"
            },
            "git_panel": {
                "dock": "right"
            },
            "disable_ai": true,
            "icon_theme": "JetBrains New UI Icons (Dark)",
            "base_keymap": "VSCode",
            "project_panel": {
                "dock": "right"
            },
            "agent": {
                "tool_permissions": {
                    "default": "allow"
                },
                "play_sound_when_agent_done": true,
                "default_model": {
                    "provider": "zed.dev",
                    "model": "claude-sonnet-4"
                }
            },
            "ui_font_size": 18,
            "buffer_font_size": 18,
            "theme": {
                "mode": "dark",
                "light": "One Light",
                "dark": "Tokyo Night"
            },
            "autosave": {
                "after_delay": {
                    "milliseconds": 500
                }
            },
            "buffer_font_family": "Iosevka Nerd Font Mono",
            "ui_font_family": "Iosevka Nerd Font Mono",
            "cursor_blink": false,
            "cursor_shape": "block",
            "toolbar": {
                "breadcrumbs": false,
                "quick_actions": false
            },
            "scrollbar": {
                "show": "never"
            },
            "tab_size": 4,
            "terminal": {
                "copy_on_select": false,
                "font_size": 17.0,
                "toolbar": {
                    "breadcrumbs": false
                }
            },
            "soft_wrap": "editor_width",
            "format_on_save": "on",
            "formatter": "auto",
            "code_actions_on_format": {
                "source.organizeImports": true,
                "source.fixAll.eslint": true,
                "source.addMissingImports": true,
                "source.removeUnusedImports": true
            },
            "prettier": {
                "tabWidth": 4,
                "useTabs": false,
                "semi": true,
                "singleQuote": false,
                "jsxSingleQuote": false,
                "trailingComma": "es5",
                "allowParens": "always"
            }
        }
    '';

    home.file.".config/zed/keymap.json".text = ''
        [
            {
                "bindings": {
                    "ctrl-b": "project_panel::ToggleFocus"
                }
            },
            {
                "context": "(Editor && mode == full)",
                "bindings": {
                    "ctrl-enter": "editor::NewlineBelow"
                }
            }
        ]
    '';
}
