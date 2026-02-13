from typing import Optional

import questionary
from rich.console import Console

from chezmoi_theme.models import Color, GenericColors, TerminalColors, Theme

console = Console()


def ask_theme_name() -> str:
    name = questionary.text("Theme name:").ask()
    if not name:
        raise ValueError("Theme name required")
    return name


def ask_color(name: str) -> Color:
    while True:
        hex = questionary.text(f"{name} color:", default="#").ask()
        if hex is None:
            raise ValueError("Theme creation aborted")
        color = Color(hex)
        try:
            color.validate()
            return color
        except ValueError:
            continue


def ask_terminal_colors() -> TerminalColors:
    color_names = list(TerminalColors.__dataclass_fields__.keys())
    return TerminalColors(**{k: ask_color(k) for k in color_names})


def ask_generic_colors() -> GenericColors:
    color_names = list(GenericColors.__dataclass_fields__.keys())
    return GenericColors(**{k: ask_color(k) for k in color_names})


def ask_accent_colors(terminal_colors: TerminalColors) -> tuple[Color, Color]:
    colors = terminal_colors.to_extended_dict()
    color_names = list(colors.keys())[:16]
    primary = questionary.select(
        "Choose primary (accent) terminal color:",
        choices=list(color_names),
    ).ask()
    secondary = questionary.select(
        "Choose secondary (accent) terminal color:",
        choices=list(color_names),
    ).ask()
    if not primary or not secondary:
        raise ValueError("Theme creation aborted")

    return Color(colors[primary]), Color(colors[secondary])


def ask_missing(theme: Optional[Theme], ask_generic: bool = False) -> Theme:
    if theme is None:
        name = ask_theme_name()
        terminal_colors = ask_terminal_colors()
        generic_colors = GenericColors.from_terminal(terminal_colors)
        if ask_generic:
            generic_colors = ask_generic_colors()
        theme = Theme(terminal_colors=terminal_colors, generic_colors=generic_colors, name=name)

    if not theme.name:
        theme.name = ask_theme_name()
    if not theme.terminal_colors:
        theme.terminal_colors = ask_terminal_colors()
    if ask_generic and not theme.generic_colors:
        theme.generic_colors = ask_generic_colors()
    if theme.generic_colors and (
        not theme.generic_colors.primary or not theme.generic_colors.secondary
    ):
        primary, secondary = ask_accent_colors(theme.terminal_colors)
        theme.generic_colors.primary = primary
        theme.generic_colors.secondary = secondary

    return theme
