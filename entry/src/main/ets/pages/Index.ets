import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';

interface Article {
  id: string;
  title: string;
  summary: string;
  url: string;
}

@Entry
@Component
struct Index {
  @State articleList: Article[] = [];
  @State isLoading: boolean = true;
  @State errorMsg: string = '';

  aboutToAppear(): void {
    this.loadArticles();
  }

  loadArticles(): void {
    this.isLoading = true;
    this.errorMsg = '';

    let httpRequest = http.createHttp();
    let url = 'https://api.github.com/repos/trending';

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 10000
      },
      (err, data) => {
        this.isLoading = false;
        if (err) {
          this.errorMsg = 'Load failed, please retry';
          return;
        }
        this.parseArticles(data.result as string);
      }
    );
  }

  parseArticles(result: string): void {
    let mockData: Article[] = [
      { id: '1', title: 'Sample Article 1', summary: 'This is a sample article summary.', url: 'https://www.example.com/1' },
      { id: '2', title: 'Sample Article 2', summary: 'Another sample article for testing.', url: 'https://www.example.com/2' },
      { id: '3', title: 'Sample Article 3', summary: 'Third sample article content here.', url: 'https://www.example.com/3' },
      { id: '4', title: 'Sample Article 4', summary: 'Fourth article in the list view.', url: 'https://www.example.com/4' },
      { id: '5', title: 'Sample Article 5', summary: 'Fifth sample article description.', url: 'https://www.example.com/5' }
    ];
    this.articleList = mockData;
  }

  goToDetail(article: Article): void {
    router.pushUrl({
      url: 'pages/ArticleDetail',
      params: { url: article.url, title: article.title }
    });
  }

  build() {
    Column() {
      Text('Daily Curation')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      if (this.isLoading) {
        Text($r('app.string.loading'))
          .fontSize(16)
          .margin({ top: 50 })
      } else if (this.errorMsg !== '') {
        Column() {
          Text(this.errorMsg)
            .fontSize(16)
            .margin({ bottom: 10 })
          Button($r('app.string.retry'))
            .onClick(() => this.loadArticles())
        }
        .margin({ top: 50 })
      } else {
        List({ space: 12 }) {
          ForEach(this.articleList, (item: Article) => {
            ListItem() {
              Column() {
                Text(item.title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                Text(item.summary)
                  .fontSize(14)
                  .fontColor('#666')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .margin({ top: 8 })
              }
              .padding(16)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .width('100%')
            }
            .onClick(() => this.goToDetail(item))
          })
        }
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }
}
