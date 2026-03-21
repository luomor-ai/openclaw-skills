---
name: vector
version: "1.0.0"
description: "Perform vector math and similarity operations using CLI tools. Use when you need dot products, cosine similarity, distance metrics, normalization,"
author: BytesAgain
homepage: https://bytesagain.com
source: https://github.com/bytesagain/ai-skills
tags:
  - vector
  - math
  - similarity
  - search
  - embeddings
---

# Vector — Vector Operations and Similarity Tool

A thorough CLI tool for vector mathematics and similarity computations. Supports vector creation, dot product, cosine similarity, Euclidean/Manhattan distance, normalization, nearest-neighbor search, batch operations, and import/export — all stored locally in JSONL format for embedding management and analysis.

## Prerequisites

- Python 3.8+
- Bash shell

## Data Storage

All vector data is persisted in `~/.vector/data.jsonl`. Each line is a JSON object representing a named vector with its components, metadata, and tags. This enables local vector store functionality similar to embedding databases.

## Commands

Run all commands via the script at `scripts/script.sh`.

### `create`
Create a new named vector collection/namespace.
```bash
bash scripts/script.sh create <collection_name> [--dimensions 128]
```

### `add`
Add a vector to a collection.
```bash
bash scripts/script.sh add <collection_name> <vector_name> --values "0.1,0.5,0.3,..." [--metadata '{"label":"cat"}'] [--tag image]
```

### `dot`
Compute the dot product of two vectors.
```bash
bash scripts/script.sh dot <collection_name> <vector_a> <vector_b>
```

### `cosine`
Compute cosine similarity between two vectors.
```bash
bash scripts/script.sh cosine <collection_name> <vector_a> <vector_b>
```

### `distance`
Compute distance between two vectors (Euclidean, Manhattan, or Chebyshev).
```bash
bash scripts/script.sh distance <collection_name> <vector_a> <vector_b> [--metric euclidean|manhattan|chebyshev]
```

### `normalize`
Normalize a vector to unit length (L2 norm).
```bash
bash scripts/script.sh normalize <collection_name> <vector_name> [--in-place] [--name normalized_copy]
```

### `search`
Find the k nearest neighbors to a query vector.
```bash
bash scripts/script.sh search <collection_name> --query <vector_name> [--k 5] [--metric cosine|euclidean] [--tag filter_tag]
bash scripts/script.sh search <collection_name> --values "0.1,0.5,0.3,..." [--k 5]
```

### `batch`
Perform batch operations (add multiple vectors, compute pairwise similarities).
```bash
bash scripts/script.sh batch add <collection_name> --file vectors.json
bash scripts/script.sh batch similarity <collection_name> [--metric cosine] [--top 10]
```

### `export`
Export vectors to JSON or CSV format.
```bash
bash scripts/script.sh export <collection_name> [--format json|csv] [--output vectors.json] [--tag filter_tag]
```

### `import`
Import vectors from a JSON or CSV file.
```bash
bash scripts/script.sh import <collection_name> <file_path> [--format json|csv]
```

### `help`
Show usage information and available commands.
```bash
bash scripts/script.sh help
```

### `version`
Show the current version of the vector tool.
```bash
bash scripts/script.sh version
```

## Workflow Example

```bash
# Create a collection
bash scripts/script.sh create embeddings --dimensions 4

# Add vectors
bash scripts/script.sh add embeddings cat --values "0.9,0.1,0.2,0.8" --tag animal
bash scripts/script.sh add embeddings dog --values "0.8,0.2,0.3,0.7" --tag animal
bash scripts/script.sh add embeddings car --values "0.1,0.9,0.8,0.2" --tag vehicle

# Compute similarity
bash scripts/script.sh cosine embeddings cat dog
bash scripts/script.sh distance embeddings cat car --metric euclidean

# Search nearest neighbors
bash scripts/script.sh search embeddings --query cat --k 2 --metric cosine

# Normalize
bash scripts/script.sh normalize embeddings cat --name cat_normalized

# Export
bash scripts/script.sh export embeddings --format json --output my-vectors.json
```

## Supported Metrics

- **Cosine Similarity**: Measures angle between vectors (range: -1 to 1)
- **Euclidean Distance**: L2 distance (straight line)
- **Manhattan Distance**: L1 distance (city block)
- **Chebyshev Distance**: L∞ distance (maximum coordinate difference)
- **Dot Product**: Inner product of two vectors

## Notes

- Acts as a lightweight local vector store — no external database needed.
- Suitable for managing embeddings from ML models.
- Batch operations enable efficient bulk processing.
- Search uses brute-force k-NN (suitable for collections up to ~100K vectors).

---

Powered by BytesAgain | bytesagain.com | hello@bytesagain.com
