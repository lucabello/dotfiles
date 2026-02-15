from pathlib import Path

import typer
from rich.console import Console

from chezmoi_data.prompts import ask_metadata, ask_theme
from models.colors import Theme
from models.metadata import Metadata

app = typer.Typer(no_args_is_help=True)
console = Console()

CHEZMOI_PATH: Path = Path.home().joinpath(".local/share/chezmoi")
CHEZMOI_DATA_PATH: Path = CHEZMOI_PATH.joinpath(".chezmoidata")
CHEZMOI_DATA_METADATA_PATH: Path = CHEZMOI_DATA_PATH.joinpath("metadata.toml")
CHEZMOI_DATA_COLORS_PATH: Path = CHEZMOI_DATA_PATH.joinpath("colors.toml")
CHEZMOI_AVAILABLE_COLORS_PATH: Path = CHEZMOI_PATH.joinpath(".colors")


@app.command()
def show(
    metadata: bool = typer.Option(False, "--metadata", help="Only show the metadata"),
    colors: bool = typer.Option(False, "--colors", help="Only show the colors"),
):
    """Print the Chezmoi metadata or colors.

    If `--metadata` is provided, only metadata is printed. If `--colors` is
    provided, only colors are printed. If neither or both are provided, all
    data is shown.
    """
    if not metadata and not colors:
        metadata = True
        colors = True

    # Default: show everything
    data_files: list[Path] = [f for f in CHEZMOI_DATA_PATH.iterdir() if f.is_file()]
    console.print(f"[bold]Data files for Chezmoi in {CHEZMOI_DATA_PATH}[/]")
    console.print("\n".join([str(f) for f in data_files]))

    if metadata:
        console.print()
        console.print(f"[bold]Metadata ({CHEZMOI_DATA_METADATA_PATH})[/]")
        metadata_obj = Metadata.from_toml(CHEZMOI_DATA_METADATA_PATH)
        print(metadata_obj.to_toml())

    if colors:
        console.print()
        console.print(f"[bold]Colors ({CHEZMOI_DATA_COLORS_PATH}) [/]")
        theme = Theme.from_toml(CHEZMOI_DATA_COLORS_PATH)
        print(theme.to_toml())


@app.command()
def create():
    """Interactively create data for chezmoi and output as TOML."""
    console.print("[bold]Create Chezmoi metadata[/]")

    metadata = ask_metadata()
    theme = ask_theme(CHEZMOI_AVAILABLE_COLORS_PATH)

    metadata.save(CHEZMOI_DATA_METADATA_PATH)
    console.print(f"[green]✓[/green] Saved metadata to {CHEZMOI_DATA_METADATA_PATH}")
    theme.save(CHEZMOI_DATA_COLORS_PATH)
    console.print(f"[green]✓[/green] Saved color metadata to {CHEZMOI_DATA_COLORS_PATH}")
