import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct ArticleDetail {
  @State webUrl: string = '';
  @State pageTitle: string = '';
  controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    let params = router.getParams() as Record<string, string>;
    if (params) {
      this.webUrl = params['url'] || 'https://www.example.com';
      this.pageTitle = params['title'] || 'Article';
    }
  }

  goBack(): void {
    router.back();
  }

  build() {
    Column() {
      Row() {
        Button($r('app.string.back'))
          .fontSize(14)
          .onClick(() => this.goBack())

        Text(this.pageTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank().width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#f5f5f5')

      Web({ src: this.webUrl, controller: this.controller })
        .width('100%')
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
