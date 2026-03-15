@Component
export struct LoadingView {
  @Prop message: string = '加载中...';

  build() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#2196F3')
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#757575')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct EmptyView {
  @Prop message: string = '暂无数据';
  @Prop icon: Resource = $r('app.media.icon_empty');

  build() {
    Column({ space: 16 }) {
      Image(this.icon)
        .width(80)
        .height(80)
        .fillColor('#BDBDBD')
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#9E9E9E')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct ErrorView {
  @Prop message: string = '加载失败';
  onRetry?: () => void;

  build() {
    Column({ space: 16 }) {
      Image($r('app.media.icon_error'))
        .width(80)
        .height(80)
        .fillColor('#F44336')
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#757575')
      
      Button('重试')
        .fontSize(14)
        .fontColor('#2196F3')
        .backgroundColor('#E3F2FD')
        .padding({ left: 24, right: 24, top: 8, bottom: 8 })
        .borderRadius(20)
        .onClick(() => {
          this.onRetry?.();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}