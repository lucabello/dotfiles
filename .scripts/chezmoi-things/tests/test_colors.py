from coloraide import Color

from chezmoi_theme import _colors


def test_parse_hex_valid():
    c = _colors.parse_hex("#1a2b3c")
    assert isinstance(c, Color)


def test_parse_hex_invalid():
    try:
        _colors.parse_hex("not-a-hex")
        assert False, "Should have raised"
    except ValueError:
        pass


def test_generate_gray_scale_and_infer():
    black = _colors.parse_hex("#000000")
    white = _colors.parse_hex("#ffffff")
    gray6 = _colors.generate_gray_scale(black, white)
    assert len(gray6) == 6
    mode = _colors.infer_mode(black, white)
    assert mode == "Dark"


def test_generate_named_colors_keys():
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
    gen = _colors.generate_named_colors(terminal, "blue", "Dark")
    for key in ["base", "background", "surface", "overlay", "muted", "subtle", "text", "primary"]:
        assert key in gen
