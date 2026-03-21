#!/usr/bin/env bash
set -euo pipefail

# classify — Text & Data Classification Tool
# Version: 1.0.0
# Powered by BytesAgain | bytesagain.com | hello@bytesagain.com

DATA_DIR="${HOME}/.classify"
DATA_FILE="${DATA_DIR}/data.jsonl"
CONFIG_FILE="${DATA_DIR}/config.json"
MODELS_DIR="${DATA_DIR}/models"
PREDICTIONS_FILE="${DATA_DIR}/predictions.jsonl"

mkdir -p "${DATA_DIR}" "${MODELS_DIR}"
touch "${DATA_FILE}" "${PREDICTIONS_FILE}"

if [ ! -f "${CONFIG_FILE}" ]; then
  echo '{"default_method": "keyword", "default_model": "default", "min_confidence": 0.3}' > "${CONFIG_FILE}"
fi

COMMAND="${1:-help}"

case "${COMMAND}" in

  train)
    python3 << 'PYEOF'
import os, sys, json, uuid, datetime

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
text = os.environ.get("CLASSIFY_TEXT", "")
label = os.environ.get("CLASSIFY_LABEL", "")
model = os.environ.get("CLASSIFY_MODEL", "default")

if not text:
    print(json.dumps({"status": "error", "message": "CLASSIFY_TEXT is required"}), file=sys.stderr)
    sys.exit(2)

if not label:
    print(json.dumps({"status": "error", "message": "CLASSIFY_LABEL is required"}), file=sys.stderr)
    sys.exit(2)

ts = datetime.datetime.utcnow().strftime("%Y%m%d_%H%M%S")
short_id = uuid.uuid4().hex[:8]
record_id = f"cls_{ts}_{short_id}"

# Tokenize text for keyword extraction
words = text.lower().split()
words = [w.strip(".,!?;:\"'()[]{}") for w in words]
words = [w for w in words if len(w) > 2]

record = {
    "id": record_id,
    "text": text,
    "label": label.lower(),
    "model": model,
    "tokens": words,
    "token_count": len(words),
    "created_at": datetime.datetime.utcnow().isoformat() + "Z"
}

with open(data_file, "a") as f:
    f.write(json.dumps(record) + "\n")

# Update model keyword index
models_dir = os.environ.get("MODELS_DIR", os.path.expanduser("~/.classify/models"))
model_file = os.path.join(models_dir, f"{model}.json")

model_data = {"labels": {}, "total_samples": 0}
if os.path.exists(model_file):
    with open(model_file, "r") as f:
        model_data = json.load(f)

label_key = label.lower()
if label_key not in model_data["labels"]:
    model_data["labels"][label_key] = {"count": 0, "keywords": {}}

model_data["labels"][label_key]["count"] += 1
model_data["total_samples"] += 1

for word in words:
    kw = model_data["labels"][label_key]["keywords"]
    kw[word] = kw.get(word, 0) + 1

with open(model_file, "w") as f:
    json.dump(model_data, f, indent=2)

print(json.dumps({
    "status": "success",
    "command": "train",
    "data": {
        "id": record_id,
        "text": text,
        "label": label_key,
        "model": model,
        "total_samples": model_data["total_samples"]
    }
}, indent=2))
PYEOF
    ;;

  predict)
    python3 << 'PYEOF'
import os, sys, json, math, datetime, uuid

models_dir = os.environ.get("MODELS_DIR", os.path.expanduser("~/.classify/models"))
predictions_file = os.environ.get("PREDICTIONS_FILE", os.path.expanduser("~/.classify/predictions.jsonl"))
text = os.environ.get("CLASSIFY_TEXT", "")
model_name = os.environ.get("CLASSIFY_MODEL", "default")
method = os.environ.get("CLASSIFY_METHOD", "keyword")

if not text:
    print(json.dumps({"status": "error", "message": "CLASSIFY_TEXT is required"}), file=sys.stderr)
    sys.exit(2)

model_file = os.path.join(models_dir, f"{model_name}.json")
if not os.path.exists(model_file):
    print(json.dumps({"status": "error", "message": f"Model not found: {model_name}"}), file=sys.stderr)
    sys.exit(3)

with open(model_file, "r") as f:
    model_data = json.load(f)

words = text.lower().split()
words = [w.strip(".,!?;:\"'()[]{}") for w in words]
words = [w for w in words if len(w) > 2]

scores = {}
total_samples = model_data.get("total_samples", 1)

for label, label_data in model_data.get("labels", {}).items():
    label_count = label_data.get("count", 0)
    keywords = label_data.get("keywords", {})

    if method == "tfidf":
        score = 0
        for word in words:
            tf = keywords.get(word, 0) / max(sum(keywords.values()), 1)
            # Simple IDF: log(total_labels / labels_containing_word)
            labels_with_word = sum(1 for l, ld in model_data["labels"].items() if word in ld.get("keywords", {}))
            idf = math.log(len(model_data["labels"]) / max(labels_with_word, 1) + 1)
            score += tf * idf
        scores[label] = score
    else:  # keyword method
        score = 0
        total_kw = max(sum(keywords.values()), 1)
        for word in words:
            if word in keywords:
                score += keywords[word] / total_kw
        # Add prior probability
        prior = label_count / total_samples
        scores[label] = score * 0.7 + prior * 0.3

if not scores:
    predicted = "unknown"
    confidence = 0
else:
    predicted = max(scores, key=scores.get)
    total_score = sum(scores.values())
    confidence = round(scores[predicted] / total_score, 3) if total_score > 0 else 0

pred_id = f"pred_{datetime.datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}"

prediction = {
    "id": pred_id,
    "text": text,
    "model": model_name,
    "method": method,
    "predicted_label": predicted,
    "confidence": confidence,
    "all_scores": {k: round(v, 4) for k, v in sorted(scores.items(), key=lambda x: -x[1])},
    "created_at": datetime.datetime.utcnow().isoformat() + "Z"
}

with open(predictions_file, "a") as f:
    f.write(json.dumps(prediction) + "\n")

print(json.dumps({"status": "success", "command": "predict", "data": prediction}, indent=2))
PYEOF
    ;;

  evaluate)
    python3 << 'PYEOF'
import os, sys, json, math

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
models_dir = os.environ.get("MODELS_DIR", os.path.expanduser("~/.classify/models"))
model_name = os.environ.get("CLASSIFY_MODEL", "default")

model_file = os.path.join(models_dir, f"{model_name}.json")
if not os.path.exists(model_file):
    print(json.dumps({"status": "error", "message": f"Model not found: {model_name}"}), file=sys.stderr)
    sys.exit(3)

with open(model_file, "r") as f:
    model_data = json.load(f)

# Load training data and do leave-one-out cross-validation
records = []
with open(data_file, "r") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        entry = json.loads(line)
        if entry.get("model") == model_name:
            records.append(entry)

if len(records) < 4:
    print(json.dumps({"status": "error", "message": "Insufficient training data (need at least 4 samples)"}), file=sys.stderr)
    sys.exit(4)

correct = 0
total = len(records)
confusion = {}

for i, test_record in enumerate(records):
    # Build model without test record
    temp_labels = {}
    for j, rec in enumerate(records):
        if i == j:
            continue
        label = rec.get("label", "")
        if label not in temp_labels:
            temp_labels[label] = {"count": 0, "keywords": {}}
        temp_labels[label]["count"] += 1
        for word in rec.get("tokens", []):
            temp_labels[label]["keywords"][word] = temp_labels[label]["keywords"].get(word, 0) + 1

    # Predict
    test_words = test_record.get("tokens", [])
    scores = {}
    for label, ld in temp_labels.items():
        score = 0
        total_kw = max(sum(ld["keywords"].values()), 1)
        for word in test_words:
            if word in ld["keywords"]:
                score += ld["keywords"][word] / total_kw
        scores[label] = score

    predicted = max(scores, key=scores.get) if scores else "unknown"
    actual = test_record.get("label", "")

    if predicted == actual:
        correct += 1

    key = f"{actual}->{predicted}"
    confusion[key] = confusion.get(key, 0) + 1

accuracy = round(correct / total * 100, 1) if total > 0 else 0

print(json.dumps({
    "status": "success",
    "command": "evaluate",
    "data": {
        "model": model_name,
        "method": "leave-one-out",
        "total_samples": total,
        "correct": correct,
        "accuracy_percent": accuracy,
        "confusion_matrix": confusion,
        "labels": list(model_data.get("labels", {}).keys())
    }
}, indent=2))
PYEOF
    ;;

  label)
    python3 << 'PYEOF'
import os, sys, json

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
record_id = os.environ.get("CLASSIFY_ID", "")
new_label = os.environ.get("CLASSIFY_LABEL", "")

if not record_id:
    print(json.dumps({"status": "error", "message": "CLASSIFY_ID is required"}), file=sys.stderr)
    sys.exit(2)

if not new_label:
    print(json.dumps({"status": "error", "message": "CLASSIFY_LABEL is required"}), file=sys.stderr)
    sys.exit(2)

records = []
found = False
with open(data_file, "r") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        entry = json.loads(line)
        if entry.get("id") == record_id:
            old_label = entry.get("label", "")
            entry["label"] = new_label.lower()
            entry["relabeled_from"] = old_label
            found = True
        records.append(entry)

if not found:
    print(json.dumps({"status": "error", "message": f"Record not found: {record_id}"}), file=sys.stderr)
    sys.exit(3)

with open(data_file, "w") as f:
    for r in records:
        f.write(json.dumps(r) + "\n")

print(json.dumps({
    "status": "success",
    "command": "label",
    "data": {"id": record_id, "new_label": new_label.lower(), "message": "Label updated. Remember to re-train the model."}
}, indent=2))
PYEOF
    ;;

  list)
    python3 << 'PYEOF'
import os, sys, json

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
model = os.environ.get("CLASSIFY_MODEL", "")
label = os.environ.get("CLASSIFY_LABEL", "").lower()

records = []
if os.path.exists(data_file):
    with open(data_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            entry = json.loads(line)
            if model and entry.get("model") != model:
                continue
            if label and entry.get("label") != label:
                continue
            records.append(entry)

print(json.dumps({
    "status": "success",
    "command": "list",
    "data": {"count": len(records), "records": records}
}, indent=2))
PYEOF
    ;;

  export)
    python3 << 'PYEOF'
import os, sys, json

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
model = os.environ.get("CLASSIFY_MODEL", "")
fmt = os.environ.get("CLASSIFY_FORMAT", "json")

records = []
if os.path.exists(data_file):
    with open(data_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            entry = json.loads(line)
            if model and entry.get("model") != model:
                continue
            records.append(entry)

if fmt == "csv":
    print("id,text,label,model,created_at")
    for r in records:
        text_safe = r.get("text", "").replace(",", ";").replace("\n", " ")
        print(f"{r.get('id','')},{text_safe},{r.get('label','')},{r.get('model','')},{r.get('created_at','')}")
else:
    print(json.dumps({
        "status": "success",
        "command": "export",
        "data": {"format": fmt, "count": len(records), "records": records}
    }, indent=2))
PYEOF
    ;;

  import)
    python3 << 'PYEOF'
import os, sys, json, uuid, datetime, csv

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
models_dir = os.environ.get("MODELS_DIR", os.path.expanduser("~/.classify/models"))
import_file = os.environ.get("CLASSIFY_FILE", "")
model = os.environ.get("CLASSIFY_MODEL", "default")

if not import_file:
    print(json.dumps({"status": "error", "message": "CLASSIFY_FILE is required"}), file=sys.stderr)
    sys.exit(2)

if not os.path.exists(import_file):
    print(json.dumps({"status": "error", "message": f"File not found: {import_file}"}), file=sys.stderr)
    sys.exit(3)

imported = 0
errors = 0

if import_file.endswith(".csv"):
    with open(import_file, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                text = row.get("text", "")
                label = row.get("label", "")
                if not text or not label:
                    errors += 1
                    continue
                words = text.lower().split()
                words = [w.strip(".,!?;:\"'()[]{}") for w in words if len(w.strip(".,!?;:\"'()[]{}")) > 2]
                record = {
                    "id": f"cls_imp_{uuid.uuid4().hex[:8]}",
                    "text": text,
                    "label": label.lower(),
                    "model": model,
                    "tokens": words,
                    "token_count": len(words),
                    "imported": True,
                    "created_at": datetime.datetime.utcnow().isoformat() + "Z"
                }
                with open(data_file, "a") as df:
                    df.write(json.dumps(record) + "\n")
                imported += 1
            except Exception:
                errors += 1
elif import_file.endswith(".jsonl") or import_file.endswith(".json"):
    with open(import_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
                if "id" not in entry:
                    entry["id"] = f"cls_imp_{uuid.uuid4().hex[:8]}"
                entry["model"] = model
                entry["imported"] = True
                with open(data_file, "a") as df:
                    df.write(json.dumps(entry) + "\n")
                imported += 1
            except json.JSONDecodeError:
                errors += 1

print(json.dumps({
    "status": "success",
    "command": "import",
    "data": {"imported": imported, "errors": errors, "source": import_file, "model": model}
}, indent=2))
PYEOF
    ;;

  stats)
    python3 << 'PYEOF'
import os, sys, json

data_file = os.environ.get("DATA_FILE", os.path.expanduser("~/.classify/data.jsonl"))
models_dir = os.environ.get("MODELS_DIR", os.path.expanduser("~/.classify/models"))
model_name = os.environ.get("CLASSIFY_MODEL", "")

records = []
if os.path.exists(data_file):
    with open(data_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            entry = json.loads(line)
            if model_name and entry.get("model") != model_name:
                continue
            records.append(entry)

by_model = {}
for r in records:
    m = r.get("model", "default")
    by_model.setdefault(m, {"count": 0, "labels": {}})
    by_model[m]["count"] += 1
    label = r.get("label", "unknown")
    by_model[m]["labels"][label] = by_model[m]["labels"].get(label, 0) + 1

# Count predictions
predictions_file = os.environ.get("PREDICTIONS_FILE", os.path.expanduser("~/.classify/predictions.jsonl"))
prediction_count = 0
if os.path.exists(predictions_file):
    with open(predictions_file, "r") as f:
        for line in f:
            if line.strip():
                prediction_count += 1

print(json.dumps({
    "status": "success",
    "command": "stats",
    "data": {
        "total_training_samples": len(records),
        "total_predictions": prediction_count,
        "models": by_model
    }
}, indent=2))
PYEOF
    ;;

  config)
    python3 << 'PYEOF'
import os, sys, json

config_file = os.environ.get("CONFIG_FILE", os.path.expanduser("~/.classify/config.json"))
key = os.environ.get("CLASSIFY_KEY", "")
value = os.environ.get("CLASSIFY_VALUE", "")

config = {}
if os.path.exists(config_file):
    with open(config_file, "r") as f:
        config = json.load(f)

if key and value:
    try:
        config[key] = json.loads(value)
    except (json.JSONDecodeError, ValueError):
        config[key] = value
    with open(config_file, "w") as f:
        json.dump(config, f, indent=2)

print(json.dumps({"status": "success", "command": "config", "data": config}, indent=2))
PYEOF
    ;;

  batch)
    python3 << 'PYEOF'
import os, sys, json, math, datetime, uuid

models_dir = os.environ.get("MODELS_DIR", os.path.expanduser("~/.classify/models"))
predictions_file = os.environ.get("PREDICTIONS_FILE", os.path.expanduser("~/.classify/predictions.jsonl"))
batch_file = os.environ.get("CLASSIFY_FILE", "")
model_name = os.environ.get("CLASSIFY_MODEL", "default")
method = os.environ.get("CLASSIFY_METHOD", "keyword")

if not batch_file:
    print(json.dumps({"status": "error", "message": "CLASSIFY_FILE is required"}), file=sys.stderr)
    sys.exit(2)

if not os.path.exists(batch_file):
    print(json.dumps({"status": "error", "message": f"File not found: {batch_file}"}), file=sys.stderr)
    sys.exit(3)

model_file = os.path.join(models_dir, f"{model_name}.json")
if not os.path.exists(model_file):
    print(json.dumps({"status": "error", "message": f"Model not found: {model_name}"}), file=sys.stderr)
    sys.exit(3)

with open(model_file, "r") as f:
    model_data = json.load(f)

with open(batch_file, "r") as f:
    texts = [line.strip() for line in f if line.strip()]

results = []
for text in texts:
    words = text.lower().split()
    words = [w.strip(".,!?;:\"'()[]{}") for w in words if len(w.strip(".,!?;:\"'()[]{}")) > 2]

    scores = {}
    total_samples = model_data.get("total_samples", 1)

    for label, label_data in model_data.get("labels", {}).items():
        label_count = label_data.get("count", 0)
        keywords = label_data.get("keywords", {})
        score = 0
        total_kw = max(sum(keywords.values()), 1)
        for word in words:
            if word in keywords:
                score += keywords[word] / total_kw
        prior = label_count / total_samples
        scores[label] = score * 0.7 + prior * 0.3

    predicted = max(scores, key=scores.get) if scores else "unknown"
    total_score = sum(scores.values())
    confidence = round(scores.get(predicted, 0) / total_score, 3) if total_score > 0 else 0

    pred_id = f"pred_{uuid.uuid4().hex[:8]}"
    prediction = {
        "id": pred_id,
        "text": text[:200],
        "predicted_label": predicted,
        "confidence": confidence
    }
    results.append(prediction)

    full_pred = {**prediction, "model": model_name, "method": method,
                 "created_at": datetime.datetime.utcnow().isoformat() + "Z"}
    with open(predictions_file, "a") as f:
        f.write(json.dumps(full_pred) + "\n")

print(json.dumps({
    "status": "success",
    "command": "batch",
    "data": {"model": model_name, "total": len(results), "predictions": results}
}, indent=2))
PYEOF
    ;;

  help)
    cat << 'HELPEOF'
classify — Text & Data Classification Tool v1.0.0

Usage: scripts/script.sh <command>

Commands:
  train     Add labeled training data (CLASSIFY_TEXT, CLASSIFY_LABEL, CLASSIFY_MODEL)
  predict   Classify new text (CLASSIFY_TEXT, CLASSIFY_MODEL)
  evaluate  Evaluate model accuracy (CLASSIFY_MODEL)
  label     Update label for record (CLASSIFY_ID, CLASSIFY_LABEL)
  list      List training data (optional CLASSIFY_MODEL, CLASSIFY_LABEL)
  export    Export data (CLASSIFY_FORMAT: json|csv)
  import    Import labeled data (CLASSIFY_FILE)
  stats     Show model statistics (optional CLASSIFY_MODEL)
  config    View/update config (CLASSIFY_KEY, CLASSIFY_VALUE)
  batch     Classify texts from file (CLASSIFY_FILE, CLASSIFY_MODEL)
  help      Show this help message
  version   Show version

Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
HELPEOF
    ;;

  version)
    echo '{"name": "classify", "version": "1.0.0", "author": "BytesAgain"}'
    ;;

  *)
    echo "Unknown command: ${COMMAND}" >&2
    echo "Run 'scripts/script.sh help' for usage." >&2
    exit 1
    ;;
esac
