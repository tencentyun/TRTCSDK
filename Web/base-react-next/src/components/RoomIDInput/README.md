## 使用说明
RoomIDInput 是用户名输入框。

RoomIDInput 会根据 url 中的参数 useStringRoomID 确定是提供数字类型的 roomID, 还是提供字符串类型的 roomID

## 接受参数
| 参数             | 类型         | 说明                                    |
| :-------------- | :------------|:-------------------------------------- |
| defaultValue    | String       | 默认的 roomID, 不传入默认值时获取url中的 roomID 参数，没有参数时提供随机 roomID|
| onChange        | Function     | roomID 发生改变时通知页面                  |
| disabled        | Boolean      | 是否不可更改               |

## 使用示例
```javascript
import RoomIDInput from '@components/RoomIDInput';

function app() {
  const handleRoomIDChange = (userID) => {

  }

  return (
    <RoomIDInput disabled={false} onChange={handleRoomIDChange}></RoomIDInput>
  )
}
```
