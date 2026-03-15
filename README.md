# DailyCuration Minimal

极简版 DailyCuration 鸿蒙应用

## 功能

- 首页：文章列表展示
- 详情页：WebView 浏览文章内容

## 项目结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets  (入口 Ability)
├── pages/
│   ├── Index.ets                  (文章列表页)
│   └── ArticleDetail.ets          (文章详情页)
```

## 技术栈

- ArkUI 声明式UI
- HTTP 网络请求
- WebView 网页浏览
- Router 页面路由

## 编译说明

1. 使用 DevEco Studio 打开项目
2. 同步依赖
3. 构建运行

## 权限

- `ohos.permission.INTERNET` - 网络访问权限
