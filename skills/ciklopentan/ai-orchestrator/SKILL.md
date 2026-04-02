---
name: ai-orchestrator
description: CLI wrapper for DeepSeek chat sessions with reusable context and long-running conversations. Use when you need a simple DeepSeek session helper.
---

# AI Orchestrator — Полный мануал оператора

**Для кого:** для ИИ-агентов и операторов, которым нужен простой CLI для DeepSeek-сессий.  
**Статус:** Production-ready, v3.3.1 (2026-04-02). Обновлено описание для ClawHub.

---

## 1. Назначение навыка

Навык обеспечивает надёжный, production-ready доступ к DeepSeek AI через браузерную автоматизацию (Puppeteer) с:
- CDP-перехватчиком API для получения полных ответов (без ожидания DOM)
- Persistent демоном (PM2) для моментального подключения (холодный старт ~5-8 сек)
- Health check и auto-restart каждые 5 минут
- Graceful shutdown (SIGTERM/SIGINT)
- Session persistence (`--session`) для контекста
- Fallback DOM extraction (если CDP недоступен)
- Rate limiting (10 сек между запросами)

**Важно:** DeepSeek free tier ограничивает длину ответа **~27 000 символов** на один запрос. Приближение к лимиту активирует кнопку "Продолжить" (Continue generating), которую можно нажимать до 10-12 раз, набирая в total до ~27k символов. Для ещё более длинного контента используйте несколько запросов через `--session`.

**Использование:** `ask-deepseek.sh "вопрос" [--session имя] [--daemon] [--timeout секунды]`

---

## 2. Быстрый старт

### Простой запрос (однократный)
```bash
~/.openclaw/workspace/skills/ai-orchestrator/ask-deepseek.sh "Твой вопрос?"
```

### Сохраняемая сессия (сохраняет контекст)
```bash
ask-deepseek.sh "Вопрос 1" --session work
ask-deepseek.sh "Вопрос 2" --session work  # продолжает тот же чат
ask-deepseek.sh --session work --end-session
```

### Явное использование демона
```bash
ask-deepseek.sh "Вопрос" --daemon
```
Гарантирует подключение к демону (ошибка, если демон не запущен).

---

## 3. Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                 ask-deepseek.sh (wrapper)                  │
│  Парсит аргументы, добавляет дату к промпту, вызывает      │
│  ask-puppeteer.js                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                ask-puppeteer.js (ядро)                     │
│  ├─ ensureBrowser() — выбор браузера (демон → сессия → new)│
│  ├─ CDP DeepSeek Interceptor — перехват Network API       │
│  ├─ Fallback DOM extraction (если CDP не дал ответ)       │
│  ├─ Session manager (сохраняет .sessions/*.json)          │
│  ├─ Graceful shutdown (SIGTERM/SIGINT → browser.close())  │
│  └─ Логирование в stdout                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                deepseek-daemon.js (PM2)                   │
│  ├─ Запускает Chrome (headless, userDataDir=.profile/)    │
│  ├─ Переходит на https://chat.deepseek.com/              │
│  ├─ Пишет .daemon-ws-endpoint (wsEndpoint)               │
│  ├─ Auto-reload страницы при error                        │
│  ├─ Graceful shutdown (удаляет endpoint, закрывает браузер)│
│  └─ Перезапускается при падении (PM2)                     │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│              daemon-healthcheck.js (PM2 cron */5)         │
│  ├─ Читает .daemon-ws-endpoint                            │
│  ├─ puppeteer.connect() с таймаутом 10 сек               │
│  ├─ Если FAIL → pm2 restart deepseek-daemon               │
│  └─ Логи в stdout                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Ключевые файлы и их роль

| Файл | Назначение |
|------|------------|
| `ask-deepseek.sh` | CLI wrapper для пользователя. Парсит флаги (`--session`, `--daemon`, `--close`, `--end-session`), добавляет временную метку к промпту, вызывает `ask-puppeteer.js`. |
| `ask-puppeteer.js` | Основной движок. Управляет браузером, CDP-перехватчиком, fallback, сессиями, graceful shutdown. |
| `deepseek-daemon.js` | Демон для PM2. Запускает persistent Chrome, сохраняет wsEndpoint, перезагружает страницу при краше. |
| `daemon-healthcheck.js` | Health check (cron каждые 5 мин). Подключается к демону, перезапускает при ошибке. |
| `SKILL.md` | Документация (этот файл). |
| `package.json` | Зависимости (puppeteer). |
| `.daemon-ws-endpoint` | Файл с wsEndpoint демона (генерируется автоматически). |
| `.sessions/*.json` | Сессии: `{ wsEndpoint, chatUrl, messageCount }`. Позволяют переподключаться к тому же чату. |
| `.profile/` | Chrome user data dir (cookies, localStorage). **Не копировать в бэкап** (можно восстановить через login). |
| `node_modules/` | NPM зависимости. **Не копировать в бэкап** (восстанавливаются через `npm ci`). |
| `working-selectors.json` | Кэш успешных CSS-селекторов для fallback. |
| `rate-limit.json` | Rate limiting (если используется). |

---

## 5. Управление демоном и health check

### Старт/стоп/статус (PM2)
```bash
pm2 start deepseek-daemon
pm2 stop deepseek-daemon
pm2 restart deepseek-daemon
pm2 status
pm2 logs deepseek-daemon      # tail логов демона
pm2 logs daemon-healthcheck   # tail health check
```

### Health check
Запускается автоматически через PM2 cron `*/5 * * * *`. Проверяет доступность демона каждые 5 минут.

### Автозапуск PM2 при старте системы
```bash
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp $HOME
pm2 save
```

---

## 6. Логирование и мониторинг

### PM2 логи
- `pm2 logs deepseek-daemon` —实时 логи демона
- `pm2 logs daemon-healthcheck` — логи health check
- `pm2 logs` — все логи

### Ротация логов (pm2-logrotate)
Установлен модуль pm2-logrotate:
- max_size: 50M
- retain: 5
- compress: true

Логи хранятся в `~/.pm2/logs/`.

### Чистка логов вручную
```bash
pm2 flush                    # все логи
pm2 flush deepseek-daemon    # только демон
```

---

## 7. Перезапуск и обслуживание

### Перезапуск компонентов
```bash
pm2 restart deepseek-daemon           # демон
pm2 restart daemon-healthcheck        # health check
pm2 restart deepseek-daemon daemon-healthcheck  # оба
```

⚠️ **Важно:** Всегда используйте абсолютные пути при запуске скриптов через PM2, чтобы избежать проблем с `cwd` и `MODULE_NOT_FOUND`:
```bash
pm2 start /home/irtual/.openclaw/workspace/skills/ai-orchestrator/deepseek-daemon.js --name deepseek-daemon --no-autorestart
```
Если перемещали папку навыка, нужно удалить старый процесс (`pm2 delete deepseek-daemon`) и пересоздать с правильным путём.

### Graceful shutdown
Сигналы `SIGINT`, `SIGTERM`, `SIGHUP` перехватываются ask-puppeteer.js и deepseek-daemon.js → корректное закрытие браузера.

---

## 8. Безопасное обслуживание

### Перед изменениями
1. Убедиться, что нет активных сессий: `pm2 stop deepseek-daemon` (демон перестанет отвечать на новые запросы)
2. Сделать бэкап: `tar -czf ~/ai-orchestrator-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C ~/.openclaw/workspace/skills ai-orchestrator --exclude=node_modules --exclude=.profile`

### После изменений
1. Проверить синтаксис: `node -c ask-puppeteer.js`
2. Перезапустить: `pm2 restart deepseek-daemon`
3. Проверить статус: `pm2 status`
4. Запустить тестовый запрос: `ask-deepseek.sh "test" --session test`

---

## 9. Создание чистого бэкапа

### Чистый бэкап (production)
```bash
cd ~/.openclaw/workspace/skills
tar --exclude='ai-orchestrator/node_modules' \
    --exclude='ai-orchestrator/.profile' \
    -czf ~/ai-orchestrator-final-$(date +%Y%m%d-%H%M%S).tar.gz \
    ai-orchestrator
```

### Что включать в бэкап
- Все файлы кроме `node_modules/` и `.profile/`
- Сессии (`.sessions/`) — опционально, можно исключить для чистоты
- `.daemon-ws-endpoint` — **нельзя**, он должен генерироваться заново при старте демона
- `SKILL.md`, скрипты, конфиги

### Восстановление из бэкапа
```bash
tar -xzf ~/ai-orchestrator-final-*.tar.gz -C ~/.openclaw/workspace/skills
pm2 restart deepseek-daemon
```

---

## 10. Важные данные и временные файлы

### Важные (не удалять)
- `ask-puppeteer.js`, `deepseek-daemon.js`, `daemon-healthcheck.js`
- `SKILL.md`, `package.json`, `package-lock.json`
- `.daemon-ws-endpoint` (если есть) — endpoint демона
- `.sessions/*.json` (если нужны сохрание сессии)
- `working-selectors.json` (кэш селекторов fallback)
- `rate-limit.json` (если используется)

### Временные (можно удалять)
- `ds-*.html`, `ds-*.png` — отладочные скриншоты/страницы
- `deepseek-err-*.html` — ошибки
- `*.bak`, `*.bak-*` — бэкапы скриптов
- Логи PM2 (`~/.pm2/logs/`) — ротируются автоматически

### Исключить из бэкапа (раздувают размер)
- `node_modules/` — восстанавливается через `npm ci`
- `.profile/` — пересоздаётся при первом запуске Chrome, содержит cookies (можно login заново)

---

## 11. Бенчмарки производительности (2026-03-31, актуальные)

Проведены тесты на DeepSeek free tier с актуальным кодом (v3.3, fallback через Enter):

| Тест | Запрос | Размер ответа | Время (wall-clock) | Продолжений | Статус |
|------|--------|---------------|-------------------|-------------|--------|
| **SHORT** | "2+2?" | **166 символов** (полный ответ) | **~10 сек** | 0 | ✅ |
| **MEDIUM** | "Что такое HTTP/HTTPS" | **27,500 символов** | **~40 сек** | 12 | ✅ |
| **LONG** | "Микросервисы (15k+)" | **18,742 символа** | **~600 сек** | fallback | ⚠️ Достигнут лимит DeepSeek |
| **LONG visible** | "Микросервисы (видимый браузер)" | **18,742 символа** | **~600 сек** | fallback | ✅ Fallback сработал |

**Ключевые цифры:**
- **Overhead (демон уже online):** 30-40 сек (первый ответ)
- **Polling interval:** 500 ms
- **Idle timeout:** 15 сек без изменений текста → завершение
- **Max continue rounds:** 30
- **Fallback:** при отсутствии кнопки "Continue" для ответов 2k–6k символов — автоматически отправляет "Продолжи" через **Enter**

**Выводы:**
1. Оптимизации (polling 500ms, idle 15s) работают стабильно.
2. **Free tier лимиты (зависит от сложности):**
   - Простые запросы: 100-1000 символов
   - Средние: до 10k
   - Сложные/технические: **18k–27k** (проверено)
   - Рекорд: **27,500 символов** (запрос "HTTP/HTTPS", 12 продолжений)
3. **Fallback работает:** если кнопка не найдена, система вводит "Продолжи" и жмёт Enter.
4. DeepSeek может **проигнорировать** "Продолжи", если достигнут его внутренний лимит (видно по `Fallback: новый текст не появился`).
5. **Для >30k символов:** используйте несколько запросов в одной сессии (`--session guide`) или DeepSeek Pro.

---

## 12. Типичные неисправности и решения

### A. КРИТИЧЕСКОЕ: Ошибка таймаута селекторов (слетела авторизация / CAPTCHA)

**Симптомы:**
- `Timeout waiting for composer element`
- `No element found for selector: textarea` (бесконечные попытки)
- Браузер в демоне headless показывает страницу с CAPTCHA

**Причина:**
- Сессия DeepSeek истекла, требуется повторный логин
- Или Cloudflare/анти-бот проверка (CAPTCHA)

**СТРОЖАЙШИЙ ЗАПРЕТ:** Не пытайся обойти кодом (не добавляй селекторы, не меняй таймауты).

**Решение:**
1. Остановить демон: `pm2 stop deepseek-daemon`
2. Запустить браузер в видимом режиме с тем же профилем:
   ```bash
   ~/.cache/puppeteer/chrome/linux-146.0.7680.153/chrome-linux64/chrome \
     --user-data-dir=~/.openclaw/workspace/skills/ai-orchestrator/.profile \
     --no-sandbox https://chat.deepseek.com/
   ```
3. Вручную залогиниться (логин/пароль или SSO)
4. Пройти CAPTCHA, если появится
5. Убедиться, что чат загружен
6. Закрыть браузер
7. Запустить демон: `pm2 start deepseek-daemon`
8. Протестировать: `ask-deepseek.sh "test" --session auth-test`

**Профилактика:** Раз в 3-6 месяцев проверяйте сессию. Не используйте демон в публичных средах без контроля.

---

### B. DeepSeek не отвечает (бесконечное ожидание)

**Симптомы:**
- "⏳ Жду ответ..." и зависание
- Через 300 сек fallback, ответ пустой или обрывочный

**Проверка:**
- `pm2 status` — демон online?
- `pm2 logs deepseek-daemon` — ошибки загрузки страницы?
- Запустить с `--visible`: `ask-deepseek.sh "test" --visible`

**Исправление:**
- Если демон offline → `pm2 restart deepseek-daemon`
- Если страница не загружается → демон сам перезагрузит её при следующем запросе
- Если CDP не работает → fallback (должен сработать через 300 сек)

---

### C. Connection refused при подключении к демону

**Симптомы:**
- `puppeteer.connect() failed: Connection refused`
- `ensureBrowser()` падает в fallback на новый браузер

**Причины:**
1. Демон не запущен
2. `.daemon-ws-endpoint` устарел (демон перезапускался, endpoint изменился)
3. Порт 9222 занят/заблокирован

**Проверка:**
- `pm2 status deepseek-daemon` — online?
- `ls -l .daemon-ws-endpoint` — файл существует?
- `netstat -tlnp | grep 9222`

**Исправление:**
- `pm2 restart deepseek-daemon` (пересоздаст endpoint)
- Удалить `.daemon-ws-endpoint` и `.sessions/*.json` (принудительный перезапуск сессий)
- Если порт занят — найти процесс, который его держит, и убить

---

### D. Ответ обрывается (incomplete)

**Симптомы:**
- Ответ обрывается на середине предложения
- Лог: `⚠️  СТАТУС: INCOMPLETE_LIMIT_REACHED`

**Причина:**
- DeepSeek free tier лимит **~18 000–27 000 символов** на один запрос (зависит от сложности). После исчерпания лимита кнопка "Продолжить" перестаёт появляться, и DeepSeek игнорирует ручные "Продолжи".

**Решение:**

1. **Автоматический fallback (v3.3+):**
   - Если кнопка не найдена, а ответ 2k–6k символов (или >8k), система автоматически вводит "Продолжи" и нажимает **Enter**.
   - Это позволяет обойти отсутствие видимой кнопки (有时候 кнопка есть в DOM, но не видна).
   - **Ограничение:** Fallback не гарантирует продолжение, если DeepSeek уже достиг своего внутреннего лимита.

2. **Ручное продолжение в рамках сессии:**
   - Используйте `--session` и делайте последовательные запросы:
     ```bash
     ask-deepseek.sh "Часть 1: введение и базовые паттерны" --session guide
     ask-deepseek.sh "Продолжи, добавь коммуникацию и оркестрацию" --session guide
     ask-deepseek.sh "Заверши, добавь безопасность и мониторинг" --session guide
     ```
   - Каждый запрос добавляет ~15–20k символов.

3. **DeepSeek Pro** — снимает лимит на длину ответа (полностью беспрерывная генерация).

**Примечание:** Free tier не позволяет получить >27k символов в одном запросе, даже с продлением. Лучший workaround — два-три последовательных запроса в той же сессии.

**Симптомы:**
- `puppeteer.connect() failed: Target closed`
- Сессия в `.sessions/NAME.json` существует, но wsEndpoint нерабочий

**Причина:**
- Браузер (демон или сессионный) закрылся
- wsEndpoint устарел (перезапуск демона)

**Исправление:**
- Удалить `.sessions/NAME.json` и начать новую сессию
- Или использовать `--daemon` для подключения к демону
- Проверить, жив ли демон (`pm2 status`)

---

### E. Демон не запускается (PM2 crashed)

**Симптомы:**
- `pm2 status deepseek-daemon` → `stopped` или `errored`
- Логи: stack trace, OOM, Chrome crash

**Причины:**
1. Недостаточно памяти (OOM)
2. Chrome не может стартовать (sandbox, GPU)
3. `.profile/` повреждён

**Проверка:**
- `pm2 logs deepseek-daemon --lines 100`
- `free -h` — свободная память
- `ls -la .profile/` — права на запись

**Исправление:**
- OOM: закрыть другие процессы, увеличить swap, добавить `--max-memory-restart 300M` к PM2 процессу
- Sandbox: в `deepseek-daemon.js` уже есть `--no-sandbox`. Если падает — проверить права
- Profile: удалить `.profile/` (создастся заново, потребуется новый login DeepSeek)

---

### F. Ответ обрывается (incomplete)

**Симптомы:**
- Ответ обрывается на середине предложения
- Лог: `⚠️  СТАТУС: INCOMPLETE_LIMIT_REACHED`

**Причина:**
- DeepSeek free tier лимит **~27 000 символов** на один запрос (начальный ответ + до 10-12 продолжений через кнопку "Продолжить")
- После исчерпания лимита кнопка больше не появляется

**Решение:**
1. **Продолжение в рамках сессии** (работает в free tier):
   - После `INCOMPLETE_LIMIT_REACHED` кнопка "Продолжить" (Continue generating) должна появиться автоматически.
   - Навык автоматически кликает её до 10 раз (можно вручную нажать ещё, если нужно).
   - Пример: получили 20 000 символов → нажимаем "Продолжить" → добавляем ещё ~7 000.
   - **Итого**: до ~27 000 символов за один запрос в рамках одной сессии.

2. **Если кнопка не появилась** (редко):
   - Перезапустите демон: `pm2 restart deepseek-daemon`
   - Используйте `--session` и делайте несколько отдельных запросов, каждый раз продолжая:
     ```bash
     ask-deepseek.sh "Часть 1: введение..." --session guide
     ask-deepseek.sh "Продолжи, добавь детали..." --session guide
     ask-deepseek.sh "Заверши, дай заключение..." --session guide
     ```

3. **DeepSeek Pro** — снимает лимит на длину ответа (полностью беспрерывная генерация).

**Примечание:** Free tier не позволяет получить >27k символов в одном запросе, даже с продлением. Лучший workaround — два последовательных запроса в той же сессии.

---

### G. Fallback возвращает эхо/интерфейсный мусор

**Симптомы:**
- В ответе присутствует промпт пользователя или элементы UI ("New chat", кнопки)

**Причина:**
- Fallback (DOM extraction) находит не тот элемент

**Решение:**
- В текущей версии (v3.3) это исправлено: `extractAnswerFromDOM` фильтрует интерфейсные элементы
- Если проблема осталась — обновить скрипт до последней версии

---

### H. PM2 процесс упал с `MODULE_NOT_FOUND`

**Симптомы:**
- `pm2 status` → `errored`
- `pm2 logs` → `Cannot find module 'deepseek-daemon.js'`

**Причина:**
PM2 кэширует старый `cwd` (рабочую директорию). Если навык переместили — скрипт не находится.

**Решение:**
```bash
pm2 delete deepseek-daemon
cd ~/.openclaw/workspace/skills/ai-orchestrator
pm2 start deepseek-daemon.js --name deepseek-daemon --no-autorestart
pm2 save
```

---

### I. Браузер "уже запущен" (browser already running)

**Симптомы:**
- `Error: The browser is already running for .../.profile`

**Причина:**
Предыдущий процесс Chrome не закрылся корректно, держит lock на `.profile/`.

**Решение:**
```bash
pkill -f "ai-orchestrator/.profile"   # убить все Chrome процессы навыка
rm -f .profile/Singleton*             # удалить lock-файлы
pm2 restart deepseek-daemon
```

---

### J. Длинные запросы (>5000 символов) зависают и падают

**Симптомы:**
- Запрос на 7000+ символов hangs на "⏳ Жду ответ..."
- Логи: `detached Frame` ошибки

**Причина:**
1. DeepSeek может не отвечать в течение 5-10 минут на очень длинные запросы
2. При intensive DOM updates фреймы "отсоединяются" (detached)

**Решение:**

**Способ 1: Увеличить таймаут** в `ask-puppeteer.js` (строка `timeoutMs = 300000` → 600000)

**Способ 2: Разбить запрос на части** (рекомендуется):
```bash
# Часть 1: Структура
ask-deepseek.sh "Опиши архитектуру: обзор, компоненты" --session large > p1.txt

# Часть 2: Детали
ask-deepseek.sh "Дай подробности по безопасности, масштабированию" --session large > p2.txt

cat p1.txt p2.txt > full.txt
```

**Способ 3: Использовать v3.3** — уже включены idle detection (40 сек без прогресса → partial) и concurrent API wait.

---

### K. Селекторы устарели (DeepSeek обновил UI)

**Симптомы:**
- В `--visible` видно, что ответ в элементе с другим классом
- `extractAnswerFromDOM` не находит текст

**Решение:**
1. Откройте DeepSeek в видимом браузере: `ask-deepseek.sh "test" --visible`
2. Откройте DevTools (F12) → Inspect элемент с ответом
3. Найдите уникальный CSS-селектор (например, `[data-message-author-role="assistant"] .markdown`)
4. Добавьте его в `RESPONSE_SELECTORS` в `ask-puppeteer.js`
5. Перезапустить демон

---

### M. Fallback не находит composer (кнопка "Продолжить" отсутствует)

**Симптом:**
Лог: `❌ Composer не найден для fallback` или `⚠️ Кнопка "Продолжить" не найдена`, и ответ не продолжается.

**Причина:**
1. Интерфейс DeepSeek изменился, селекторы composer'а устарели.
2. Страница не в режиме чата (например, открыт домен без открытого чата).
3. Composer заблокирован (редко).

**Решение:**
1. Убедиться, что сессия в чате: `ask-deepseek.sh "test" --visible` → в окне браузера должен быть виден чат с полем ввода.
2. Если интерфейс изменился, обновите массив `composerSelectors` в функции `handleContinueButton`:
   ```javascript
   const composerSelectors = [
     'textarea[placeholder*="Message"]',
     'textarea[placeholder*="message"]',
     'div[contenteditable="true"]',
     'textarea',
     // добавьте новый селектор, если нашли в DevTools:
     // 'div[data-deepseek="composer"]',
   ];
   ```
3. Перезапустите демон: `pm2 restart deepseek-daemon`
4. Если проблема осталась, временно увеличьте задержку после ввода "Продолжи": `await sleep(300);` → `await sleep(1000);`

**Примечание:** Fallback срабатывает ТОЛЬКО если длительность ответа 2k–6k символов (или >8k). Если DeepSeek отклонил запрос как слишком длинный (сгенерировал 1-2k), fallback не активируется — нужно разбивать запрос на части.

---

### L. Логи разрослись, диск забит

**Проверка:**
```bash
df -h
ls -lh ~/.pm2/logs/
find ~/.openclaw/workspace/skills/ai-orchestrator -name "ds-*.html" -o -name "ds-*.png"
```

**Решение:**
```bash
# Ротация логов PM2
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 50M
pm2 set pm2-logrotate:retain 5
pm2 set pm2-logrotate:compress true

# Удалить временные файлы
rm -f ~/.openclaw/workspace/skills/ai-orchestrator/ds-*.html
rm -f ~/.openclaw/workspace/skills/ai-orchestrator/ds-*.png

# Очистить логи PM2
pm2 flush
```

---

## 13. Синтаксис аргументов ask-deepseek.sh / ask-puppeteer.js

| Флаг | Описание |
|------|---------|
| `--session <имя>` | Использовать сохраняемую сессию (сохраняет контекст между запросами) |
| `--daemon` | Требовать использования демона (ошибка, если демон не запущен) |
| `--new-chat` | Начать новый чат (даже если сессия уже существует) |
| `--close` | Закрыть браузер после завершения (только для одиночных запросов, без сессии) |
| `--end-session` | Завершить сессию (удаляет `.sessions/<имя>.json`) |
| `--timeout <секунды>` | Таймаут ожидания ответа (default: 60, min: 10) |
| `--visible` | Показать браузер (для отладки) |
| `--verbose` | Подробный вывод (debug-логи) |

---

## 14. Примеры использования

### Разработка — быстрое тестирование
```bash
node ask-puppeteer.js "test -- markers" --timeout 90 2>&1 | grep -E "символов|OTBET|FINISHED"
```

### Производство — фоновый запрос
```bash
node ask-puppeteer.js "Сгенерируй отчет за сегодня" --session daily-report --daemon
```

### Отладка — видимый браузер
```bash
node ask-puppeteer.js "ошибка повторяется" --visible --verbose
```

### Administrative — перезапуск демона
```bash
pm2 restart deepseek-daemon && sleep 8 && cat .daemon-ws-endpoint
```

---

## 15. План B: DOM-based answer extraction (2026-03-29)

После того как CDP SSE парсинг оказался хрупким, мы перешли на стратегию "DOM as source of truth".

### Изменения

- **Удалён `parseDeepSeekSSE`** (вся логика склеивания JSON-фрагментов).
- **CDP interceptor** используется ТОЛЬКО как индикатор завершения стрима (`Network.loadingFinished`).
- Как только CDP сообщает о завершении (или срабатывает idle/DOM churn), вызывается `extractAnswerFromDOM()` — однократное извлечение текста из DOM.
- Селекторы ответа:
  - `data-message-author-role="assistant"` (приоритет)
  - `.ds-markdown`, `.markdown-body`, `div[class*="assistant"]`, `div[class*="ai"]`, `div[class*="bot"]`
- Исключаются интерфейсные элементы (`nav`, `aside`, `.sidebar`, `[contenteditable]`, `.composer`).
- Берётся **последний** найденный блок (текущий ответ).
- Если ничего не найдено, fallback — `document.body.innerText` с удалением промпта.

### Преимущества
- **Независимость от формата SSE** — не парсим JSON-фрагменты.
- **Чистый текст** — DeepSeek уже рендерит Markdown; мы его просто извлекаем.
- **Стабильность** — не ломается при смене внутреннего RPC DeepSeek.

### Тест
```bash
node ask-puppeteer.js "short query" --session domtest
```
✅ Должен вернуть чистый ответ без интерфейсного мусора.

---

## 16. Окончательный бэкап и коммиты

Все изменения за март 2026 закоммичены в workspace и в `skills/ai-orchestrator/`. Память (MEMORY.md) обновлена.

**Коммиты включают:**
- Stale endpoint cleanup (удаление мёртвого `.daemon-ws-endpoint`)
- Error message fix (`systemctl` → `node deepseek-daemon.js`)
- Smoke-test timeout 60s → 120s
- Daemon registration in PM2 (online)
- v3.3 SSE parsing fix + DOM-first
- v3.2 fast prompt inject (instant paste)
- v3.1 idle detection + concurrent API wait
- v3.0 DOM extraction rewrite

---

## 17. Операционная памятка (Ops Cheatsheet)

```bash
# 1. Проверка статуса демона
pm2 describe deepseek-daemon | grep status

# 2. Перезапуск демона (основная операция)
pm2 restart deepseek-daemon && sleep 8 && cat .daemon-ws-endpoint

# 3. Чистый тест (проверить что всё работает)
node ask-puppeteer.js "Say: TEST" --session clean --daemon --new-chat

# 4. Убить зависшие процессы
pkill -f "ask-puppeteer"
pkill -f "ai-orchestrator/.profile"
rm -f .profile/Singleton*

# 5. Если PM2 демон не запускается (Module not found)
pm2 delete deepseek-daemon
cd ~/.openclaw/workspace/skills/ai-orchestrator
pm2 start deepseek-daemon.js --name deepseek-daemon --no-autorestart
pm2 save

# 6. Логи демона (последние 50 строк)
pm2 logs deepseek-daemon --lines 50 --nostream

# 7. Проверка endpoint
cat ~/.openclaw/workspace/skills/ai-orchestrator/.daemon-ws-endpoint

# 8. Очистка всех процессов навыка
pkill -9 -f "ask-puppeteer"
pkill -9 -f "deepseek-daemon"
pkill -9 -f "ai-orchestrator"
rm -f .profile/Singleton*
pm2 restart deepseek-daemon
```

---

## 18. Обновление кода

### Git (если используется)
```bash
cd ~/.openclaw/workspace/skills/ai-orchestrator
git pull origin main   # если есть репозиторий
cd ~/.openclaw/workspace/skills/ai-orchestrator && npm ci --omit=dev
pm2 restart deepseek-daemon
```

### Без git (перезапись скриптов)
1. Скачать новые версии `ask-puppeteer.js`, `deepseek-daemon.js` и `daemon-healthcheck.js`
2. Проверить синтаксис: `node -c ask-puppeteer.js`
3. Перезапустить демон: `pm2 restart deepseek-daemon`

---

## 19. Production checklist

- [x] deepseek-daemon.js запущен через PM2
- [x] .daemon-ws-endpoint существует и содержит ws://...
- [x] pm2 status показывает deepseek-daemon: online
- [x] Auto-restart включён (PM2)
- [x] pm2-logrotate настроен (50M, retain=5)
- [x] Сессии не обязательны для стабильности (если есть дроп — перезапуск демона)
- [x] Бэкап сделан (исключая node_modules и .profile)
- [x] Gateway перезапущен после изменений в skill

---

**Последнее обновление документации:** 2026-03-31 13:05 (Asia/Irkutsk)  
**Версия навыка:** 3.3.0  
**Автор:** Clawd (AI Orchestrator maintainer)
