import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { CacheManager } from '../model/CacheManager';
import { NotificationUtil } from '../utils/NotificationUtil';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化缓存管理器
    CacheManager.getInstance().init(this.context);
    // 初始化通知渠道
    NotificationUtil.initNotificationChannel();
  }

  onDestroy(): void {
    // 清理资源
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 加载主页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('Failed to load the content:', JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // 窗口销毁
  }

  onForeground(): void {
    // 应用进入前台
  }

  onBackground(): void {
    // 应用进入后台
  }
}