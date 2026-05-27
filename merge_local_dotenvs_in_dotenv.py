import os
import sys
from pathlib import Path

BASE_DIR = Path(__file__).parent.resolve()

def merge(environment: str) -> None:
    env_dir = BASE_DIR / ".envs" / f".{environment}"
    output_file = BASE_DIR / ".env"

    if not env_dir.exists():
        print(f"No existe: {env_dir}")
        sys.exit(1)

    merged = ""
    for f in sorted(env_dir.iterdir()):
        if f.is_file():
            merged += f.read_text()
            merged += os.linesep

    output_file.write_text(merged)


if __name__ == "__main__":
    merge(sys.argv[1])
