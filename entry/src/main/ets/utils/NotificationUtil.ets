import { notificationManager } from '@kit.NotificationKit';
import { Article } from '../model/ArticleModel';
import { Constants } from '../common/Constants';

export class NotificationUtil {
  private static notificationId: number = 1000;

  // 获取下一个通知ID
  private static getNextNotificationId(): number {
    NotificationUtil.notificationId++;
    if (NotificationUtil.notificationId > 999999) {
      NotificationUtil.notificationId = 1000;
    }
    return NotificationUtil.notificationId;
  }

  // 初始化通知渠道
  static async initNotificationChannel(): Promise<void> {
    const channel: notificationManager.NotificationChannel = {
      id: Constants.NOTIFICATION_CHANNEL_ID,
      name: Constants.NOTIFICATION_CHANNEL_NAME,
      description: '每天推送精选文章',
      importance: notificationManager.Importance.IMPORTANCE_HIGH,
      showBadge: true
    };
    await notificationManager.setNotificationChannel(channel);
  }

  // 发送每日文章通知
  static async sendDailyArticleNotification(article: Article): Promise<void> {
    const notification: notificationManager.NotificationRequest = {
      id: NotificationUtil.getNextNotificationId(),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: `📖 今日精选：${article.title}`,
          text: article.summary.substring(0, 50) + '...',
          additionalText: `作者：${article.author}`
        }
      },
      notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      groupName: 'daily_articles',
      removeAfterClicked: true
    };

    await notificationManager.publish(notification);
  }

  // 发送通用通知
  static async sendNotification(title: string, content: string): Promise<void> {
    const notification: notificationManager.NotificationRequest = {
      id: NotificationUtil.getNextNotificationId(),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title,
          text: content
        }
      }
    };

    await notificationManager.publish(notification);
  }

  // 取消所有通知
  static async cancelAllNotifications(): Promise<void> {
    await notificationManager.cancelAllNotifications();
  }
}