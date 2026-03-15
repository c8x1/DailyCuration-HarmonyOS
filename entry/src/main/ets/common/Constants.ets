// 常量定义
export class Constants {
  // 数据源URL
  static readonly ARTICLES_JSON_URL = 'https://c8x1.github.io/articles.json';
  static readonly BASE_URL = 'https://c8x1.github.io';
  
  // 缓存配置
  static readonly CACHE_EXPIRE_DAYS = 7;
  static readonly PREFERENCES_NAME = 'DailyCurationPrefs';
  
  // 通知配置
  static readonly NOTIFICATION_CHANNEL_ID = 'daily_article_channel';
  static readonly NOTIFICATION_CHANNEL_NAME = '每日文章推送';
  
  // 默认设置
  static readonly DEFAULT_NOTIFICATION_ENABLED = true;
  static readonly DEFAULT_AUTO_CACHE = true;
}