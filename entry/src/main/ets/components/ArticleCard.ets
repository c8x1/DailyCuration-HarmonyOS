import { Article } from '../model/ArticleModel';

@Component
export struct ArticleCard {
  @Prop article: Article;
  @Prop isFavorite: boolean = false;
  onCardClick?: () => void;
  onFavoriteClick?: () => void;
  onShareClick?: () => void;

  build() {
    Column() {
      // 分类标签
      Row() {
        ForEach(this.article.category, (cat: string, index: number) => {
          Text(cat)
            .fontSize(10)
            .fontColor('#2196F3')
            .backgroundColor('#E3F2FD')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ right: index < this.article.category.length - 1 ? 6 : 0 })
        })
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 标题
      Text(this.article.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 4 })

      // 英文副标题
      Text(this.article.subtitle)
        .fontSize(12)
        .fontColor('#757575')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 8 })

      // 摘要
      Text(this.article.summary)
        .fontSize(13)
        .fontColor('#616161')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 10 })

      // 底部信息栏
      Row() {
        Row() {
          Text(this.article.author)
            .fontSize(11)
            .fontColor('#9E9E9E')
          
          Text(' · ')
            .fontSize(11)
            .fontColor('#BDBDBD')
          
          Text(`${this.article.stats.readTime}分钟阅读`)
            .fontSize(11)
            .fontColor('#9E9E9E')
        }

        Blank()

        // 操作按钮
        Row({ space: 12 }) {
          // 分享按钮
          Button() {
            Image(this.isFavorite ? $r('app.media.icon_favorite_filled') : $r('app.media.icon_favorite'))
              .width(20)
              .height(20)
              .fillColor(this.isFavorite ? '#FF4081' : '#9E9E9E')
          }
          .type(ButtonType.Circle)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.onFavoriteClick?.();
          })

          // 分享按钮
          Button() {
            Image($r('app.media.icon_share'))
              .width(20)
              .height(20)
              .fillColor('#9E9E9E')
          }
          .type(ButtonType.Circle)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.onShareClick?.();
          })
        }
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(16)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.08)',
      offsetY: 2
    })
    .onClick(() => {
      this.onCardClick?.();
    })
  }
}