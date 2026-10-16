"""Validation gate for the qompassai/unreal repository.

The repo's built artifacts are Unreal Engine projects and their
configuration: .uproject descriptors (strict JSON), Config/*.ini
files (Unreal INI dialect), the UnrealBuildTool XML configuration,
and binary .uasset packages. Unreal itself is not available in
this environment, so these tests validate the artifacts' own
formats — the same checks that catch a corrupted descriptor or a
truncated asset before an editor ever opens the project.

The vendored opt/UnrealEngine/Config/**/*_SDK.json files are
deliberately NOT strict-parsed: Epic ships them in Unreal's
lenient JSON dialect (comments, trailing commas), which the
engine's own reader accepts and strict JSON rejects.

Run: python3 -m pytest tests/ -q
"""

from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
UASSET_MAGIC = bytes.fromhex('c1832a9e')  # Unreal package file magic
ENGINE_VERSION_RE = re.compile(r'^\d+\.\d+(\.\d+)?$')
MAX_INI_BYTES = 4_000_000


def _validate_uproject(data: object) -> list[str]:
    """Contract for a .uproject descriptor."""
    problems: list[str] = []
    if not isinstance(data, dict):
        return ['uproject: top level is not an object']
    if data.get('FileVersion') != 3:
        problems.append(f'uproject: FileVersion is {data.get("FileVersion")!r}, want 3')
    association = data.get('EngineAssociation')
    if not isinstance(association, str) or not ENGINE_VERSION_RE.match(association):
        problems.append(f'uproject: EngineAssociation {association!r} is not a version')
    modules = data.get('Modules')
    if not isinstance(modules, list) or not modules:
        problems.append('uproject: Modules missing or empty')
    else:
        for module in modules:
            if (
                not isinstance(module, dict)
                or not module.get('Name')
                or not module.get('Type')
            ):
                problems.append(f'uproject: module lacks Name/Type: {module!r}')
    for plugin in data.get('Plugins') or []:
        if not isinstance(plugin, dict) or not plugin.get('Name'):
            problems.append(f'uproject: plugin lacks Name: {plugin!r}')
        elif 'Enabled' in plugin and not isinstance(plugin['Enabled'], bool):
            problems.append(
                f'uproject: plugin {plugin["Name"]} Enabled is not a boolean'
            )
    return problems


def _validate_unreal_ini(text: str) -> list[str]:
    """Contract for Unreal INI: sections, comments, key lines.

    Unreal INI is not configparser INI (array operators +,-,. and
    duplicate keys are normal), so lines are checked by shape:
    blank, comment (';' or '#'), a '[section]' header, or a line
    containing '='. Anything else is malformed.
    """
    problems: list[str] = []
    for number, raw in enumerate(text.splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith((';', '#')):
            continue
        if line.startswith('[') and line.endswith(']') and len(line) > 2:
            continue
        if '=' in line:
            continue
        problems.append(
            f'line {number}: not a section, comment or key=value: {line[:60]!r}'
        )
    return problems


def _validate_uasset_header(data: bytes) -> list[str]:
    """An .uasset package starts with the Unreal package magic."""
    if len(data) < 4:
        return ['uasset: shorter than the 4-byte magic']
    if data[:4] != UASSET_MAGIC:
        return [f'uasset: magic is {data[:4].hex()}, want {UASSET_MAGIC.hex()}']
    return []


def _uproject_files() -> list[Path]:
    return sorted(REPO_ROOT.glob('**/*.uproject'))


def _ini_files() -> list[Path]:
    return sorted(REPO_ROOT.glob('**/*.ini'))


# --- Validation ---


def test_uproject_descriptors_are_valid() -> None:
    files = _uproject_files()
    assert len(files) >= 2, 'expected the edu and MLDeformer projects'
    for path in files:
        data = json.loads(path.read_text(encoding='utf-8'))
        assert _validate_uproject(data) == [], path


def test_all_ini_files_are_well_formed() -> None:
    files = _ini_files()
    assert len(files) >= 70, 'expected the engine + project Config trees'
    for path in files:
        data = path.read_bytes()
        assert len(data) <= MAX_INI_BYTES, path
        assert _validate_unreal_ini(data.decode('utf-8', errors='replace')) == [], path


def test_build_configuration_xml_parses() -> None:
    path = REPO_ROOT / '.config/Unreal Engine/UnrealBuildTool/BuildConfiguration.xml'
    root = ET.parse(path).getroot()
    assert root.tag.endswith('Configuration')


def test_all_uassets_carry_package_magic() -> None:
    files = sorted(REPO_ROOT.glob('**/*.uasset'))
    assert len(files) >= 50, 'expected the edu/Content asset tree'
    for path in files:
        with path.open('rb') as handle:
            assert _validate_uasset_header(handle.read(4)) == [], path


# --- Adversarial ---


def test_uproject_wrong_file_version_is_rejected() -> None:
    data = json.loads(_uproject_files()[0].read_text(encoding='utf-8'))
    data['FileVersion'] = 2
    assert _validate_uproject(data) != []


def test_uproject_non_version_engine_association_is_rejected() -> None:
    data = json.loads(_uproject_files()[0].read_text(encoding='utf-8'))
    data['EngineAssociation'] = 'latest'
    assert _validate_uproject(data) != []


def test_uproject_module_without_type_is_rejected() -> None:
    data = json.loads(_uproject_files()[0].read_text(encoding='utf-8'))
    data['Modules'] = [{'Name': 'OnlyName'}]
    assert _validate_uproject(data) != []


def test_ini_bare_garbage_line_is_rejected() -> None:
    assert _validate_unreal_ini('[Section]\nKey=1\nthis is not a setting\n') != []


def test_ini_unterminated_section_is_rejected() -> None:
    assert _validate_unreal_ini('[Section\nKey=1\n') != []


def test_uasset_bad_magic_is_rejected() -> None:
    assert _validate_uasset_header(bytes.fromhex('deadbeef') + b'payload') != []
    assert _validate_uasset_header(b'\xc1\x83') != []
