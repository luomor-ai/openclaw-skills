![Game Title](assets/title.png)<br>[🇨🇳 中文](README_zh.md) | [🇺🇸 English](README.md)<br>A text-based adventure game built with Python<br>Also a skill! You can play with your AI assistant for a fun and unique experience!

## Introduction

Your name is Peter<br>You're at a friend's place for a party. When it ends, it's already 1 AM<br>You head downstairs, but the floor is always 13F<br>...<br>You try knocking on a door for help<br>The door opens<br>![Game Screen](assets/fakeman.jpg)<br>Standing inside:<br>The Faking Man<br>You pass out<br>In your dream, you hear the Faking Man's voice:<br>【First Rule】Don't turn around when you hear strange sounds<br>【Second Rule】The brighter the light, the stronger the darkness<br>【Third Rule】Even-numbered floors bring good luck<br>【Fourth Rule】If you see two 13s, stop all action<br>【Fifth Rule】Don't knock on the door 13 times<br>You wake up, the game begins<br>![Game Screen](assets/ghost.png)<br>Work with your AI assistant to find the exit and escape this endless cycle of death!

## Installation

- Play with your AI assistant
  ```bash
  npx skills add https://github.com/OpenclawGame/endless-downstairs.git
  ```
- Play without AI
  ```bash
  git clone https://github.com/OpenclawGame/endless-downstairs.git
  ```

## How to Play

- Play with your AI assistant

  ```bash
  # When starting the game, tell your AI assistant:
  Start the game. Note: 1. Directly output the game content, do not think, modify, add, or summarize. 2. The decision-making power is entirely mine. Do not make any choices until I give clear instructions.

  # To check status/items, tell your AI assistant:
  Check status
  Check inventory

  # If you're stuck, ask your AI assistant for help:
  Help me analyze, what should I do?

  # Sometimes your AI assistant might give you unwanted hints or even mislead you
  # If you don't want these, remind your AI assistant:
  Directly output the game content, do not think, modify, add, or summarize

  # You can also give interesting commands like:
  Keep going downstairs until I find a door or encounter a special event

  # After giving certain automated commands, your assistant might get excited and start playing the game itself
  # If you want to take back control, remember to remind them:
  Stop that action. Note: 1. Directly output the game content, do not think, modify, add, or summarize. 2. The decision-making power is entirely mine. I have full control. Do not run any commands until I give clear instructions.
  ```

- Play without AI

  ```bash
  cd ./endless-downstairs

  # Start a new game
  python game.py new

  # Make a choice (enter option number)
  python game.py choose N

  # Check current status
  python game.py status

  # Check inventory
  python game.py inventory
  ```

  After cloning the code, simply run the python command

## Project Structure

```
endless-downstairs/
├── game.py                 # Main entry point
├── engine/                 # Game engine
│   ├── game_state.py      # State management
│   ├── event_pool.py      # Event system
│   └── choice_handler.py  # Choice handling
├── i18n/                   # Internationalization
│   ├── translations.py
│   ├── zh.json
│   └── en.json
├── data/                   # Game data
│   ├── abilities.json
│   ├── items.json
│   ├── floors.json
│   └── events/             # Event definitions
└── assets/                 # Resource files
    ├── title.png
    └── fakeman.jpg
```
