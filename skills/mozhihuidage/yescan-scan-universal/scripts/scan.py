#!/usr/bin/env python3
"""
Quark OCR - 夸克扫描王 OCR 识别服务（保存图片到 imgs 目录）
支持通过 --scene 参数指定场景，自动获取对应配置
"""
import sys
import argparse
from pathlib import Path

# 导入公共模块 - 同级目录（发布版本）
SCRIPTS_DIR = Path(__file__).parent
sys.path.insert(0, str(SCRIPTS_DIR))

from common import (
    OCRResult,
    CredentialManager,
    QuarkOCRClient,
    FileSaver,
    get_scene_config,
    list_scenes,
)


def save_image_from_result(result: OCRResult) -> OCRResult:
    """从 OCR 结果中提取并保存图片"""
    image_base64 = None
    if isinstance(result.data, dict) and "ImageInfo" in result.data:
        image_info_list = result.data["ImageInfo"]
        if isinstance(image_info_list, list) and len(image_info_list) > 0:
            image_info = image_info_list[0]
            if isinstance(image_info, dict) and "ImageBase64" in image_info:
                image_base64 = image_info["ImageBase64"]

    if image_base64 and result.code == "00000":
        try:
            saver = FileSaver()
            save_res = saver.save_image_from_base64(image_base64)
            if save_res["code"] == 0:
                result.data = {"path": save_res["data"]["path"]}
            else:
                result = OCRResult(code=save_res["code"], message=save_res["msg"], data=save_res["data"])
        except (IOError, OSError) as e:
            result = OCRResult(code="FILE_SAVE_ERROR", message=f"File save failed: {e}", data={})

    return result


def main():
    """主函数 - 调用 API 并保存图片"""
    parser = argparse.ArgumentParser(
        description="Quark OCR - 支持图片 URL、本地路径、BASE64 字符串",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
可用场景（--scene 参数值）:
  {', '.join(list_scenes())}

示例:
  # 通用 OCR
  python3 scripts/scan.py --scene general-ocr --url "https://example.com/image.jpg"
  
  # 身份证识别
  python3 scripts/scan.py --scene idcard-ocr --path "/path/to/idcard.jpg"
  
  # 试卷增强
  python3 scripts/scan.py --scene exam-enhance --base64 "iVBORw0KGgo..."
        """
    )
    
    # 场景参数（必填）
    parser.add_argument("--scene", "-s", required=True, help="场景名称（如 general-ocr, idcard-ocr 等）")
    
    # 输入源参数（三选一，必填）
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--url", "-u", help="图片 URL")
    group.add_argument("--path", "-p", help="本地图片文件路径")
    group.add_argument("--base64", "-b", help="BASE64 字符串")
    
    args = parser.parse_args()
    
    # 获取场景配置
    try:
        config = get_scene_config(args.scene)
    except ValueError as e:
        print(OCRResult(code="INVALID_SCENE", message=str(e), data=None).to_json())
        sys.exit(1)
    
    try:
        api_key = CredentialManager.load()
        with QuarkOCRClient(
            api_key=api_key,
            service_option=config["service_option"],
            input_configs=config["input_configs"],
            output_configs=config["output_configs"],
            data_type=config["data_type"]
        ) as client:
            if args.base64:
                result = client.recognize(base64_data=args.base64)
            elif args.url:
                result = client.recognize(image_url=args.url)
            else:
                result = client.recognize(image_path=args.path)
        
        result = save_image_from_result(result)
        print(result.to_json())
        
    except ValueError as e:
        print(OCRResult(code="A0100", message=str(e), data=None).to_json())
        sys.exit(1)
    except Exception as e:
        print(OCRResult(code="UNKNOWN_ERROR", message=f"Unexpected error: {str(e)}", data=None).to_json())
        sys.exit(1)


if __name__ == "__main__":
    main()
