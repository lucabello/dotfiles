from pathlib import Path

from chezmoi_theme._models import Metadata, Theme


def test_theme_roundtrip(tmp_path: Path):
    metadata = Metadata(name="test", mode="Dark")
    terminal = {
        "black": "#000000",
        "red": "#ff0000",
        "green": "#00ff00",
        "yellow": "#ffff00",
        "blue": "#0000ff",
        "magenta": "#ff00ff",
        "cyan": "#00ffff",
        "white": "#ffffff",
    }
    generic = {"background": "#000000", "text": "#ffffff"}
    theme = Theme(metadata=metadata, terminal=terminal, generic=generic)

    p = tmp_path / "theme.toml"
    theme.save(p)
    loaded = Theme.load(p)
    loaded.validate()

    assert loaded.metadata.name == theme.metadata.name
    assert loaded.metadata.mode == theme.metadata.mode
    assert loaded.terminal == theme.terminal
    assert loaded.generic == theme.generic
