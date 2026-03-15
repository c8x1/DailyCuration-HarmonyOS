import { CacheManager } from '../model/CacheManager';
import { NotificationUtil } from '../utils/NotificationUtil';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct Settings {
  @State cacheSize: string = '0 KB';
  @State notificationEnabled: boolean = true;
  @State autoCache: boolean = true;

  private cacheManager: CacheManager = CacheManager.getInstance();

  async aboutToAppear() {
    await this.cacheManager.init(getContext(this));
    await this.calculateCacheSize();
    
    // 读取设置
    this.notificationEnabled = AppStorage.get('notification_enabled') ?? true;
    this.autoCache = AppStorage.get('auto_cache') ?? true;
  }

  async calculateCacheSize() {
    const size = await this.cacheManager.getCacheSize();
    // 转换为可读格式
    if (size < 1024) {
      this.cacheSize = `${size} B`;
    } else if (size < 1024 * 1024) {
      this.cacheSize = `${(size / 1024).toFixed(1)} KB`;
    } else {
      this.cacheSize = `${(size / (1024 * 1024)).toFixed(2)} MB`;
    }
  }

  async clearCache() {
    await this.cacheManager.clearExpiredCache();
    await this.calculateCacheSize();
    promptAction.showToast({ message: '已清理过期缓存' });
  }

  async clearAllCache() {
    await this.cacheManager.clearAllCache();
    await this.calculateCacheSize();
    promptAction.showToast({ message: '缓存已清空' });
  }

  toggleNotification(enabled: boolean) {
    this.notificationEnabled = enabled;
    AppStorage.setOrCreate('notification_enabled', enabled);
    promptAction.showToast({ 
      message: enabled ? '已开启推送通知' : '已关闭推送通知' 
    });
  }

  toggleAutoCache(enabled: boolean) {
    this.autoCache = enabled;
    AppStorage.setOrCreate('auto_cache', enabled);
    promptAction.showToast({ 
      message: enabled ? '已开启自动缓存' : '已关闭自动缓存' 
    });
  }

  async testNotification() {
    await NotificationUtil.sendNotification(
      '测试通知',
      '这是一条测试推送消息'
    );
    promptAction.showToast({ message: '测试通知已发送' });
  }

  build() {
    Navigation() {
      List() {
        // 通知设置
        ListItemGroup({ header: this.SectionHeader('通知设置') }) {
          ListItem() {
            Row() {
              Text('每日文章推送')
                .fontSize(16)
                .fontColor('#212121')
              
              Blank()
              
              Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
                .onChange((isOn: boolean) => {
                  this.toggleNotification(isOn);
                })
            }
            .width('100%')
            .padding(16)
          }

          ListItem() {
            Row() {
              Text('自动离线缓存')
                .fontSize(16)
                .fontColor('#212121')
              
              Blank()
              
              Toggle({ type: ToggleType.Switch, isOn: this.autoCache })
                .onChange((isOn: boolean) => {
                  this.toggleAutoCache(isOn);
                })
            }
            .width('100%')
            .padding(16)
          }

          ListItem() {
            Row() {
              Text('测试推送通知')
                .fontSize(16)
                .fontColor('#212121')
              
              Blank()
              
              Image($r('app.media.icon_arrow_right'))
                .width(20)
                .height(20)
                .fillColor('#BDBDBD')
            }
            .width('100%')
            .padding(16)
            .onClick(() => this.testNotification())
          }
        }
        .divider({ strokeWidth: 0.5, color: '#E0E0E0' })

        // 缓存管理
        ListItemGroup({ header: this.SectionHeader('缓存管理') }) {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text('缓存大小')
                  .fontSize(16)
                  .fontColor('#212121')
                Text(this.cacheSize)
                  .fontSize(12)
                  .fontColor('#9E9E9E')
              }
              
              Blank()
              
              Button('清理过期缓存')
                .fontSize(12)
                .fontColor('#2196F3')
                .backgroundColor('#E3F2FD')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(4)
                .onClick(() => this.clearCache())
            }
            .width('100%')
            .padding(16)
          }

          ListItem() {
            Row() {
              Text('清空所有缓存')
                .fontSize(16)
                .fontColor('#F44336')
              
              Blank()
              
              Image($r('app.media.icon_arrow_right'))
                .width(20)
                .height(20)
                .fillColor('#BDBDBD')
            }
            .width('100%')
            .padding(16)
            .onClick(() => this.clearAllCache())
          }
        }
        .divider({ strokeWidth: 0.5, color: '#E0E0E0' })

        // 关于
        ListItemGroup({ header: this.SectionHeader('关于') }) {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text('每日精选')
                  .fontSize(16)
                  .fontColor('#212121')
                Text('版本 1.0.0')
                  .fontSize(12)
                  .fontColor('#9E9E9E')
              }
            }
            .width('100%')
            .padding(16)
          }

          ListItem() {
            Row() {
              Text('数据来源')
                .fontSize(16)
                .fontColor('#212121')
              
              Blank()
              
              Text('c8x1.github.io')
                .fontSize(14)
                .fontColor('#757575')
            }
            .width('100%')
            .padding(16)
          }
        }
        .divider({ strokeWidth: 0.5, color: '#E0E0E0' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      .divider({ strokeWidth: 0 })
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .onBackPressed(() => {
      router.back();
      return true;
    })
  }

  @Builder
  SectionHeader(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor('#757575')
      .fontWeight(FontWeight.Medium)
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }
}