from __future__ import annotations

from pathlib import Path
from typing import Optional

import typer
from rich.console import Console

from chezmoi_theme.prompts import ask_missing
from models.colors import Theme

app = typer.Typer(no_args_is_help=True)
console = Console()


@app.command()
def create(
    output: Optional[Path] = typer.Option(None, "--output", "-o", help="Path to save TOML file"),
    input: Optional[Path] = typer.Option(
        None, "--input", "-i", help="Path to input TOML theme to load"
    ),
):
    """Interactively create a theme and output as TOML."""
    console.print("[bold]Create or load a chezmoi theme[/]")

    theme = Theme.from_toml(input) if input else None
    theme = ask_missing(theme, ask_generic=False)
    theme.validate()

    theme.save(output) if output else print(theme.to_toml())
    console.print(f"[green]✓[/green] Saved theme to {output}")
