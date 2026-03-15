import { Article, CachedArticle, FavoriteArticle } from './ArticleModel';
import { preferences } from '@kit.ArkData';
import { Constants } from '../common/Constants';

const FAVORITES_KEY = 'favorites';

export class CacheManager {
  private static instance: CacheManager;
  private pref: preferences.Preferences | null = null;

  static getInstance(): CacheManager {
    if (!CacheManager.instance) {
      CacheManager.instance = new CacheManager();
    }
    return CacheManager.instance;
  }

  async init(context: Context): Promise<void> {
    this.pref = await preferences.getPreferences(context, Constants.PREFERENCES_NAME);
  }

  // 缓存文章列表
  async cacheArticles(articles: Article[]): Promise<void> {
    if (!this.pref) return;
    await this.pref.put('cached_articles', JSON.stringify(articles));
    await this.pref.flush();
  }

  // 获取缓存的文章列表
  async getCachedArticles(): Promise<Article[]> {
    if (!this.pref) return [];
    const data = await this.pref.get('cached_articles', '[]') as string;
    try {
      return JSON.parse(data) as Article[];
    } catch {
      return [];
    }
  }

  // 缓存单篇文章HTML
  async cacheArticleHtml(article: Article, htmlContent: string): Promise<void> {
    if (!this.pref) return;
    const cacheKey = `article_html_${article.id}`;
    const cachedData: CachedArticle = {
      article,
      htmlContent,
      cachedAt: Date.now()
    };
    await this.pref.put(cacheKey, JSON.stringify(cachedData));
    await this.pref.flush();
  }

  // 获取缓存的文章HTML
  async getCachedArticleHtml(articleId: string): Promise<string | null> {
    if (!this.pref) return null;
    const cacheKey = `article_html_${articleId}`;
    const data = await this.pref.get(cacheKey, '') as string;
    if (!data) return null;
    try {
      const cached = JSON.parse(data) as CachedArticle;
      return cached.htmlContent;
    } catch {
      return null;
    }
  }

  // 检查文章是否已缓存
  async isArticleCached(articleId: string): Promise<boolean> {
    const html = await this.getCachedArticleHtml(articleId);
    return html !== null;
  }

  // 添加收藏
  async addFavorite(article: Article): Promise<void> {
    if (!this.pref) return;
    const favorites = await this.getFavorites();
    if (!favorites.find(f => f.id === article.id)) {
      favorites.unshift({
        ...article,
        favoritedAt: Date.now()
      });
      await this.pref.put(FAVORITES_KEY, JSON.stringify(favorites));
      await this.pref.flush();
    }
  }

  // 移除收藏
  async removeFavorite(articleId: string): Promise<void> {
    if (!this.pref) return;
    const favorites = await this.getFavorites();
    const filtered = favorites.filter(f => f.id !== articleId);
    await this.pref.put(FAVORITES_KEY, JSON.stringify(filtered));
    await this.pref.flush();
  }

  // 获取所有收藏
  async getFavorites(): Promise<FavoriteArticle[]> {
    if (!this.pref) return [];
    const data = await this.pref.get(FAVORITES_KEY, '[]') as string;
    try {
      return JSON.parse(data) as FavoriteArticle[];
    } catch {
      return [];
    }
  }

  // 检查是否已收藏
  async isFavorite(articleId: string): Promise<boolean> {
    const favorites = await this.getFavorites();
    return favorites.some(f => f.id === articleId);
  }

  // 清除过期缓存（超过7天）
  async clearExpiredCache(): Promise<void> {
    if (!this.pref) return;
    const keys = await this.pref.getAll();
    const now = Date.now();
    const expireTime = Constants.CACHE_EXPIRE_DAYS * 24 * 60 * 60 * 1000;
    
    for (const key in keys) {
      if (key.startsWith('article_html_')) {
        try {
          const data = JSON.parse(keys[key] as string) as CachedArticle;
          if (now - data.cachedAt > expireTime) {
            await this.pref.delete(key);
          }
        } catch {
          // 解析失败，删除
          await this.pref.delete(key);
        }
      }
    }
    await this.pref.flush();
  }

  // 清除所有缓存（保留收藏）
  async clearAllCache(): Promise<void> {
    if (!this.pref) return;
    const keys = await this.pref.getAll();
    
    for (const key in keys) {
      // 删除所有文章相关的缓存，但保留收藏
      if (key.startsWith('article_html_') || key === 'cached_articles') {
        await this.pref.delete(key);
      }
    }
    await this.pref.flush();
  }

  // 获取缓存大小（估算）
  async getCacheSize(): Promise<number> {
    if (!this.pref) return 0;
    const keys = await this.pref.getAll();
    let totalSize = 0;
    
    for (const key in keys) {
      if (key.startsWith('article_html_') || key === 'cached_articles') {
        const value = keys[key] as string;
        totalSize += new Blob([value]).size;
      }
    }
    return totalSize;
  }
}