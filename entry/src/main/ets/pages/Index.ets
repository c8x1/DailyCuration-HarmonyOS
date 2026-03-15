import { Article } from '../model/ArticleModel';
import { CacheManager } from '../model/CacheManager';
import { HttpUtil } from '../utils/HttpUtil';
import { NotificationUtil } from '../utils/NotificationUtil';
import { ArticleCard } from '../components/ArticleCard';
import { LoadingView, EmptyView, ErrorView } from '../components/LoadingView';
import { promptAction, share, router } from '@kit.ArkUI';
import { businessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State articles: Article[] = [];
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false;
  @State errorMessage: string = '';
  @State favoriteIds: Set<string> = new Set();

  private cacheManager: CacheManager = CacheManager.getInstance();
  private httpUtil: HttpUtil = HttpUtil.getInstance();

  async aboutToAppear() {
    await this.cacheManager.init(getContext(this));
    await NotificationUtil.initNotificationChannel();
    await this.loadFavorites();
    await this.loadArticles();
  }

  async loadFavorites() {
    const favorites = await this.cacheManager.getFavorites();
    this.favoriteIds = new Set(favorites.map(f => f.id));
  }

  async loadArticles() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 先尝试从网络获取
      const hasNetwork = await this.httpUtil.checkNetwork();
      
      if (hasNetwork) {
        const articles = await this.httpUtil.fetchArticles();
        this.articles = articles.sort((a, b) => 
          new Date(b.date).getTime() - new Date(a.date).getTime()
        );
        await this.cacheManager.cacheArticles(this.articles);
        
        // 检查是否有今日新文章，发送通知
        await this.checkAndNotifyDailyArticle();
      } else {
        // 无网络，使用缓存
        const cached = await this.cacheManager.getCachedArticles();
        if (cached.length > 0) {
          this.articles = cached;
          promptAction.showToast({ message: '使用离线缓存' });
        } else {
          this.errorMessage = '无网络连接且无缓存数据';
        }
      }
    } catch (err) {
      // 出错时尝试使用缓存
      const cached = await this.cacheManager.getCachedArticles();
      if (cached.length > 0) {
        this.articles = cached;
        promptAction.showToast({ message: '加载失败，使用缓存' });
      } else {
        this.errorMessage = '加载失败：' + (err as Error).message;
      }
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  async checkAndNotifyDailyArticle() {
    const today = new Date().toISOString().split('T')[0];
    const todayArticle = this.articles.find(a => a.date === today);
    if (todayArticle) {
      // 检查今天是否已经发送过通知
      const lastNotifyDate = AppStorage.get<string>('last_notify_date');
      if (lastNotifyDate !== today) {
        await NotificationUtil.sendDailyArticleNotification(todayArticle);
        AppStorage.setOrCreate('last_notify_date', today);
      }
    }
  }

  async onRefresh() {
    this.isRefreshing = true;
    await this.loadArticles();
  }

  async toggleFavorite(article: Article) {
    if (this.favoriteIds.has(article.id)) {
      await this.cacheManager.removeFavorite(article.id);
      this.favoriteIds.delete(article.id);
      promptAction.showToast({ message: '已取消收藏' });
    } else {
      await this.cacheManager.addFavorite(article);
      this.favoriteIds.add(article.id);
      promptAction.showToast({ message: '已收藏' });
    }
    // 触发UI更新
    this.favoriteIds = new Set(this.favoriteIds);
  }

  async shareArticle(article: Article) {
    const shareUrl = `https://c8x1.github.io/${article.file}`;
    
    try {
      await share.share({
        title: article.title,
        content: article.summary,
        url: shareUrl
      });
    } catch (err) {
      const code = (err as businessError.BusinessError).code;
      if (code !== 12500002) { // 用户取消不算错误
        promptAction.showToast({ message: '分享失败' });
      }
    }
  }

  goToDetail(article: Article) {
    router.pushUrl({
      url: 'pages/ArticleDetail',
      params: { article: JSON.stringify(article) }
    });
  }

  goToFavorites() {
    router.pushUrl({ url: 'pages/Favorites' });
  }

  build() {
    Navigation() {
      Column() {
        if (this.isLoading) {
          LoadingView({ message: '加载文章中...' })
        } else if (this.errorMessage) {
          ErrorView({
            message: this.errorMessage,
            onRetry: () => this.loadArticles()
          })
        } else if (this.articles.length === 0) {
          EmptyView({ message: '暂无文章' })
        } else {
          List({ space: 12 }) {
            ForEach(this.articles, (article: Article) => {
              ListItem() {
                ArticleCard({
                  article: article,
                  isFavorite: this.favoriteIds.has(article.id),
                  onCardClick: () => this.goToDetail(article),
                  onFavoriteClick: () => this.toggleFavorite(article),
                  onShareClick: () => this.shareArticle(article)
                })
              }
            })
          }
          .width('100%')
          .height('100%')
          .padding(16)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Auto)
          .refresh({
            refreshing: this.isRefreshing,
            onRefresh: () => this.onRefresh()
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('每日精选')
    .titleMode(NavigationTitleMode.Mini)
    .menus([
      {
        value: '',
        icon: $r('app.media.icon_favorite'),
        action: () => this.goToFavorites()
      }
    ])
  }
}