import { Article } from '../model/ArticleModel';
import { CacheManager } from '../model/CacheManager';
import { HttpUtil } from '../utils/HttpUtil';
import { LoadingView, ErrorView } from '../components/LoadingView';
import { promptAction, share, router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct ArticleDetail {
  @State article: Article | null = null;
  @State htmlContent: string = '';
  @State isLoading: boolean = true;
  @State isOffline: boolean = false;
  @State errorMessage: string = '';
  @State isFavorite: boolean = false;

  private cacheManager: CacheManager = CacheManager.getInstance();
  private httpUtil: HttpUtil = HttpUtil.getInstance();
  private webviewController: webview.WebviewController = new webview.WebviewController();

  async aboutToAppear() {
    await this.cacheManager.init(getContext(this));
    
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params?.article) {
      this.article = JSON.parse(params.article) as Article;
      await this.checkFavoriteStatus();
      await this.loadArticleContent();
    }
  }

  async checkFavoriteStatus() {
    if (this.article) {
      this.isFavorite = await this.cacheManager.isFavorite(this.article.id);
    }
  }

  async loadArticleContent() {
    if (!this.article) return;

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 先检查缓存
      const cachedHtml = await this.cacheManager.getCachedArticleHtml(this.article.id);
      
      if (cachedHtml) {
        this.htmlContent = cachedHtml;
        this.isOffline = true;
        this.isLoading = false;
        return;
      }

      // 无缓存，从网络获取
      const hasNetwork = await this.httpUtil.checkNetwork();
      
      if (!hasNetwork) {
        this.errorMessage = '无网络连接，该文章未缓存';
        this.isLoading = false;
        return;
      }

      const html = await this.httpUtil.fetchArticleHtml(this.article.file);
      this.htmlContent = html;
      this.isOffline = false;

      // 缓存文章
      await this.cacheManager.cacheArticleHtml(this.article, html);
    } catch (err) {
      this.errorMessage = '加载失败：' + (err as Error).message;
    } finally {
      this.isLoading = false;
    }
  }

  async toggleFavorite() {
    if (!this.article) return;

    if (this.isFavorite) {
      await this.cacheManager.removeFavorite(this.article.id);
      this.isFavorite = false;
      promptAction.showToast({ message: '已取消收藏' });
    } else {
      await this.cacheManager.addFavorite(this.article);
      this.isFavorite = true;
      promptAction.showToast({ message: '已收藏' });
    }
  }

  async shareArticle() {
    if (!this.article) return;
    
    const shareUrl = `https://c8x1.github.io/${this.article.file}`;
    
    try {
      await share.share({
        title: this.article.title,
        content: this.article.summary,
        url: shareUrl
      });
    } catch {
      // 用户取消不提示
    }
  }

  async cacheOffline() {
    if (!this.article || this.isOffline) return;

    promptAction.showToast({ message: '已缓存，可离线阅读' });
  }

  build() {
    Navigation() {
      Column() {
        if (this.isLoading) {
          LoadingView({ message: '加载文章内容...' })
        } else if (this.errorMessage) {
          ErrorView({
            message: this.errorMessage,
            onRetry: () => this.loadArticleContent()
          })
        } else {
          Column() {
            // 离线提示
            if (this.isOffline) {
              Row() {
                Image($r('app.media.icon_offline'))
                  .width(16)
                  .height(16)
                  .fillColor('#FF9800')
                  .margin({ right: 6 })
                Text('离线模式 - 使用缓存内容')
                  .fontSize(12)
                  .fontColor('#FF9800')
              }
              .width('100%')
              .backgroundColor('#FFF3E0')
              .padding(8)
              .justifyContent(FlexAlign.Center)
            }

            // 文章内容
            Web({
              src: '',
              controller: this.webviewController
            })
            .width('100%')
            .layoutWeight(1)
            .onPageBegin(() => {
              // 注入HTML内容
              if (this.htmlContent) {
                this.webviewController.loadData(
                  this.htmlContent,
                  'text/html',
                  'UTF-8'
                );
              }
            })
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
    }
    .title(this.article?.title ?? '文章详情')
    .titleMode(NavigationTitleMode.Mini)
    .menus([
      {
        value: '',
        icon: this.isFavorite ? $r('app.media.icon_favorite_filled') : $r('app.media.icon_favorite'),
        action: () => this.toggleFavorite()
      },
      {
        value: '',
        icon: $r('app.media.icon_share'),
        action: () => this.shareArticle()
      },
      {
        value: '',
        icon: $r('app.media.icon_download'),
        action: () => this.cacheOffline()
      }
    ])
    .onBackPressed(() => {
      router.back();
      return true;
    })
  }
}