#!/usr/bin/env node

/**
 * memory-refiner.js - MEMORY.md 提炼工具。MEMORY.md refiner utility.
 * 
 * 负责从 Daily 笔记中提炼长期记忆，使用 OpenClaw 主 LLM 智能分析和分类。
 * Responsible for refining long-term memory from Daily notes using OpenClaw main LLM.
 */

const fs = require('fs');
const path = require('path');
const { refineMemory: refineMemoryViaSubagent } = require('./subagent-runner');

/**
 * 读取所有 Daily 笔记
 */
function readAllDailyNotes(dailyDir) {
  if (!fs.existsSync(dailyDir)) {
    return [];
  }
  
  const files = fs.readdirSync(dailyDir)
    .filter(f => f.endsWith('.md'))
    .sort()
    .reverse(); // 最新的在前
  
  const notes = [];
  
  for (const file of files) {
    try {
      const content = fs.readFileSync(path.join(dailyDir, file), 'utf-8');
      notes.push({
        filename: file,
        date: file.replace('.md', ''),
        content
      });
    } catch (error) {
      console.error(`读取 ${file} 失败:`, error.message);
    }
  }
  
  return notes;
}

/**
 * 使用 LLM 从 Daily 笔记中提炼长期记忆
 */
async function refineMemoryWithLLM(dailyNotes) {
  if (dailyNotes.length === 0) {
    console.log('⚠️  没有 Daily 笔记可提炼');
    return { success: false, reason: 'no_notes' };
  }
  
  console.log(`📄 读取了 ${dailyNotes.length} 篇 Daily 笔记`);
  
  // 如果笔记太多，只处理最近的 10 篇
  const notesToProcess = dailyNotes.slice(0, 10);
  
  const notesContent = notesToProcess.map(note => {
    return `【${note.date}】\n${note.content.substring(0, 2000)}`;
  });
  
  try {
    console.log('  🤖 使用 LLM 提炼长期记忆...');
    const memoryContent = await refineMemoryViaSubagent(notesContent);
    
    return {
      success: true,
      content: memoryContent,
      notesProcessed: notesToProcess.length
    };
  } catch (error) {
    console.error('  ⚠️  LLM 提炼记忆失败，使用规则提炼:', error.message);
    return refineMemoryWithRules(dailyNotes);
  }
}

/**
 * 使用规则提炼记忆（降级方案）
 */
function refineMemoryWithRules(dailyNotes) {
  const MEMORY_CATEGORIES = {
    USER_PREFERENCES: {
      key: 'userPreferences',
      title: '🎯 用户偏好',
      keywords: ['偏好', '喜欢', '习惯', '风格', '语言', '时区', '格式', '配置']
    },
    DECISIONS: {
      key: 'decisions',
      title: '💡 重要决策',
      keywords: ['决定', '决策', '确定', '选择', '采用', '使用']
    },
    PROJECTS: {
      key: 'projects',
      title: '📈 项目进展',
      keywords: ['项目', '进展', '完成', '进行中', '任务', '目标']
    },
    TODOS: {
      key: 'todos',
      title: '📋 待办事项',
      keywords: ['待办', '计划', '要做', '未完成', '接下来', '后续']
    },
    SKILLS: {
      key: 'skills',
      title: '🔧 技能配置',
      keywords: ['Skill', '技能', '安装', '配置', '工具', '扩展']
    },
    LEARNINGS: {
      key: 'learnings',
      title: '📚 关键学习',
      keywords: ['学习', '经验', '教训', '问题', '解决', '方案', '发现']
    }
  };
  
  const memories = {};
  
  // 初始化分类
  Object.values(MEMORY_CATEGORIES).forEach(cat => {
    memories[cat.key] = [];
  });
  
  for (const note of dailyNotes) {
    const lines = note.content.split('\n');
    
    for (const line of lines) {
      const trimmedLine = line.trim();
      if (trimmedLine.length < 10 || trimmedLine.startsWith('#')) continue;
      
      // 检查每个分类
      for (const category of Object.values(MEMORY_CATEGORIES)) {
        for (const keyword of category.keywords) {
          if (trimmedLine.toLowerCase().includes(keyword.toLowerCase())) {
            // 避免重复
            const exists = memories[category.key].some(
              m => m.content.includes(trimmedLine.substring(0, 50))
            );
            
            if (!exists) {
              memories[category.key].push({
                content: trimmedLine,
                source: note.date,
                category: category.key
              });
            }
            break;
          }
        }
      }
    }
  }
  
  // 生成 MEMORY.md 内容
  let content = `# MEMORY.md - 长期记忆\n\n`;
  content += `_最后更新：${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}_\n\n`;
  content += `> 此文件由 heartbeat-memory Skill 自动维护，记录重要的长期记忆。\n\n`;
  content += `---\n\n`;
  
  for (const category of Object.values(MEMORY_CATEGORIES)) {
    const items = memories[category.key] || [];
    
    content += `## ${category.title}\n\n`;
    
    if (items.length === 0) {
      content += `_暂无内容_\n\n`;
    } else {
      // 限制每个分类最多 10 条，按日期排序（最新的在前）
      const sorted = items.sort((a, b) => b.source.localeCompare(a.source)).slice(0, 10);
      for (const item of sorted) {
        content += `- ${item.content} _(${item.source})_\n`;
      }
      content += '\n';
    }
    
    content += `---\n\n`;
  }
  
  return {
    success: true,
    content,
    notesProcessed: dailyNotes.length,
    totalItems: Object.values(memories).reduce((sum, items) => sum + items.length, 0)
  };
}

/**
 * 写入 MEMORY.md
 */
function writeMemoryFile(content, memoryPath) {
  try {
    // 确保目录存在
    const dir = path.dirname(memoryPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    fs.writeFileSync(memoryPath, content, 'utf-8');
    return { success: true, path: memoryPath };
  } catch (error) {
    console.error('写入 MEMORY.md 失败:', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * 检查是否需要提炼
 * 使用 lastRefine 字段（只记录提炼时间），和 lastCheck（检查时间）分离
 */
function shouldRefine(state, config) {
  const schedule = config.memorySave?.refineSchedule || { type: 'weekly', dayOfWeek: 'sunday', time: '20:00' };
  
  // 首次运行：强制触发提炼
  if (!state.lastRefine) {
    return true;
  }
  
  const now = new Date();
  const lastRefine = new Date(state.lastRefine);
  
  if (schedule.type === 'weekly') {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const targetDay = days.indexOf(schedule.dayOfWeek);
    const currentDay = now.getDay();
    
    if (currentDay === targetDay) {
      const [targetHour, targetMinute] = (schedule.time || '20:00').split(':').map(Number);
      const lastHour = lastRefine.getHours();
      const lastMinute = lastRefine.getMinutes();
      const currentHour = now.getHours();
      const currentMinute = now.getMinutes();
      
      const lastTotalMinutes = lastHour * 60 + lastMinute;
      const currentTotalMinutes = currentHour * 60 + currentMinute;
      const targetTotalMinutes = targetHour * 60 + targetMinute;
      
      // 检查是否已过目标时间且上次提炼在目标时间之前
      return currentTotalMinutes >= targetTotalMinutes && lastTotalMinutes < targetTotalMinutes;
    }
  } else if (schedule.type === 'interval') {
    const daysDiff = (now - lastRefine) / (1000 * 60 * 60 * 24);
    return daysDiff >= (schedule.days || 7);
  }
  
  return false;
}

/**
 * 主提炼函数
 */
async function refineMemory(dailyDir, memoryPath, state, config, saveStateFn) {
  console.log('🧠 开始提炼 MEMORY.md...');
  
  // 读取所有 Daily 笔记
  const notes = readAllDailyNotes(dailyDir);
  
  if (notes.length === 0) {
    console.log('⚠️  没有 Daily 笔记可提炼');
    return { success: false, reason: 'no_notes' };
  }
  
  // 使用 LLM 提炼记忆
  const result = await refineMemoryWithLLM(notes);
  
  if (result.success) {
    // 写入文件
    const writeResult = writeMemoryFile(result.content, memoryPath);
    
    if (writeResult.success) {
      console.log('✅ MEMORY.md 提炼完成');
      
      // 更新 lastRefine 记录
      if (saveStateFn && state) {
        state.lastRefine = new Date().toISOString();
        saveStateFn(state);
      }
      
      // 统计
      if (result.totalItems) {
        console.log(`📊 共提炼 ${result.totalItems} 条记忆`);
      } else {
        console.log(`📊 处理了 ${result.notesProcessed} 篇 Daily 笔记`);
      }
      
      return { success: true, ...result };
    }
    
    return writeResult;
  }
  
  return result;
}

/**
 * 生成 MEMORY.md 内容（兼容测试）
 */
function generateMemoryContent(refinedMemories) {
  const MEMORY_CATEGORIES = {
    USER_PREFERENCES: { key: 'userPreferences', title: '🎯 用户偏好' },
    DECISIONS: { key: 'decisions', title: '💡 重要决策' },
    PROJECTS: { key: 'projects', title: '📈 项目进展' },
    TODOS: { key: 'todos', title: '📋 待办事项' },
    SKILLS: { key: 'skills', title: '🔧 技能配置' },
    LEARNINGS: { key: 'learnings', title: '📚 关键学习' }
  };
  
  let content = `# MEMORY.md - 长期记忆\n\n`;
  content += `_最后更新：${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}_\n\n`;
  content += `> 此文件由 heartbeat-memory Skill 自动维护，记录重要的长期记忆。\n\n`;
  content += `---\n\n`;
  
  for (const category of Object.values(MEMORY_CATEGORIES)) {
    const items = refinedMemories[category.key] || [];
    
    content += `## ${category.title}\n\n`;
    
    if (items.length === 0) {
      content += `_暂无内容_\n\n`;
    } else {
      for (const item of items) {
        content += `- ${item.content} _(${item.source})_\n`;
      }
      content += '\n';
    }
    
    content += `---\n\n`;
  }
  
  return content;
}

module.exports = {
  readAllDailyNotes,
  refineMemoryWithLLM,
  refineMemoryWithRules,
  generateMemoryContent,
  writeMemoryFile,
  shouldRefine,
  refineMemory
};
