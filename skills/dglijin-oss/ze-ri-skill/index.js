/**
 * 择日学 Skill - 核心算法
 * 作者：天工长老
 * 版本：v1.0
 * 创建：2026 年 3 月 29 日
 */

// 建除十二神计算
function getJianChu(year, month, day) {
  // 简化算法：以月建为基准
  const monthJian = ['建', '除', '满', '平', '定', '执', '破', '危', '成', '收', '开', '闭'];
  
  // 计算月建（简化：正月建寅）
  const lunarMonth = ((month - 1 + 2) % 12); // 调整为农历月
  
  // 计算日建除
  const dayIndex = (day + lunarMonth) % 12;
  
  return monthJian[dayIndex];
}

// 黄道黑道计算（简化版）
function getHuangDao(year, month, day) {
  const huangDao = ['青龙', '明堂', '天刑', '朱雀', '金匮', '天德', '白虎', '玉堂', '天牢', '玄武', '司命', '勾陈'];
  const dayIndex = (year + month + day) % 12;
  return huangDao[dayIndex];
}

// 建除吉凶判断
function getJianChuJiXiong(jianChu) {
  const jiXiong = {
    '建': '吉', '除': '吉', '满': '吉', '平': '平',
    '定': '吉', '执': '吉', '破': '凶', '危': '凶',
    '成': '吉', '收': '吉', '开': '吉', '闭': '凶'
  };
  return jiXiong[jianChu] || '平';
}

// 黄道黑道吉凶判断
function getHuangDaoJiXiong(huangDao) {
  const jiXiong = {
    '青龙': '大吉', '明堂': '吉', '天刑': '凶', '朱雀': '凶',
    '金匮': '吉', '天德': '吉', '白虎': '凶', '玉堂': '吉',
    '天牢': '凶', '玄武': '凶', '司命': '吉', '勾陈': '凶'
  };
  return jiXiong[huangDao] || '平';
}

// 宜忌查询（简化版）
function getYiJi(jianChu, huangDao) {
  const yiMap = {
    '建': ['上任', '出行', '安床'],
    '除': ['扫舍', '求医', '解除'],
    '满': ['祭祀', '祈福', '嫁娶'],
    '平': ['祭祀', '祈福', '修造'],
    '定': ['祭祀', '祈福', '嫁娶'],
    '执': ['祭祀', '祈福', '捕捉'],
    '破': ['破屋', '坏垣', '求医'],
    '危': ['祭祀', '祈福'],
    '成': ['祭祀', '祈福', '嫁娶', '开业'],
    '收': ['祭祀', '祈福', '捕捉', '纳财'],
    '开': ['祭祀', '祈福', '嫁娶', '开业', '出行'],
    '闭': ['祭祀', '祈福', '修造']
  };
  
  const jiMap = {
    '建': ['动土', '开仓'],
    '除': ['余事'],
    '满': ['服药', '栽种'],
    '平': ['嫁娶', '安葬'],
    '定': ['出行', '医疗'],
    '执': ['出行', '搬迁'],
    '破': ['余事'],
    '危': ['登高', '乘船'],
    '成': ['诉讼'],
    '收': ['出行', '安葬'],
    '开': ['动土'],
    '闭': ['嫁娶', '出行', '安葬']
  };
  
  return {
    宜：yiMap[jianChu] || [],
    忌：jiMap[jianChu] || []
  };
}

// 综合择日判断
function zeRi(year, month, day, eventType = 'general') {
  const jianChu = getJianChu(year, month, day);
  const huangDao = getHuangDao(year, month, day);
  const jianChuJiXiong = getJianChuJiXiong(jianChu);
  const huangDaoJiXiong = getHuangDaoJiXiong(huangDao);
  const yiJi = getYiJi(jianChu, huangDao);
  
  // 综合评分
  let score = 50;
  if (jianChuJiXiong === '吉') score += 20;
  if (jianChuJiXiong === '凶') score -= 20;
  if (huangDaoJiXiong.includes('吉')) score += 15;
  if (huangDaoJiXiong.includes('凶')) score -= 15;
  
  let conclusion = '平';
  if (score >= 80) conclusion = '大吉';
  else if (score >= 65) conclusion = '吉';
  else if (score >= 50) conclusion = '平';
  else if (score >= 35) conclusion = '凶';
  else conclusion = '大凶';
  
  return {
    日期：`${year}年${month}月${day}日`,
    建除：jianChu,
    建除吉凶：jianChuJiXiong,
    黄道：huangDao,
    黄道吉凶：huangDaoJiXiong,
    宜：yiJi.宜，
    忌：yiJi.忌，
    综合评分：score,
    综合判断：conclusion
  };
}

// 择日推荐（给定月份推荐吉日）
function tuiJianJiRi(year, month, eventType = '嫁娶', limit = 5) {
  const daysInMonth = new Date(year, month, 0).getDate();
  const jiRiList = [];
  
  for (let day = 1; day <= daysInMonth; day++) {
    const result = zeRi(year, month, day);
    if (result.综合评分 >= 65) {
      if (eventType === '嫁娶' && result.宜.includes('嫁娶')) {
        jiRiList.push({ ...result, 日：day });
      } else if (eventType === '开业' && result.宜.includes('开业')) {
        jiRiList.push({ ...result, 日：day });
      } else if (eventType === 'general') {
        jiRiList.push({ ...result, 日：day });
      }
    }
  }
  
  return jiRiList.slice(0, limit);
}

// 导出
module.exports = {
  zeRi,
  tuiJianJiRi,
  getJianChu,
  getHuangDao,
  getJianChuJiXiong,
  getHuangDaoJiXiong
};
