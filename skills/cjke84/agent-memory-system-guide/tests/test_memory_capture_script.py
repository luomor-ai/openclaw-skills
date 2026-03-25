from pathlib import Path
import subprocess
import sys
import zipfile


def script_path() -> Path:
    return Path(__file__).resolve().parents[1] / 'scripts' / 'memory_capture.py'


def run_script(tmp_path: Path, *args: str) -> subprocess.CompletedProcess[str]:
    repo_root = Path(__file__).resolve().parents[1]
    return subprocess.run(
        [sys.executable, str(script_path()), '--workspace', str(tmp_path), *args],
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )


def run_command(*args: str, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    repo_root = Path(__file__).resolve().parents[1]
    return subprocess.run(
        [sys.executable, str(script_path()), *args],
        cwd=cwd or repo_root,
        text=True,
        capture_output=True,
        check=False,
    )


def test_bootstrap_creates_missing_memory_files(tmp_path: Path):
    result = run_script(tmp_path, '--generated-at', '2026-03-24T09:30:00+08:00')

    assert result.returncode == 0
    assert (tmp_path / 'SESSION-STATE.md').exists()
    assert (tmp_path / 'working-buffer.md').exists()
    capture_path = tmp_path / 'memory-capture.md'
    assert capture_path.exists()
    capture_text = capture_path.read_text(encoding='utf-8')
    assert 'Generated at: 2026-03-24T09:30:00+08:00' in capture_text
    assert '候选决策' in capture_text


def test_bootstrap_preserves_existing_state_files(tmp_path: Path):
    session_state = tmp_path / 'SESSION-STATE.md'
    working_buffer = tmp_path / 'working-buffer.md'
    session_state.write_text('# SESSION-STATE.md\n\ncustom session\n', encoding='utf-8')
    working_buffer.write_text('# working-buffer.md\n\ncustom buffer\n', encoding='utf-8')

    result = run_script(tmp_path, '--generated-at', '2026-03-24T10:00:00+08:00')

    assert result.returncode == 0
    assert session_state.read_text(encoding='utf-8') == '# SESSION-STATE.md\n\ncustom session\n'
    assert working_buffer.read_text(encoding='utf-8') == '# working-buffer.md\n\ncustom buffer\n'


def test_bootstrap_subcommand_creates_missing_memory_files(tmp_path: Path):
    result = run_command(
        'bootstrap',
        '--workspace',
        str(tmp_path),
        '--generated-at',
        '2026-03-24T11:00:00+08:00',
    )

    assert result.returncode == 0
    assert (tmp_path / 'SESSION-STATE.md').exists()
    assert (tmp_path / 'working-buffer.md').exists()
    assert (tmp_path / 'memory-capture.md').exists()


def test_export_creates_archive_with_manifest(tmp_path: Path):
    workspace = tmp_path / 'workspace'
    memory_dir = workspace / 'memory'
    attachments_dir = workspace / 'attachments'
    memory_dir.mkdir(parents=True)
    attachments_dir.mkdir()
    (workspace / 'MEMORY.md').write_text('# MEMORY\n', encoding='utf-8')
    (workspace / 'SESSION-STATE.md').write_text('# SESSION\n', encoding='utf-8')
    (workspace / 'working-buffer.md').write_text('# BUFFER\n', encoding='utf-8')
    (workspace / 'memory-capture.md').write_text('# CAPTURE\n', encoding='utf-8')
    (memory_dir / '2026-03-25.md').write_text('# daily\n', encoding='utf-8')
    (attachments_dir / 'note.txt').write_text('evidence\n', encoding='utf-8')
    backup_path = tmp_path / 'backup.zip'

    result = run_command(
        'export',
        '--workspace',
        str(workspace),
        '--output',
        str(backup_path),
        '--generated-at',
        '2026-03-25T09:00:00+08:00',
    )

    assert result.returncode == 0
    assert backup_path.exists()
    with zipfile.ZipFile(backup_path) as archive:
        names = set(archive.namelist())
        assert 'manifest.json' in names
        assert 'MEMORY.md' in names
        assert 'SESSION-STATE.md' in names
        assert 'working-buffer.md' in names
        assert 'memory-capture.md' in names
        assert 'memory/2026-03-25.md' in names
        assert 'attachments/note.txt' in names
        manifest = archive.read('manifest.json').decode('utf-8')
    assert '"generated_at": "2026-03-25T09:00:00+08:00"' in manifest
    assert '"MEMORY.md"' in manifest


def test_import_restores_files_and_backs_up_existing_state(tmp_path: Path):
    source_workspace = tmp_path / 'source'
    source_memory_dir = source_workspace / 'memory'
    source_memory_dir.mkdir(parents=True)
    (source_workspace / 'MEMORY.md').write_text('# MEMORY\n\nrestored\n', encoding='utf-8')
    (source_workspace / 'SESSION-STATE.md').write_text('# SESSION\n\nrestored\n', encoding='utf-8')
    (source_workspace / 'working-buffer.md').write_text('# BUFFER\n\nrestored\n', encoding='utf-8')
    (source_memory_dir / '2026-03-25.md').write_text('# daily restored\n', encoding='utf-8')
    archive_path = tmp_path / 'memory-backup.zip'
    export_result = run_command(
        'export',
        '--workspace',
        str(source_workspace),
        '--output',
        str(archive_path),
        '--generated-at',
        '2026-03-25T09:30:00+08:00',
    )
    assert export_result.returncode == 0

    target_workspace = tmp_path / 'target'
    target_workspace.mkdir()
    (target_workspace / 'MEMORY.md').write_text('# MEMORY\n\nexisting\n', encoding='utf-8')
    (target_workspace / 'SESSION-STATE.md').write_text('# SESSION\n\nexisting\n', encoding='utf-8')

    result = run_command(
        'import',
        '--workspace',
        str(target_workspace),
        '--input',
        str(archive_path),
        '--generated-at',
        '2026-03-25T10:00:00+08:00',
    )

    assert result.returncode == 0
    assert (target_workspace / 'MEMORY.md').read_text(encoding='utf-8') == '# MEMORY\n\nrestored\n'
    assert (target_workspace / 'SESSION-STATE.md').read_text(encoding='utf-8') == '# SESSION\n\nrestored\n'
    assert (target_workspace / 'working-buffer.md').read_text(encoding='utf-8') == '# BUFFER\n\nrestored\n'
    assert (target_workspace / 'memory' / '2026-03-25.md').read_text(encoding='utf-8') == '# daily restored\n'

    backups = sorted(target_workspace.glob('memory-import-backup-*.zip'))
    assert backups
    with zipfile.ZipFile(backups[0]) as archive:
        names = set(archive.namelist())
        assert 'manifest.json' in names
        assert 'MEMORY.md' in names
        assert 'SESSION-STATE.md' in names
        assert archive.read('MEMORY.md').decode('utf-8') == '# MEMORY\n\nexisting\n'
