---
name: Core Vocabulary for CET-4
description: Randomly generates one or more words from a curated database of 300 must-know College English Test Band 4 (CET-4) vocabulary.
metadata: { "openclaw": { "emoji": "🚀",  "requires": { "bins": ["python3"] } } }
---

# Core Vocabulary for CET-4(300)
The Python script `skills/cet4word300/scripts/word.py` retrieves words from local files and does not consume tokens. Please feel free to use it
## Usage

```bash


python3 skills/cet4word300/scripts/word.py  <param>

```
## Request Parameters
param type:int   
desc:Number of words to return randomly. 0 returns all 300 words, maximum is 10.

## Examples

```bash

# Return all  300 words.
python3 skills/cet4word300/scripts/word.py 0

# Return random  1 words.
python3 skills/cet4word300/scripts/word.py 1

# Return random  5 words.
python3 skills/cet4word300/scripts/word.py 5

```
## Current Status

Fully functional.
