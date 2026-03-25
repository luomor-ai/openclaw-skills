from pathlib import Path


def test_skill_mentions_memory_capture_flow():
    repo_root = Path(__file__).resolve().parents[1]
    skill_text = (repo_root / 'SKILL.md').read_text(encoding='utf-8')

    assert '任务结束 30 秒记录流程' in skill_text
    assert '候选记忆' in skill_text
    assert 'memory-capture.md' in skill_text
    assert '导出备份' in skill_text
    assert '导入恢复' in skill_text
    assert '导入前备份' in skill_text


def test_memory_capture_template_exists():
    repo_root = Path(__file__).resolve().parents[1]
    template_text = (repo_root / 'templates' / 'memory-capture.md').read_text(encoding='utf-8')

    assert '候选决策' in template_text
    assert '候选踩坑' in template_text
    assert '候选长期记忆' in template_text


def test_readmes_document_cross_device_backup_restore():
    repo_root = Path(__file__).resolve().parents[1]
    readme_text = (repo_root / 'README.md').read_text(encoding='utf-8')
    readme_cn_text = (repo_root / 'README_CN.md').read_text(encoding='utf-8')
    readme_en_text = (repo_root / 'README_EN.md').read_text(encoding='utf-8')

    assert 'export' in readme_text
    assert 'import' in readme_text
    assert '新设备' in readme_cn_text
    assert '导入前备份' in readme_cn_text
    assert 'new device' in readme_en_text
    assert 'pre-import backup' in readme_en_text


def test_skill_declares_working_buffer_as_only_short_term_scratchpad():
    repo_root = Path(__file__).resolve().parents[1]
    skill_text = (repo_root / 'SKILL.md').read_text(encoding='utf-8')

    assert '`working-buffer.md` 是唯一的短期毛坯区' in skill_text
    assert '其他 skill 如果也有 working buffer 概念，应复用这个文件' in skill_text
    assert '不要再创建第二份并行写入的 WAL / buffer 文件' in skill_text


def test_readmes_document_memory_layers_and_lookup_order():
    repo_root = Path(__file__).resolve().parents[1]
    readme_paths = ['README.md', 'README_CN.md', 'README_EN.md']

    for path in readme_paths:
        text = (repo_root / path).read_text(encoding='utf-8')
        assert 'MEMORY.md' in text
        assert 'memory/' in text

    readme_cn_text = (repo_root / 'README_CN.md').read_text(encoding='utf-8')
    assert '`MEMORY.md` 用于启动时快速参考' in readme_cn_text
    assert '`memory/` 用于每日笔记和深度归档' in readme_cn_text
    assert '检索顺序' in readme_cn_text
