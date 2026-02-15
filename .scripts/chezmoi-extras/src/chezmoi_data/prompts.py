from pathlib import Path
from typing import Any

import questionary
from rich.console import Console

from models.colors import Theme, ThemeMode, ThemeModeIcon
from models.metadata import Metadata, Profile, Style

console = Console()


def ask_profile() -> Profile:
    profile: str = questionary.select(
        "Choose a profile:", choices=[p.value for p in Profile]
    ).ask()
    return Profile[profile.upper()]


def ask_style() -> Style:
    style: str = questionary.select("Choose a style:", choices=[s.value for s in Style]).ask()
    return Style[style.upper()]


def ask_theme(colors_path: Path) -> Theme:
    colors_files = [f for f in colors_path.iterdir() if f.is_file()]
    colors_themes: list[Any] = [Theme.from_toml(f) for f in colors_files]
    # Prepare the choices menu
    colors_themes.sort(key=lambda t: t.name or "")
    colors_themes.sort(key=lambda t: t.mode.value)
    separator = questionary.Separator()
    separator_index = next(
        (i for i, t in enumerate(colors_themes) if t.mode == ThemeMode.LIGHT), len(colors_themes)
    )
    colors_themes.insert(separator_index, separator)
    colors_choices = []
    for t in colors_themes:
        if isinstance(t, questionary.Separator):
            colors_choices.append(t)
            continue
        colors_choices.append(
            questionary.Choice(title=f"{ThemeModeIcon[t.mode.name].value} {t.name}", value=t.name)
        )

    selected_name = questionary.select("Choose a color scheme:", choices=colors_choices).ask()
    colors_themes.remove(separator)
    selected_theme = next(t for t in colors_themes if t.name == selected_name)

    return selected_theme


def ask_metadata() -> Metadata:
    profile = ask_profile()
    style = ask_style()
    return Metadata(profile=profile, style=style)
