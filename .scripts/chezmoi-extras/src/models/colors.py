import tomllib
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Optional

import coloraide
import tomli_w

# =======
# Colors
# =======


def _clamp(value: float, min_value: float = 0, max_value: float = 100) -> float:
    return max(min_value, min(max_value, value))


@dataclass
class Color:
    hex: str

    @property
    def _color(self) -> coloraide.Color:
        return coloraide.Color(self.hex).convert(space="hsl")

    def copy(self) -> "Color":
        return Color(self.hex)

    def validate(self) -> None:
        try:
            self._color
        except Exception:
            raise ValueError(f"Invalid color hex: {self.hex}")

    def lighten(self, amount: float) -> "Color":
        """Change the lightness of the color by a relative amount (e.g. 0.1 to increase by 10%)."""
        if not (-1 <= amount <= 1):
            raise ValueError("Amount must be between -1 and 1")
        # Work in HSL space: get coords (h, s, l), adjust L, and construct
        # a new color. Clamp to [0, 1] to match existing behavior.
        base_h, base_s, base_l = self._color.coords()
        new_l = _clamp(base_l + amount)
        new_color = coloraide.Color("hsl", (base_h, base_s, new_l))
        return Color(new_color.convert("srgb").to_string(hex=True))

    def saturate(self, amount: float) -> "Color":
        """Change the saturation of the color by a relative amount (e.g. 0.1 to increase by 10%)."""
        if not (-1 <= amount <= 1):
            raise ValueError("Amount must be between -1 and 1")
        # Work in HSL space: get coords (h, s, l), adjust S, and construct
        # a new color. Clamp to [0, 1] to match existing behavior.
        base_h, base_s, base_l = self._color.coords()
        new_s = _clamp(base_s + amount)
        new_color = coloraide.Color("hsl", (base_h, new_s, base_l))
        return Color(new_color.convert("srgb").to_string(hex=True))

    @staticmethod
    def gradient(start: "Color", end: "Color", steps: int) -> list["Color"]:
        """Generate a gradient of colors between start and end."""
        # Interpolate in Lab (perceptually uniform) space
        start_color = start._color.convert("lab").coords()
        end_color = end._color.convert("lab").coords()
        gradient_ramp: list[coloraide.Color] = []
        # Generate `steps` samples between start and end inclusive
        for i in range(steps):
            t = 0.0 if steps == 1 else (i / (steps - 1))
            L_component = start_color[0] + (end_color[0] - start_color[0]) * t
            a_component = start_color[1] + (end_color[1] - start_color[1]) * t
            b_component = start_color[2] + (end_color[2] - start_color[2]) * t
            gradient_ramp.append(coloraide.Color("lab", (L_component, a_component, b_component)))
        return [Color(color.convert("srgb").to_string(hex=True)) for color in gradient_ramp]


class ThemeMode(Enum):
    LIGHT = "Light"
    DARK = "Dark"


class ThemeModeIcon(Enum):
    LIGHT = ""
    DARK = ""


@dataclass
class TerminalColors:
    black: Color
    red: Color
    green: Color
    yellow: Color
    blue: Color
    magenta: Color
    cyan: Color
    white: Color

    def _bright_variants(self) -> dict[str, Color]:
        bright_colors = {}
        for name, color in self.__dict__.items():
            bright_colors[f"bright_{name}"] = color.saturate(0.2).lighten(0.1)

        if self.mode == ThemeMode.DARK:
            bright_colors["bright_black"] = self.black.saturate(0.15).lighten(0.15)
            bright_colors["bright_white"] = self.white.saturate(-0.15).lighten(-0.15)
        if self.mode == ThemeMode.LIGHT:
            bright_colors["bright_black"] = self.black.saturate(-0.15).lighten(-0.15)
            bright_colors["bright_white"] = self.white.saturate(0.15).lighten(0.15)

        return bright_colors

    def _numbered_variants(self) -> dict[str, Color]:
        NUMBERS = [16, 17, 18, 19, 20, 21]
        numbered_colors = {}
        gradient = Color.gradient(self.black, self.white, steps=8)[1:7]
        for i, number in enumerate(NUMBERS):
            numbered_colors[f"color_{number}"] = gradient[i]

        return numbered_colors

    @property
    def mode(self) -> ThemeMode:
        # Infer mode based on relative lightness of black and white
        black_lum = self.black._color.luminance()
        white_lum = self.white._color.luminance()
        return ThemeMode.DARK if black_lum < white_lum else ThemeMode.LIGHT

    def validate(self) -> None:
        for color in self.__dict__.values():
            if color is None:
                continue
            color.validate()

    def to_extended_dict(self) -> dict[str, str]:
        colors_dict = {k: v.hex for k, v in self.__dict__.items()}
        colors_dict.update({k: v.hex for k, v in self._bright_variants().items()})
        colors_dict.update({k: v.hex for k, v in self._numbered_variants().items()})
        return colors_dict


@dataclass
class GenericColors:
    # Background-based colors
    surface: Color
    background: Color
    overlay: Color
    # Foreground-based colors
    muted: Color
    subtle: Color
    foreground: Color
    # Informational colors
    success: Color
    warning: Color
    failure: Color
    # Accent colors
    primary: Optional[Color] = None
    secondary: Optional[Color] = None

    @staticmethod
    def from_terminal(terminal: TerminalColors) -> "GenericColors":
        # Surface should come first; background should match surface,
        # and foreground should match white.

        overlay = terminal.black.copy()
        foreground = terminal.white.copy()
        success = terminal.green.copy()
        warning = terminal.yellow.copy()
        failure = terminal.red.copy()
        if terminal.mode == ThemeMode.DARK:
            surface = terminal.black.lighten(-0.07).saturate(0.5)
            background = terminal.black.lighten(-0.05)
            muted = terminal.white.lighten(-0.2).saturate(-0.1)
            subtle = terminal.white.lighten(-0.12).saturate(-0.04)
        else:
            surface = terminal.black.lighten(0.07).saturate(0.5)
            background = terminal.black.lighten(0.05)
            muted = terminal.white.lighten(0.2).saturate(-0.1)
            subtle = terminal.white.lighten(0.12).saturate(-0.04)

        return GenericColors(
            surface=surface,
            background=background,
            overlay=overlay,
            muted=muted,
            subtle=subtle,
            foreground=foreground,
            success=success,
            warning=warning,
            failure=failure,
        )

    def validate(self) -> None:
        for color in self.__dict__.values():
            if color is None:
                continue
            color.validate()

    def to_dict(self) -> dict[str, str]:
        return {k: v.hex for k, v in self.__dict__.items()}


@dataclass
class Theme:
    terminal_colors: TerminalColors
    generic_colors: GenericColors
    name: Optional[str] = None

    @property
    def metadata(self) -> dict[str, str]:
        return {"name": self.name or "Example", "mode": self.terminal_colors.mode.value}

    @property
    def mode(self) -> ThemeMode:
        return self.terminal_colors.mode

    def validate(self) -> None:
        self.terminal_colors.validate()
        self.generic_colors.validate()

    def to_dict(self) -> dict[str, Any]:
        return {
            "colors": {
                "metadata": self.metadata,
                "terminal": self.terminal_colors.to_extended_dict(),
                "generic": self.generic_colors.to_dict(),
            }
        }

    def to_toml(self) -> str:
        return tomli_w.dumps(self.to_dict())

    @staticmethod
    def from_toml(filename: Path) -> "Theme":
        with open(filename, "rb") as f:
            data = tomllib.load(f)
        try:
            name: Optional[str] = data["colors"].get("metadata", {}).get("name")
            terminal_data = data["colors"]["terminal"]
            terminal_data = {
                k: Color(v)
                for k, v in terminal_data.items()
                if k in TerminalColors.__dataclass_fields__.keys()
            }
            generic_data = data["colors"].get("generic", {})
            generic_data = {
                k: Color(v)
                for k, v in generic_data.items()
                if k in GenericColors.__dataclass_fields__.keys()
            }

            terminal_colors = TerminalColors(**terminal_data)
            generic_colors = (
                GenericColors(**generic_data)
                if generic_data
                else GenericColors.from_terminal(terminal_colors)
            )
        except TypeError as e:
            raise TypeError(f"Failed to parse {filename}: {e}")

        theme = Theme(
            terminal_colors=terminal_colors,
            generic_colors=generic_colors,
            name=name,
        )
        theme.validate()

        return theme

    def save(self, path: Path) -> None:
        with open(path, "w") as f:
            f.write(self.to_toml())
