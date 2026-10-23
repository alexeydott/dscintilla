"""Exercise a compiled SciConfGen without modifying the input settings catalogs."""
import argparse
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("generator", type=Path)
    parser.add_argument("settings", type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="confgen-") as directory:
        root = Path(directory)
        seed = ET.parse(args.settings / "DScintilla.config.xml")
        changes = {
            "Editor": {"UpperLineSpacing": "3", "LowerLineSpacing": "5"},
            "TextPadding": {"Left": "9", "Right": "7"},
            "LineWrapping": {"Enabled": "yes", "Mode": "2"},
            "StatusBar": {"Visible": "yes", "PanelFile": "yes"},
            "Logging": {"Enabled": "yes", "Level": "2"},
            "Rendering": {"Technology": "1", "FontQuality": "2"},
        }
        for name, attributes in changes.items():
            seed.getroot().find(name).attrib.update(attributes)
        seed_path = root / "seed.xml"
        seed.write(seed_path, encoding="utf-8", xml_declaration=True)
        command = [str(args.generator.resolve()),
                   f"--settings-dir={args.settings.resolve()}",
                   f"--seed-config={seed_path}"]
        for option, filename in [("config", "config.xml"), ("xml", "default.xml"),
                                 ("unit", "default.pas"), ("rc", "default.rc"),
                                 ("res", "default.res")]:
            command.append(f"--out-{option}={root / filename}")
        subprocess.run(command, check=True)
        generated = ET.parse(root / "default.xml").getroot()
        for original in seed.getroot():
            if original.tag in ("Styles", "Theme"):
                continue
            actual = generated.find(original.tag)
            assert actual is not None, original.tag
            assert actual.attrib == original.attrib, (original.tag, actual.attrib, original.attrib)
            assert (actual.text or "").strip() == (original.text or "").strip(), original.tag
        styles = generated.find("Styles/Style[@name='powershell']/WordStyles")
        for style_id in (7, 11, 12):
            token = styles.find(f"WordStyle[@styleID='{style_id}']")
            assert token is not None, style_id
            assert "bgColor" not in token.attrib, token.attrib
            assert "fgColor" not in token.attrib, token.attrib
        assert styles.find("WordStyle[@styleID='1']").get("fgColor") is not None
        assert generated.findall(".//Keywords"), "Keyword catalogs were lost"
        seed_path.write_text("<Config><broken>", encoding="utf-8")
        assert subprocess.run(command, capture_output=True).returncode != 0
        print("PASS: complete seed settings, partial theme inheritance, explicit colors, keywords, malformed XML")


if __name__ == "__main__":
    main()
