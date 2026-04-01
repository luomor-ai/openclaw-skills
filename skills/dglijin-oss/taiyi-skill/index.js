/**
 * 太乙神数 Skill - 核心算法（第一版简化）
 * 作者：天工长老
 * 版本：v1.0
 * 创建：2026 年 3 月 29 日
 */

// 十六神将（简化版）
const SHI_LIU_SHEN_JIANG = [
  '太乙', '文昌', '计神', '始击',
  '主大', '客大', '主算', '客算',
  '定算', '四神', '天目', '地目',
  '飞鸟', '走兽', '游都', '鲁都'
];

// 神将含义
const SHEN_JIANG_HAN_YI = {
  '太乙': '主神，统领全局',
  '文昌': '文运、文化、考试',
  '计神': '计谋、策略、谋划',
  '始击': '开始、攻击、行动',
  '主大': '主方大将、内部领导',
  '客大': '客方大将、外部对手',
  '主算': '主方计算、内部运势',
  '客算': '客方计算、外部运势',
  '定算': '定局计算、最终结果',
  '四神': '四方之神、守护',
  '天目': '天文观测、天时',
  '地目': '地理观测、地利',
  '飞鸟': '空中事务、快速',
  '走兽': '地面事务、稳定',
  '游都': '游走之都、变动',
  '鲁都': '固定之都、稳定'
};

// 九宫
const JIU_GONG = [
  '坎一宫', '坤二宫', '震三宫', '巽四宫',
  '中五宫', '乾六宫', '兑七宫', '艮八宫', '离九宫'
];

// 阴阳遁判断
function getYinYangDun(month, day) {
  // 简化：冬至后阳遁，夏至后阴遁
  // 冬至约 12 月 21 日，夏至约 6 月 21 日
  if ((month > 6) || (month === 6 && day >= 21)) {
    return '阴遁';
  } else {
    return '阳遁';
  }
}

// 太乙积年计算
function calcTaiYiJiNian(year) {
  // 基准年：公元前 2917 年（上元甲子）
  return year + 2917;
}

// 局数计算（简化版）
function calcJuShu(jiNian, yinYangDun) {
  if (yinYangDun === '阳遁') {
    return ((jiNian - 1) % 9) + 1;
  } else {
    return 9 - ((jiNian - 1) % 9);
  }
}

// 十六神将排布（简化版）
function paiShenJiang(juShu) {
  const shenJiangList = [];
  const startIndex = (juShu - 1) % 16;
  
  for (let i = 0; i < 16; i++) {
    const gongIndex = (startIndex + i) % 9;
    shenJiangList.push({
      神将：SHI_LIU_SHEN_JIANG[i],
      落宫：JIU_GONG[gongIndex],
      含义：SHEN_JIANG_HAN_YI[SHI_LIU_SHEN_JIANG[i]]
    });
  }
  
  return shenJiangList;
}

// 主客算计算（简化版）
function calcZhuKeSuan(jiNian, juShu) {
  // 简化算法
  const zhuSuan = (jiNian % 60) + 1;
  const keSuan = ((jiNian + juShu) % 60) + 1;
  const dingSuan = (zhuSuan + keSuan) % 60;
  
  return {
    主算：zhuSuan,
    客算：keSuan,
    定算：dingSuan
  };
}

// 主客判断
function zhuKePanDuan(zhuSuan, keSuan) {
  if (zhuSuan > keSuan) {
    return { 结果：'主胜', 建议：'宜守不宜攻，内部有利' };
  } else if (keSuan > zhuSuan) {
    return { 结果：'客胜', 建议：'宜主动出击，外部有利' };
  } else {
    return { 结果：'平局', 建议：'宜和谈合作' };
  }
}

// 大势判断
function daShiPanDuan(shenJiangList, zhuKe) {
  const panDuan = [];
  
  // 找太乙落宫
  const taiYi = shenJiangList.find(s => s.神将 === '太乙');
  if (taiYi) {
    panDuan.push(`太乙落${taiYi.落宫}：全局主导方向`);
  }
  
  // 找文昌
  const wenChang = shenJiangList.find(s => s.神将 === '文昌');
  if (wenChang) {
    panDuan.push(`文昌落${wenChang.落宫}：文运${wenChang.落宫.includes('四') ? '旺' : '平'}`);
  }
  
  // 主客判断
  panDuan.push(`主客算：${zhuKe.结果} - ${zhuKe.建议}`);
  
  return panDuan;
}

// 综合太乙神数分析
function taiYiShenShu(year, question = '国运大势') {
  // 积年
  const jiNian = calcTaiYiJiNian(year);
  
  // 阴阳遁（简化用年中）
  const yinYangDun = getYinYangDun(6, 15);
  
  // 局数
  const juShu = calcJuShu(jiNian, yinYangDun);
  
  // 神将排布
  const shenJiangList = paiShenJiang(juShu);
  
  // 主客算
  const zhuKe = calcZhuKeSuan(jiNian, juShu);
  const zhuKePD = zhuKePanDuan(zhuKe.主算，zhuKe.客算);
  
  // 大势判断
  const daShi = daShiPanDuan(shenJiangList, zhuKePD);
  
  return {
    年份：year,
    积年：jiNian,
    遁局：yinYangDun,
    局数：juShu,
    十六神将：shenJiangList,
    主客算：zhuKe,
    主客判断：zhuKePD,
    大势判断：daShi,
    问题：question
  };
}

// 导出
module.exports = {
  taiYiShenShu,
  calcTaiYiJiNian,
  getYinYangDun,
  calcJuShu,
  paiShenJiang,
  calcZhuKeSuan,
  zhuKePanDuan,
  SHI_LIU_SHEN_JIANG,
  SHEN_JIANG_HAN_YI
};
