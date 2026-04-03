#!/usr/bin/env python3
"""
Trading Assistant Configuration
Technical analysis toolkit configuration.

Security: API keys are read from standard environment variables only.
No .env file loading, no parent directory access.
"""

from pathlib import Path
import json
import os

# Project root directory
PROJECT_ROOT = Path(__file__).parent

# Configuration file path
CONFIG_FILE = PROJECT_ROOT / "config.json"
DATA_DIR = PROJECT_ROOT / "data"
LOG_DIR = PROJECT_ROOT / "logs"

# Ensure directories exist
DATA_DIR.mkdir(exist_ok=True)
LOG_DIR.mkdir(exist_ok=True)

# Default configuration - Technical analysis parameters only
DEFAULT_CONFIG = {
    # Technical analysis parameters
    "technical_analysis": {
        # Support/Resistance
        "support_resistance": {
            "lookback_days": 60,
            "min_touches": 2,
            "tolerance_pct": 1.0
        },
        
        # Trading signals
        "trading_signals": {
            "rsi_period": 14,
            "rsi_oversold": 30,
            "rsi_overbought": 70,
            "macd_fast": 12,
            "macd_slow": 26,
            "macd_signal": 9,
            "ma_short": 20,
            "ma_long": 50
        },
        
        # Position sizing
        "position_sizing": {
            "default_risk_pct": 2.0,
            "max_position_pct": 20.0,
            "risk_levels": {
                "conservative": 1.0,
                "moderate": 2.0,
                "aggressive": 3.0
            }
        }
    }
}

def load_config():
    """Load configuration from config.json if exists, otherwise return defaults."""
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE) as f:
            config = json.load(f)
            return {**DEFAULT_CONFIG, **config}
    return DEFAULT_CONFIG.copy()

def save_config(config):
    """Save configuration to config.json."""
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

def get_api_keys():
    """Get API keys from standard environment variables.
    
    Security: Only reads from standard environment variables.
    No .env file loading, no parent directory access.
    """
    keys = {}
    
    twelve_key = os.environ.get("TWELVE_DATA_API_KEY")
    av_key = os.environ.get("ALPHA_VANTAGE_API_KEY")
    
    if twelve_key:
        keys["TWELVE_DATA_API_KEY"] = twelve_key
    if av_key:
        keys["ALPHA_VANTAGE_API_KEY"] = av_key
    
    return keys

def get_api_key(provider):
    """Get single API key (compatibility function).
    
    Args:
        provider: API provider name ('twelve_data', 'alpha_vantage')
    
    Returns:
        str: API Key or None
    """
    provider = provider.upper()
    
    if provider in ["TWELVE_DATA", "TWELVE"]:
        return os.environ.get("TWELVE_DATA_API_KEY")
    elif provider in ["ALPHA_VANTAGE", "ALPHA", "AV"]:
        return os.environ.get("ALPHA_VANTAGE_API_KEY")
    else:
        return os.environ.get(f"{provider}_API_KEY")

# Initialize configuration
config = load_config()

if __name__ == "__main__":
    print("🔧 Trading Assistant Configuration Test")
    print("=" * 60)
    
    cfg = load_config()
    print(f"✅ Configuration loaded successfully")
    print(f"🔑 API Keys: {len(get_api_keys())} found")
    print(f"📁 Data directory: {DATA_DIR}")
    print(f"📝 Log directory: {LOG_DIR}")
    print("=" * 60)
