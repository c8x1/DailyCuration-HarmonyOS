// 文章数据模型
export interface ArticleStats {
  wordCount: number;
  readTime: number;
}

export interface Article {
  id: string;
  title: string;
  subtitle: string;
  author: string;
  source: string;
  date: string;
  category: string[];
  tags: string[];
  summary: string;
  file: string;
  originalUrl: string;
  stats: ArticleStats;
}

export interface ArticlesMeta {
  title: string;
  description: string;
  version: string;
  updated: string;
  totalArticles: number;
}

export interface ArticlesData {
  meta: ArticlesMeta;
  articles: Article[];
}

// 收藏文章（本地存储格式）
export interface FavoriteArticle extends Article {
  favoritedAt: number;
}

// 缓存的文章内容
export interface CachedArticle {
  article: Article;
  htmlContent: string;
  cachedAt: number;
}