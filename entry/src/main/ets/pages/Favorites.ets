import { FavoriteArticle } from '../model/ArticleModel';
import { CacheManager } from '../model/CacheManager';
import { ArticleCard } from '../components/ArticleCard';
import { EmptyView } from '../components/LoadingView';
import { promptAction, share, router } from '@kit.ArkUI';

@Entry
@Component
struct Favorites {
  @State favorites: FavoriteArticle[] = [];
  @State isLoading: boolean = true;

  private cacheManager: CacheManager = CacheManager.getInstance();

  async aboutToAppear() {
    await this.cacheManager.init(getContext(this));
    await this.loadFavorites();
  }

  async loadFavorites() {
    this.isLoading = true;
    this.favorites = await this.cacheManager.getFavorites();
    this.isLoading = false;
  }

  async removeFavorite(article: FavoriteArticle) {
    await this.cacheManager.removeFavorite(article.id);
    this.favorites = this.favorites.filter(f => f.id !== article.id);
    promptAction.showToast({ message: '已取消收藏' });
  }

  async shareArticle(article: FavoriteArticle) {
    const shareUrl = `https://c8x1.github.io/${article.file}`;
    
    try {
      await share.share({
        title: article.title,
        content: article.summary,
        url: shareUrl
      });
    } catch {
      // 用户取消
    }
  }

  goToDetail(article: FavoriteArticle) {
    router.pushUrl({
      url: 'pages/ArticleDetail',
      params: { article: JSON.stringify(article) }
    });
  }

  build() {
    Navigation() {
      Column() {
        if (this.favorites.length === 0) {
          EmptyView({ message: '暂无收藏文章' })
        } else {
          List({ space: 12 }) {
            ForEach(this.favorites, (article: FavoriteArticle) => {
              ListItem() {
                ArticleCard({
                  article: article,
                  isFavorite: true,
                  onCardClick: () => this.goToDetail(article),
                  onFavoriteClick: () => this.removeFavorite(article),
                  onShareClick: () => this.shareArticle(article)
                })
              }
              .swipeAction({
                end: {
                  builder: () => {
                    this.DeleteButton(article)
                  }
                }
              })
            })
          }
          .width('100%')
          .height('100%')
          .padding(16)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Auto)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('我的收藏')
    .titleMode(NavigationTitleMode.Mini)
    .onBackPressed(() => {
      router.back();
      return true;
    })
  }

  @Builder
  DeleteButton(article: FavoriteArticle) {
    Button() {
      Image($r('app.media.icon_delete'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
    }
    .width(60)
    .height('100%')
    .backgroundColor('#F44336')
    .onClick(() => {
      this.removeFavorite(article);
    })
  }
}