---
name: classify
version: "1.0.0"
description: "Train and run text classification models using keyword-based and TF-IDF methods. Use when you need to categorize, label, or classify text data into predefined groups."
author: BytesAgain
homepage: https://bytesagain.com
source: https://github.com/bytesagain/ai-skills
tags: [classify, text, machine-learning, nlp, categorization, labeling]
---

# Classify — Text & Data Classification Tool

A text and data classification skill supporting keyword-based and TF-IDF classification methods. Train models on labeled data, predict categories for new text, evaluate accuracy, and manage labeled datasets. All data stored in JSONL format.

## Prerequisites

- `bash` (v4+)
- `python3` (v3.6+)
- No external dependencies required (uses built-in collections and math modules)

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `CLASSIFY_TEXT` | Yes* | Text to classify or label |
| `CLASSIFY_LABEL` | No | Label/category for training data |
| `CLASSIFY_MODEL` | No | Model name (default: default) |
| `CLASSIFY_METHOD` | No | Classification method: keyword, tfidf (default: keyword) |
| `CLASSIFY_ID` | No | Record ID for lookup |
| `CLASSIFY_FILE` | No | File path for import/export/batch operations |
| `CLASSIFY_FORMAT` | No | Export format: json, csv (default: json) |
| `CLASSIFY_KEY` | No | Config key to read/write |
| `CLASSIFY_VALUE` | No | Config value to set |

## Data Storage

- Training data: `~/.classify/data.jsonl`
- Models: `~/.classify/models/`
- Config: `~/.classify/config.json`
- Predictions log: `~/.classify/predictions.jsonl`

## Commands

### `train`
Add labeled training data to a model.
```bash
CLASSIFY_TEXT="Great product, love it!" CLASSIFY_LABEL="positive" CLASSIFY_MODEL="sentiment" scripts/script.sh train
```

### `predict`
Classify new text using a trained model.
```bash
CLASSIFY_TEXT="This is terrible" CLASSIFY_MODEL="sentiment" scripts/script.sh predict
```

### `evaluate`
Evaluate model accuracy with test data.
```bash
CLASSIFY_MODEL="sentiment" scripts/script.sh evaluate
```

### `label`
Add or update a label for existing data.
```bash
CLASSIFY_ID="cls_abc123" CLASSIFY_LABEL="neutral" scripts/script.sh label
```

### `list`
List training data or prediction history.
```bash
CLASSIFY_MODEL="sentiment" CLASSIFY_LABEL="positive" scripts/script.sh list
```

### `export`
Export model data or predictions.
```bash
CLASSIFY_MODEL="sentiment" CLASSIFY_FORMAT="csv" scripts/script.sh export
```

### `import`
Import labeled data from a file.
```bash
CLASSIFY_FILE="/path/to/labeled_data.csv" CLASSIFY_MODEL="sentiment" scripts/script.sh import
```

### `stats`
Show model statistics and label distribution.
```bash
CLASSIFY_MODEL="sentiment" scripts/script.sh stats
```

### `config`
View or update classification configuration.
```bash
CLASSIFY_KEY="default_method" CLASSIFY_VALUE="tfidf" scripts/script.sh config
```

### `batch`
Classify multiple texts from a file.
```bash
CLASSIFY_FILE="/path/to/texts.txt" CLASSIFY_MODEL="sentiment" scripts/script.sh batch
```

### `help`
Display usage information.
```bash
scripts/script.sh help
```

### `version`
Display current version.
```bash
scripts/script.sh version
```

## Output Format

```json
{
  "status": "success",
  "command": "predict",
  "data": {
    "text": "This product is amazing",
    "predicted_label": "positive",
    "confidence": 0.85,
    "model": "sentiment"
  }
}
```

## Error Handling

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Missing required parameter |
| 3 | Model/record not found |
| 4 | Insufficient training data |

---

Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
