## 使用说明
UserIDInput 是用户名输入框。

## 接受参数
| 参数             | 类型         | 说明                                    |
| :-------------- | :------------|:-------------------------------------- |
| defaultValue    | String       | 默认的 userID, 不传入默认值时获取url中的 userID参数，没有参数时提供随机 userID|
| onChange        | Function     | userID 发生改变时通知页面                  |
| disabled        | Boolean      | 是否不可更改               |
| label           | Boolean      | 根据 url 中的 label 对应的值设置默认值, 默认为'userID' ｜

## 使用示例
```javascript
import UserIDInput from '@components/UserIDInput';

function app() {
  const handleUserIDChange = (userID) => {

  }

  return (
    <UserIDInput onChange={handleUserIDChange}></UserIDInput>
  )
}
```
