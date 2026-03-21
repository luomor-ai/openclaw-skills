"""
数据加载器

支持多种数据格式的加载：
- CSV/TSV
- Excel (.xlsx/.xls)
- Parquet
- JSON
- SQL 数据库
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import Dict, Any, Optional, Union, List
from dataclasses import dataclass, field
from enum import Enum
import logging
import time

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DataFormat(Enum):
    """支持的数据格式"""
    CSV = "csv"
    TSV = "tsv"
    EXCEL = "excel"
    PARQUET = "parquet"
    JSON = "json"
    SQL = "sql"
    UNKNOWN = "unknown"


@dataclass
class DataLoadResult:
    """数据加载结果"""
    success: bool
    data: Optional[pd.DataFrame] = None
    format: DataFormat = DataFormat.UNKNOWN
    file_path: Optional[str] = None
    rows: int = 0
    columns: int = 0
    memory_usage_mb: float = 0.0
    load_time_ms: float = 0.0
    warnings: List[str] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)
    encoding: str = "utf-8"

    def to_dict(self) -> Dict[str, Any]:
        return {
            'success': self.success,
            'format': self.format.value,
            'file_path': self.file_path,
            'rows': self.rows,
            'columns': self.columns,
            'memory_usage_mb': round(self.memory_usage_mb, 2),
            'load_time_ms': round(self.load_time_ms, 2),
            'warnings': self.warnings,
            'errors': self.errors,
        }


class DataLoader:
    """
    数据加载器

    支持自动格式检测和多种数据源
    """

    tool_name = "data_loader"
    tool_description = "加载各种格式的数据文件"

    # 格式映射
    EXTENSION_MAP = {
        '.csv': DataFormat.CSV,
        '.tsv': DataFormat.TSV,
        '.txt': DataFormat.CSV,
        '.xlsx': DataFormat.EXCEL,
        '.xls': DataFormat.EXCEL,
        '.parquet': DataFormat.PARQUET,
        '.pq': DataFormat.PARQUET,
        '.json': DataFormat.JSON,
    }

    def __init__(self):
        self._load_stats = []

    def detect_format(self, file_path: Union[str, Path]) -> DataFormat:
        """检测文件格式"""
        path = Path(file_path)
        ext = path.suffix.lower()

        # 检查扩展名
        if ext in self.EXTENSION_MAP:
            return self.EXTENSION_MAP[ext]

        # 尝试读取前几个字节判断
        try:
            with open(path, 'rb') as f:
                header = f.read(8)
                # Parquet 文件以 PAR1 开头
                if header[:4] == b'PAR1':
                    return DataFormat.PARQUET
        except:
            pass

        return DataFormat.UNKNOWN

    def execute(self, params: Dict[str, Any]) -> DataLoadResult:
        """
        执行数据加载

        Args:
            params: {
                'file_path': str,  # 文件路径
                'format': str,     # 可选，强制指定格式
                'encoding': str,   # 可选，默认utf-8
                'sheet_name': str, # Excel专用
                'sql_query': str,  # SQL专用
                'connection_string': str, # SQL专用
                'limit': int,      # 限制加载行数
                'parse_dates': list, # 日期列
                'dtype': dict,     # 指定数据类型
            }
        """
        start_time = time.time()

        file_path = params.get('file_path')
        if not file_path:
            return DataLoadResult(
                success=False,
                errors=["缺少 file_path 参数"]
            )

        # 检测或获取格式
        format_hint = params.get('format')
        if format_hint:
            data_format = DataFormat(format_hint.lower())
        else:
            data_format = self.detect_format(file_path)

        if data_format == DataFormat.UNKNOWN:
            return DataLoadResult(
                success=False,
                file_path=str(file_path),
                errors=[f"无法识别文件格式: {file_path}"]
            )

        # 根据格式加载
        try:
            result = self._load_by_format(
                file_path=file_path,
                data_format=data_format,
                params=params
            )
        except Exception as e:
            load_time = (time.time() - start_time) * 1000
            return DataLoadResult(
                success=False,
                file_path=str(file_path),
                format=data_format,
                load_time_ms=load_time,
                errors=[f"加载失败: {str(e)}"]
            )

        result.load_time_ms = (time.time() - start_time) * 1000
        return result

    def _load_by_format(self, file_path: str, data_format: DataFormat,
                        params: Dict[str, Any]) -> DataLoadResult:
        """根据格式加载数据"""

        encoding = params.get('encoding', 'utf-8')
        limit = params.get('limit')
        parse_dates = params.get('parse_dates', [])
        dtype = params.get('dtype')

        result = DataLoadResult(
            success=True,
            file_path=str(file_path),
            format=data_format,
            encoding=encoding
        )

        if data_format == DataFormat.CSV:
            df = pd.read_csv(
                file_path,
                encoding=encoding,
                parse_dates=parse_dates,
                dtype=dtype,
                low_memory=False
            )

        elif data_format == DataFormat.TSV:
            df = pd.read_csv(
                file_path,
                sep='\t',
                encoding=encoding,
                parse_dates=parse_dates,
                dtype=dtype,
                low_memory=False
            )

        elif data_format == DataFormat.EXCEL:
            sheet_name = params.get('sheet_name', 0)
            df = pd.read_excel(
                file_path,
                sheet_name=sheet_name,
                parse_dates=parse_dates,
                dtype=dtype
            )

        elif data_format == DataFormat.PARQUET:
            df = pd.read_parquet(file_path)

        elif data_format == DataFormat.JSON:
            df = pd.read_json(file_path)

        elif data_format == DataFormat.SQL:
            connection_string = params.get('connection_string')
            sql_query = params.get('sql_query')

            if not connection_string or not sql_query:
                result.success = False
                result.errors.append("SQL加载需要 connection_string 和 sql_query")
                return result

            from sqlalchemy import create_engine
            engine = create_engine(connection_string)
            df = pd.read_sql(sql_query, engine, parse_dates=parse_dates)

        else:
            result.success = False
            result.errors.append(f"不支持的格式: {data_format}")
            return result

        # 限制行数
        if limit and len(df) > limit:
            result.warnings.append(f"数据行数超过限制 {limit}，已截断")
            df = df.head(limit)

        # 填充结果
        result.data = df
        result.rows = len(df)
        result.columns = len(df.columns)
        result.memory_usage_mb = df.memory_usage(deep=True).sum() / 1024 / 1024

        # 记录统计
        self._load_stats.append(result.to_dict())

        logger.info(f"加载成功: {result.rows} 行 × {result.columns} 列, "
                   f"{result.memory_usage_mb:.2f} MB")

        return result

    def load_csv(self, file_path: str, **kwargs) -> DataLoadResult:
        """便捷加载 CSV"""
        params = {'file_path': file_path, 'format': 'csv'}
        params.update(kwargs)
        return self.execute(params)

    def load_excel(self, file_path: str, sheet_name=0, **kwargs) -> DataLoadResult:
        """便捷加载 Excel"""
        params = {
            'file_path': file_path,
            'format': 'excel',
            'sheet_name': sheet_name
        }
        params.update(kwargs)
        return self.execute(params)

    def load_parquet(self, file_path: str, **kwargs) -> DataLoadResult:
        """便捷加载 Parquet"""
        params = {'file_path': file_path, 'format': 'parquet'}
        params.update(kwargs)
        return self.execute(params)

    def load_sql(self, connection_string: str, sql_query: str,
                 **kwargs) -> DataLoadResult:
        """便捷加载 SQL"""
        params = {
            'file_path': 'sql_query',
            'format': 'sql',
            'connection_string': connection_string,
            'sql_query': sql_query
        }
        params.update(kwargs)
        return self.execute(params)

    def get_load_stats(self) -> List[Dict]:
        """获取加载统计"""
        return self._load_stats.copy()


# 全局实例
loader = DataLoader()

# 便捷函数
def load(file_path: str, **kwargs) -> DataLoadResult:
    """便捷加载函数"""
    params = {'file_path': file_path}
    params.update(kwargs)
    return loader.execute(params)
