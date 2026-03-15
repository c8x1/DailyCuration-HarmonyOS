import { Article, ArticlesData } from '../model/ArticleModel';
import { http } from '@kit.NetworkKit';
import { Constants } from '../common/Constants';

export class HttpUtil {
  private static instance: HttpUtil;

  static getInstance(): HttpUtil {
    if (!HttpUtil.instance) {
      HttpUtil.instance = new HttpUtil();
    }
    return HttpUtil.instance;
  }

  // 获取文章列表
  async fetchArticles(): Promise<Article[]> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      httpRequest.request(Constants.ARTICLES_JSON_URL, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      }, (err, data) => {
        httpRequest.destroy();
        if (err) {
          reject(err);
          return;
        }
        try {
          const result = JSON.parse(data.result as string) as ArticlesData;
          resolve(result.articles);
        } catch (e) {
          reject(e);
        }
      });
    });
  }

  // 获取文章HTML内容
  async fetchArticleHtml(filePath: string): Promise<string> {
    const url = `${Constants.BASE_URL}/${filePath}`;
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'text/html'
        },
        connectTimeout: 15000,
        readTimeout: 15000
      }, (err, data) => {
        httpRequest.destroy();
        if (err) {
          reject(err);
          return;
        }
        resolve(data.result as string);
      });
    });
  }

  // 检查网络状态
  async checkNetwork(): Promise<boolean> {
    try {
      const httpRequest = http.createHttp();
      return new Promise((resolve) => {
        httpRequest.request(Constants.ARTICLES_JSON_URL, {
          method: http.RequestMethod.HEAD,
          connectTimeout: 5000,
          readTimeout: 5000
        }, (err) => {
          httpRequest.destroy();
          resolve(!err);
        });
      });
    } catch {
      return false;
    }
  }
}