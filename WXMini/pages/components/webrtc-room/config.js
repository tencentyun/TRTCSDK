const CONSTANT = {
  TEMPLATE_TYPE: {
    'BIGSMALL': 'bigsmall' // 大小画面
  },

  IM: {
    LOGIN_EVENT: 'login_event', // 登录事件
    JOIN_GROUP_EVENT: 'join_group_event', // 创建|加入群组事件
    CONNECTION_EVENT: 'connection_event', // 连接状态事件
    BIG_GROUP_MSG_NOTIFY: 'big_group_msg_notify', // 大群消息通知
    MSG_NOTIFY: 'msg_notify', // 普通群消息
    GROUP_SYSTEM_NOTIFYS: 'group_system_notifys', // 监听（多终端同步）群系统消息事件，必填
    GROUP_INFO_CHANGE_NOTIFY: 'group_info_change_notify', // 监听群资料变化事件，选填
    KICKED: 'kicked' // 被踢下线
  }
}

module.exports = CONSTANT;