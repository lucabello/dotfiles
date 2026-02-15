import tomllib
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any

import tomli_w


class Profile(Enum):
    DESKTOP = "Desktop"
    LAPTOP = "Laptop"
    SERVER = "Server"


class Style(Enum):
    MATERIAL = "Material"


@dataclass
class Metadata:
    profile: Profile
    style: Style

    def to_dict(self) -> dict[str, Any]:
        return {
            "metadata": {
                "profile": self.profile.value,
                "style": self.style.value,
            }
        }

    def to_toml(self) -> str:
        return tomli_w.dumps(self.to_dict())

    @staticmethod
    def from_toml(filename: Path) -> "Metadata":
        with open(filename, "rb") as f:
            data = tomllib.load(f)
        profile: str = data.get("metadata", {}).get("profile")
        style: str = data.get("metadata", {}).get("style")

        if not profile or not style:
            raise ValueError(f"Cannot parse metadata from {filename}")

        return Metadata(profile=Profile[profile.upper()], style=Style[style.upper()])

    def save(self, path: Path) -> None:
        with open(path, "w") as f:
            f.write(self.to_toml())
