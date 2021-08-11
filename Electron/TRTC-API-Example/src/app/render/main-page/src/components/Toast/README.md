## 使用说明
Toast 用来进行消息显示。

## 参数
| 参数        | 类型              | 说明          |
| :--------- | :---------------- |:------------- |
| message    | String            | notification 展示的信息         |
| duration   | Function          | notification 显示的时间         |
| onClose    | Function          | notification 关闭之后执行该回调函数   |

## 使用示例
```javascript
// 1. 全局引入 notification 组件
import Notification from '@components/Toast/notification';

function MyApp({ Component, pageProps }) {
  return (
      <Component {...pageProps} />
      <Notification></Notification>
  );
}
```

```javascript
// 2. 在组件中使用 toast
import toast from '@components/Toast'

toast.info('info', 2000, () => {});
toast.success('info', 2000, () => {});
toast.warning('info', 2000, () => {});
toast.error('info', 2000, () => {});
toast.loading('info', 2000, () => {});
```
