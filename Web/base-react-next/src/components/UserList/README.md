stream 组件使用说明

参数说明：

```javascript
list {Array}

@param {String} type 类型 local 本地 remote 远端 必填

@param {String} userID 用户ID 必填

@param {Boolean} video 视频初始状态 选填 默认 true

@param {Boolean} audio 音频初始状态 选填 默认 true

@param {Boolean} mic 话筒初始状态 选填 默认 true

@param {Boolean} shareDesk 共享桌面初始状态 选填 默认 true
```

使用说明：

```js
import UserList from "@components/userList";
 <UserList list={this.state.list}></UserList>
```

