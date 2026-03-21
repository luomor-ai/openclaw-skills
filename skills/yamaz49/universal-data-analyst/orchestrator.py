#!/usr/bin/env python3
"""
Orchestrator - 数据分析流程编排器

整合完整的数据分析流程：
1. 数据加载 (data_loader)
2. 本体识别 -> 调用LLM思考
3. 数据质量校验 (data_validator) - 必须执行，输出到报告
4. 方案规划 -> 调用LLM思考
5. 脚本生成 -> 调用LLM思考
6. 执行分析
7. 综合报告生成 -> 输出HTML报告 + MD报告 + 图表

特点：
- 每次判断都调用大模型，不依赖硬编码
- 支持单轮完整分析（用户信息充分时）
- 最终输出统一格式的综合报告
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional, Tuple, List
from datetime import datetime

# Setup paths
SKILL_ROOT = Path(__file__).parent
sys.path.insert(0, str(SKILL_ROOT))
sys.path.insert(0, str(SKILL_ROOT / 'layers'))

from main import UniversalDataAnalyst, DataOntology, AnalysisPlan
from llm_analyzer import LLMAnalyzer, OntologyResult, AnalysisPlan as LLMAnalysisPlan
from report_generator import ReportGenerator


class DataAnalysisOrchestrator:
    """
    数据分析流程编排器

    关键设计：
    - 每个思考步骤都生成提示词，通过 Claude 调用大模型
    - 数据质量诊断必须执行，结果整合到最终报告
    - 最终输出统一格式的HTML报告 + MD报告
    """

    def __init__(self, output_dir: str = "./analysis_output"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        # 初始化组件
        self.analyst = UniversalDataAnalyst()
        self.llm_analyzer = LLMAnalyzer()
        self.report_generator = None

        # 会话状态
        self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_dir = self.output_dir / f"session_{self.session_id}"
        self.session_dir.mkdir(exist_ok=True)

        # 初始化报告生成器
        self.report_generator = ReportGenerator(str(self.session_dir))

        # 缓存结果
        self.ontology_result: Optional[OntologyResult] = None
        self.analysis_plan: Optional[LLMAnalysisPlan] = None
        self.validation_report_dict: Optional[Dict] = None
        self.data_info: Optional[Dict] = None

    def step1_load_data(self, file_path: str, **kwargs) -> Tuple[bool, str]:
        """
        步骤1: 加载数据
        返回: (是否成功, 消息)
        """
        print("\n" + "="*80)
        print("【步骤1/7】数据加载")
        print("="*80)

        result = self.analyst.load_data(file_path, **kwargs)

        if result.success:
            msg = f"✅ 加载成功: {result.rows:,} 行 × {result.columns} 列"
            print(msg)

            # 保存数据基本信息
            self.data_info = {
                "file_path": file_path,
                "file_name": Path(file_path).name,
                "rows": result.rows,
                "columns": result.columns,
                "memory_mb": result.memory_usage_mb,
                "column_names": list(self.analyst.data.columns),
                "report_title": f"{Path(file_path).stem} 数据分析报告"
            }
            self._save_json("step1_data_info.json", self.data_info)
            return True, msg
        else:
            msg = f"❌ 加载失败: {result.errors}"
            print(msg)
            return False, msg

    def step2_identify_ontology(self) -> Tuple[str, str]:
        """
        步骤2: 识别数据本体
        返回: (提示词, 提示词文件路径)
        """
        print("\n" + "="*80)
        print("【步骤2/7】数据本体识别 - 调用大模型思考")
        print("="*80)
        print("🤔 正在生成数据本体识别提示词...")

        # 生成数据画像
        data_profile = self.analyst._generate_data_profile()

        # 生成提示词
        prompt = self.llm_analyzer.identify_ontology(data_profile)

        # 保存提示词
        prompt_file = self.session_dir / "step2_ontology_prompt.txt"
        prompt_file.write_text(prompt, encoding='utf-8')

        print(f"💾 提示词已保存: {prompt_file}")
        print("\n📋 提示词预览（前1000字符）:")
        print("-" * 80)
        print(prompt[:1000])
        print("...")

        return str(prompt), str(prompt_file)

    def step3_validate_data(self) -> Dict[str, Any]:
        """
        步骤3: 数据质量校验（必须执行）
        返回: 验证报告字典
        """
        print("\n" + "="*80)
        print("【步骤3/7】数据质量校验")
        print("="*80)

        report = self.analyst.validate_data()

        # 转换为字典
        self.validation_report_dict = report.to_dict()

        # 保存校验结果
        self._save_json("step3_validation_report.json", self.validation_report_dict)

        # 生成清洗报告
        cleaning_report = report.generate_cleaning_report()
        cleaning_file = self.session_dir / "step3_cleaning_report.txt"
        cleaning_file.write_text(cleaning_report, encoding='utf-8')

        # 显示关键信息
        print(f"\n📊 质量评分: {report.overall_score:.1f}/100")
        print(f"📋 发现问题: {len(report.issues)} 个")

        critical_count = len(report.get_issues_by_severity(report.issues[0].severity if report.issues else None))
        warning_count = sum(1 for i in report.issues if str(i.severity) == 'IssueSeverity.WARNING')

        if report.issues:
            print(f"   - Critical: {critical_count} 个")
            print(f"   - Warning: {warning_count} 个")

        summary = report.get_cleaning_summary()
        if summary.get('recommended_deletions', 0) > 0:
            print(f"🗑️  建议删除: {summary['recommended_deletions']:,} 行")
        if summary.get('recommended_fills', 0) > 0:
            print(f"📝 建议填充: {summary['recommended_fills']:,} 个缺失值")

        print(f"💾 校验报告已保存: {cleaning_file}")

        return self.validation_report_dict

    def step4_plan_analysis(self, user_intent: str) -> Tuple[str, str]:
        """
        步骤4: 规划分析方案
        返回: (提示词, 提示词文件路径)
        """
        print("\n" + "="*80)
        print("【步骤4/7】分析方案规划 - 调用大模型思考")
        print("="*80)
        print(f"📝 用户诉求: {user_intent}")

        # 需要先有本体结果，如果没有，使用占位
        if self.ontology_result is None:
            print("⚠️ 警告: 尚未进行本体识别，使用数据画像替代")
            # 创建一个基于数据画像的简化本体
            data_profile = self.analyst._generate_data_profile()
            ontology = self._create_placeholder_ontology(data_profile)
        else:
            ontology = self.ontology_result

        # 获取数据样本和字段详情
        df = self.analyst.data
        data_sample = df.head(10).to_string()

        column_details = []
        for col in df.columns:
            dtype = df[col].dtype
            unique = df[col].nunique()
            null_pct = df[col].isnull().sum() / len(df) * 100
            detail = f"{col}: {dtype}, 唯一值{unique:,}, 缺失{null_pct:.1f}%"
            if hasattr(df[col], 'min') and pd.api.types.is_numeric_dtype(df[col]):
                detail += f", 范围[{df[col].min():.2f}, {df[col].max():.2f}]"
            column_details.append(detail)

        # 生成提示词
        prompt = self.llm_analyzer.plan_analysis(
            ontology=ontology,
            user_intent=user_intent,
            data_sample=data_sample,
            column_details=column_details
        )

        # 保存提示词
        prompt_file = self.session_dir / "step4_planning_prompt.txt"
        prompt_file.write_text(prompt, encoding='utf-8')

        print(f"💾 提示词已保存: {prompt_file}")
        print("\n📋 提示词预览（前1000字符）:")
        print("-" * 80)
        print(prompt[:1000])
        print("...")

        return str(prompt), str(prompt_file)

    def step5_generate_script(self) -> Tuple[str, str]:
        """
        步骤5: 生成分析脚本
        返回: (提示词, 提示词文件路径)
        """
        print("\n" + "="*80)
        print("【步骤5/7】生成分析脚本 - 调用大模型思考")
        print("="*80)

        # 需要有分析计划
        if self.analysis_plan is None:
            print("❌ 错误: 尚未进行分析方案规划")
            return "", ""

        # 使用已识别的本体（或占位）
        ontology = self.ontology_result or self._create_placeholder_ontology(
            self.analyst._generate_data_profile()
        )

        file_path = self.analyst.load_result.file_path if self.analyst.load_result else "data.csv"

        # 生成提示词
        prompt = self.llm_analyzer.generate_script(
            analysis_plan=self.analysis_plan,
            ontology=ontology,
            file_path=file_path
        )

        # 保存提示词
        prompt_file = self.session_dir / "step5_script_prompt.txt"
        prompt_file.write_text(prompt, encoding='utf-8')

        print(f"💾 提示词已保存: {prompt_file}")

        return str(prompt), str(prompt_file)

    def step6_execute_analysis(self, script_path: Optional[str] = None) -> Dict[str, Any]:
        """
        步骤6: 执行分析脚本
        返回: 分析结果字典
        """
        print("\n" + "="*80)
        print("【步骤6/7】执行分析")
        print("="*80)

        results = {
            "status": "未执行",
            "executed": False,
            "script_output": ""
        }

        if script_path and os.path.exists(script_path):
            print(f"🚀 执行分析脚本: {script_path}")
            try:
                result = subprocess.run(
                    [sys.executable, script_path],
                    capture_output=True,
                    text=True,
                    cwd=str(self.session_dir)
                )
                print(result.stdout)
                if result.stderr:
                    print("⚠️ 警告:", result.stderr)

                results["status"] = "执行成功"
                results["executed"] = True
                results["script_output"] = result.stdout

            except Exception as e:
                print(f"❌ 执行失败: {e}")
                results["status"] = f"执行失败: {e}"
        else:
            print("ℹ️ 未提供脚本路径，跳过执行")
            results["status"] = "未提供脚本"

        # 尝试读取分析结果
        results_file = self.session_dir / "analysis_results.json"
        if results_file.exists():
            try:
                with open(results_file, 'r', encoding='utf-8') as f:
                    analysis_data = json.load(f)
                    results["data"] = analysis_data
                    print(f"📊 分析结果已读取: {results_file}")
            except Exception as e:
                print(f"⚠️ 读取分析结果失败: {e}")

        return results

    def step7_generate_comprehensive_report(self,
                                            ontology_result: Optional[Dict] = None,
                                            analysis_plan_result: Optional[Dict] = None,
                                            analysis_results: Optional[Dict] = None) -> Dict[str, str]:
        """
        步骤7: 生成综合报告（HTML + MD + 图表）

        返回: 报告文件路径字典
        """
        print("\n" + "="*80)
        print("【步骤7/7】生成综合报告")
        print("="*80)

        # 准备数据
        data_info = self.data_info or {
            "file_name": "Unknown",
            "rows": 0,
            "columns": 0,
            "report_title": "数据分析报告"
        }

        validation_report = self.validation_report_dict or {
            "overall_score": 0,
            "issues": [],
            "cleaning_summary": {}
        }

        # 使用传入的本体结果，或从文件读取，或使用占位
        ontology = ontology_result or {}
        if not ontology and (self.session_dir / "ontology_result.json").exists():
            try:
                with open(self.session_dir / "ontology_result.json", 'r', encoding='utf-8') as f:
                    ontology = json.load(f)
            except:
                pass

        if not ontology:
            ontology = {
                "entity_type": "待识别（请在步骤2调用LLM识别）",
                "entity_type_reason": "未完成本体识别",
                "generation_mechanism": "待识别",
                "mechanism_reason": "未完成本体识别",
                "core_dimensions": [],
                "is_economic": False,
                "economic_type": None,
                "domain_type": "待识别",
                "keywords": [],
                "limitations": ["未完成本体识别"]
            }

        # 使用传入的分析计划，或从文件读取，或使用占位
        plan = analysis_plan_result or {}
        if not plan and (self.session_dir / "analysis_plan.json").exists():
            try:
                with open(self.session_dir / "analysis_plan.json", 'r', encoding='utf-8') as f:
                    plan = json.load(f)
            except:
                pass

        if not plan:
            plan = {
                "question_type": "待规划",
                "question_type_reason": "未完成方案规划",
                "frameworks": [],
                "analysis_steps": [],
                "expected_outputs": [],
                "prerequisites": [],
                "risks": []
            }

        # 使用传入的分析结果，或从文件读取
        results = analysis_results or {}
        if not results and (self.session_dir / "analysis_results.json").exists():
            try:
                with open(self.session_dir / "analysis_results.json", 'r', encoding='utf-8') as f:
                    results = json.load(f)
            except:
                pass

        # 如果仍然没有结果，创建占位
        if not results:
            results = {
                "executive_summary": ["未完成分析执行"],
                "findings": [],
                "detailed_findings": {},
                "conclusions": [],
                "recommendations": [],
                "limitations": ["分析脚本未执行，无详细结果"],
                "key_metrics": {}
            }

        # 查找图表文件
        chart_files = []
        charts_dir = self.session_dir / "charts"
        if charts_dir.exists():
            chart_files = list(charts_dir.glob("*.png")) + list(charts_dir.glob("*.jpg"))
            chart_files = [str(f) for f in chart_files]

        # 生成报告
        report_paths = self.report_generator.generate_all_reports(
            data_info=data_info,
            validation_report=validation_report,
            ontology=ontology,
            analysis_plan=plan,
            analysis_results=results,
            chart_files=chart_files
        )

        print("\n📄 报告已生成:")
        print(f"  📘 HTML报告: {report_paths['html_report']}")
        print(f"  📄 Markdown报告: {report_paths['markdown_report']}")
        print(f"  🖼️  图表目录: {report_paths['charts_dir']}")

        return report_paths

    def run_full_analysis(self, file_path: str, user_intent: str) -> Dict[str, Any]:
        """
        运行完整分析流程（单轮完成）

        适用于用户信息充分的情况
        """
        print("\n" + "="*80)
        print("🚀 启动通用数据分析流程")
        print(f"📁 数据文件: {file_path}")
        print(f"🎯 分析目标: {user_intent}")
        print("="*80)

        results = {
            "session_dir": str(self.session_dir),
            "steps": {},
            "reports": {}
        }

        # 步骤1: 加载数据
        success, msg = self.step1_load_data(file_path)
        results["steps"]["load"] = {"success": success, "message": msg}
        if not success:
            return results

        # 步骤2: 本体识别（生成提示词）
        ontology_prompt, ontology_file = self.step2_identify_ontology()
        results["steps"]["ontology"] = {
            "prompt_file": ontology_file,
            "note": "请使用此提示词调用大模型进行本体识别，结果保存为 ontology_result.json"
        }

        # 步骤3: 数据校验（必须执行）
        validation_report = self.step3_validate_data()
        results["steps"]["validation"] = {
            "executed": True,
            "score": validation_report.get("overall_score", 0),
            "issues_count": len(validation_report.get("issues", []))
        }

        # 步骤4: 方案规划（生成提示词）
        planning_prompt, planning_file = self.step4_plan_analysis(user_intent)
        results["steps"]["planning"] = {
            "prompt_file": planning_file,
            "note": "请使用此提示词调用大模型进行方案规划，结果保存为 analysis_plan.json"
        }

        # 步骤5: 脚本生成（生成提示词）
        script_prompt, script_file = self.step5_generate_script()
        results["steps"]["script_generation"] = {
            "prompt_file": script_file,
            "note": "请使用此提示词调用大模型生成分析脚本，保存为 analysis_script.py"
        }

        # 步骤6: 执行分析（如果有脚本）
        analysis_results = self.step6_execute_analysis()
        results["steps"]["execution"] = analysis_results

        # 步骤7: 生成综合报告
        report_paths = self.step7_generate_comprehensive_report()
        results["reports"] = report_paths

        # 保存完整会话摘要
        summary_file = self.session_dir / "SESSION_SUMMARY.json"
        self._save_json("SESSION_SUMMARY.json", results)

        print("\n" + "="*80)
        print("✅ 数据分析流程完成")
        print("="*80)
        print(f"\n📂 所有文件保存在: {self.session_dir}")
        print("\n📋 生成的文件:")
        print(f"  1. 本体识别提示词: {ontology_file}")
        print(f"  2. 数据质量报告: {self.session_dir / 'step3_validation_report.json'}")
        print(f"  3. 方案规划提示词: {planning_file}")
        print(f"  4. 脚本生成提示词: {script_file}")
        print(f"  5. 📘 HTML报告: {report_paths['html_report']}")
        print(f"  6. 📄 Markdown报告: {report_paths['markdown_report']}")
        print(f"  7. 🖼️  图表目录: {report_paths['charts_dir']}")
        print("\n💡 使用说明:")
        print("  - 查看 HTML报告 获取完整分析结果（含图表）")
        print("  - 查看 Markdown报告 获取纯文本分析内容")
        print("  - 图表已单独保存在 charts/ 目录下")

        return results

    def _save_json(self, filename: str, data: Dict):
        """保存JSON文件"""
        filepath = self.session_dir / filename
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)

    def _create_placeholder_ontology(self, data_profile: Dict) -> OntologyResult:
        """创建占位本体结果（当尚未进行LLM识别时）"""
        return OntologyResult(
            entity_type="待识别",
            entity_type_reason="尚未调用大模型进行本体识别",
            generation_mechanism="待识别",
            mechanism_reason="尚未调用大模型进行本体识别",
            core_dimensions=[],
            is_economic=False,
            economic_type=None,
            domain_type="待识别",
            keywords=["待识别"],
            recommended_questions=["待识别"],
            limitations=["尚未进行本体识别"],
            confidence="低"
        )

    def _create_placeholder_plan(self) -> AnalysisPlan:
        """创建占位分析计划（当尚未进行LLM规划时）"""
        return AnalysisPlan(
            question_type="待规划",
            frameworks=[],
            analysis_steps=[],
            script_files=[],
            expected_outputs=["待规划"]
        )


def main():
    """命令行入口"""
    import argparse

    parser = argparse.ArgumentParser(
        description='Universal Data Analyst - 通用数据分析流程编排器'
    )
    parser.add_argument('file', help='数据文件路径')
    parser.add_argument(
        '--intent', '-i',
        default='探索性数据分析，了解数据特征和潜在模式',
        help='用户分析诉求'
    )
    parser.add_argument(
        '--output', '-o',
        default='./analysis_output',
        help='输出目录'
    )

    args = parser.parse_args()

    # 运行完整分析
    orchestrator = DataAnalysisOrchestrator(output_dir=args.output)
    results = orchestrator.run_full_analysis(
        file_path=args.file,
        user_intent=args.intent
    )

    print(f"\n✅ 分析流程完成，结果保存在: {results['session_dir']}")


if __name__ == '__main__':
    import pandas as pd
    main()
