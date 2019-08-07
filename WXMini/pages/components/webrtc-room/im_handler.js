const webim = require('./webim_wx');

module.exports = {
  initData(userData, groupData = {}) {
    this.userData = userData || {};
    this.userData['accountType'] = 1;

    this.groupData = groupData || {};
    this.groupData['sessionType'] = webim.SESSION_TYPE.GROUP;
    this.selSess = null; // 当前会话
    this.selSessHeadUrl = null; // 当前会话头像
  },

  /**
   * 初始化登录IM的监听函数
   * @param {Object} loginListeners 
   */
  initLoginListeners(loginListeners) {
    this.loginListeners = loginListeners;
  },

  /**
   * 登录IM
   * @param {Function} success 
   * @param {Function} fail 
   */
  loginIm(success, fail) {
    if (!webim.checkLogin()) {
      webim.login(this.userData, this.loginListeners, {
        isAccessFormalEnv: true,
        isLogOn: false
      }, success, fail);
    }
  },

  /**
   * 注销IM
   */
  logout() {
    if (webim.checkLogin()) {
      webim.logout();
    }
  },

  /**
   * 创建群组
   * @param {*} groupId 群组ID
   * @param {*} userID 用户ID
   * @param {*} succ 成功回调
   * @param {*} fail 失败回调
   */
  createGroup(groupId, userID, succ, fail) {
    var options = {
      'GroupId': String(groupId),
      'Owner_Account': String(userID),
      'Type': "AVChatRoom", //Private/Public/ChatRoom/AVChatRoom
      'ApplyJoinOption': 'FreeAccess',
      'Name': String(groupId),
      'Notification': "",
      'Introduction': "",
      'MemberList': [],
    };

    webim.createGroup(
      options,
      function (resp) {
        if (succ) succ();
      },
      function (err) {
        if (err.ErrorCode == 10025 || err.ErrorCode == 10021) {
          if (succ) succ();
        } else {
          if (fail) fail(err);
        }
      }
    );
  },

  /**
   * 加入群组
   * @param {*} groupId 群组ID
   * @param {*} succ 成功回调
   * @param {*} fail 失败回调
   */
  joinGroup(groupId, succ, fail) {
    var self = this;
    this.selSess = null;
    // 先创建群，成功后加入群
    this.createGroup(groupId, this.userData.identifier, () => {
      webim.applyJoinBigGroup({
          GroupId: String(groupId)
        },
        function (resp) {
          //JoinedSuccess:加入成功; WaitAdminApproval:等待管理员审批
          if (resp.JoinedStatus && resp.JoinedStatus == 'JoinedSuccess') {
            self.groupData['groupId'] = groupId;
            succ && succ(resp);
          } else {
            fail && fail(resp);
          }
        },
        function (err) {
          if (err.ErrorCode == 10013) { // 被邀请加入的用户已经是群成员,也表示成功
            self.groupData['groupId'] = groupId;
            console.warn('applyJoinGroupSucc', groupId)
            return;
          }
          if (fail) {
            fail(err);
          }
        }
      );
    }, fail);
  },

  /**
   * 发送C2C文本消息
   * @param {string} msg 
   * @param {function} succ 
   * @param {function} fail
   */
  sendC2CTextMsg(receiveUser, msg, succ, fail) {
    this.sendTextMessage(webim.SESSION_TYPE.C2C, receiveUser, msg, succ, fail);
  },

  /**
   * 发送C2C自定义消息
   * @param {object} msgObj {data: 'xxx', desc: 'xxxx', ext: 'xxxx'}
   * @param {function} succ
   * @param {function} fail
   */
  sendC2CCustomMsg(toUser, msgObj, succ, fail) {
    this.sendCustomMsg(webim.SESSION_TYPE.C2C, toUser, msgObj, succ, fail);
  },


  /**
   * 发送群组文本消息
   * @param {string} msg 
   * @param {function} succ 
   * @param {function} fail
   */
  sendGroupTextMsg(msg, succ, fail) {
    this.sendTextMessage(webim.SESSION_TYPE.GROUP, null, msg, succ, fail);
  },

  /**
   * 发送群组自定义消息
   * @param {object} msgObj {data: 'xxx', desc: 'xxxx', ext: 'xxxx'}
   * @param {function} succ
   * @param {function} fail
   */
  sendGroupCustomMsg(msgObj, succ, fail) {
    this.sendCustomMsg(webim.SESSION_TYPE.GROUP, null, msgObj, succ, fail);
  },

  /**
   * 发送普通文本消息
   * @param {*} selType 接收方类型（个人/群组）
   * @param {*} msgText 消息内容
   * @param {*} toUser 接收方ID
   */
  sendTextMessage(selType, toUser, msgText, succ, fail) {
    var maxLen, errInfo;
    if (selType == webim.SESSION_TYPE.C2C) {
      if (!toUser) {
        fail && fail(-1, '没有接收人');
        return;
      }
      maxLen = webim.MSG_MAX_LENGTH.C2C;
      errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    } else {
      maxLen = webim.MSG_MAX_LENGTH.GROUP;
      errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    }

    if (msgText.length < 1) {
      fail && fail(-2, '不能发送空消息');
      return;
    }
    var msgLen = webim.Tool.getStrBytes(msgText);

    if (msgLen > maxLen) {
      fail && fail(-3, errInfo);
      return;
    }

    var selSess = null;
    var subType; //消息子类型

    // 如果是发给群组
    if (selType == webim.SESSION_TYPE.GROUP) {
      var groupId = this.groupData['groupId'];
      selSess = new webim.Session(webim.SESSION_TYPE.GROUP, groupId, groupId);
      subType = webim.GROUP_MSG_SUB_TYPE.COMMON;
    } else {
      subType = webim.C2C_MSG_SUB_TYPE.COMMON;
      selSess = new webim.Session(selType, toUser, toUser, '', this.getUnixTimestamp());
    }

    var isSend = true; //是否为自己发送
    var seq = -1; //消息序列，-1表示 SDK 自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296); //消息随机数，用于去重
    var msgTime = this.getUnixTimestamp(); //消息时间戳
    var msg = new webim.Msg(selSess, isSend, seq, random, msgTime, this.userData.identifier, subType, this.userData.identifierNick);
    var text_obj, face_obj, tmsg, emotionIndex, emotion, restMsgIndex;

    //解析文本和表情
    var expr = /\[[^[\]]{1,3}\]/mg;
    var emotions = msgText.match(expr);
    if (!emotions || emotions.length < 1) {
      text_obj = new webim.Msg.Elem.Text(msgText);
      msg.addText(text_obj);
    } else {
      for (var i = 0; i < emotions.length; i++) {
        tmsg = msgText.substring(0, msgText.indexOf(emotions[i]));
        if (tmsg) {
          text_obj = new webim.Msg.Elem.Text(tmsg);
          msg.addText(text_obj);
        }
        emotionIndex = webim.EmotionDataIndexs[emotions[i]];
        emotion = webim.Emotions[emotionIndex];
        if (emotion) {
          face_obj = new webim.Msg.Elem.Face(emotionIndex, emotions[i]);
          msg.addFace(face_obj);
        } else {
          text_obj = new webim.Msg.Elem.Text(emotions[i]);
          msg.addText(text_obj);
        }
        restMsgIndex = msgText.indexOf(emotions[i]) + emotions[i].length;
        msgText = msgText.substring(restMsgIndex);
      }
      if (msgText) {
        text_obj = new webim.Msg.Elem.Text(msgText);
        msg.addText(text_obj);
      }
    }

    webim.sendMsg(msg, function (resp) {
      succ && succ(msg);
    }, function (err) {
      fail && fail(-4, err);
    });
  },

  /**
   * 发送自定义消息
   * @param {*} selType 接收方类型（个人/群组）
   * @param {*} msgObj 消息内容
   * @param {*} toUser 接收方ID
   */
  sendCustomMsg(selType, toUser, msgObj, succ, fail) {
    var maxLen, errInfo;
    if (selType == webim.SESSION_TYPE.C2C) {
      if (!toUser) {
        event.fire(this, Constant.EVENT.IM.SEND_CHAT_MSG_EMPTY_RECEIVE_ERROR, JSON.stringify(msgObj));
        fail && fail(-1, '没有接收人');
        return;
      }
      maxLen = webim.MSG_MAX_LENGTH.C2C;
      errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    } else {
      maxLen = webim.MSG_MAX_LENGTH.GROUP;
      errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    }

    var data = msgObj.data + '';
    var desc = msgObj.desc;
    var ext = msgObj.ext;

    var msgLen = webim.Tool.getStrBytes(data);
    if (data.length < 1) {
      fail && fail(-2, '不能发送空消息');
      return;
    }

    if (msgLen > maxLen) {
      fail && fail(-3, errInfo);
      return;
    }

    var selSess = null;
    var subType; //消息子类型

    // 如果是发给群组
    if (selType == webim.SESSION_TYPE.GROUP) {
      var groupId = this.groupData['groupId'];
      selSess = new webim.Session(webim.SESSION_TYPE.GROUP, groupId, groupId);
      subType = webim.GROUP_MSG_SUB_TYPE.COMMON;
    } else {
      selSess = new webim.Session(selType, toUser, toUser, '', this.getUnixTimestamp());
      subType = webim.C2C_MSG_SUB_TYPE.COMMON;
    }

    var isSend = true; //是否为自己发送
    var seq = -1; //消息序列，-1表示 SDK 自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296); //消息随机数，用于去重
    var msgTime = this.getUnixTimestamp(); //消息时间戳

    var msg = new webim.Msg(selSess, isSend, seq, random, msgTime, this.userData.identifier, subType, this.userData.identifierNick);

    var custom_obj = new webim.Msg.Elem.Custom(data, desc, ext);
    msg.addCustom(custom_obj);
    //调用发送消息接口
    webim.sendMsg(msg, function (resp) {
      // if (selType == webim.SESSION_TYPE.C2C) { //私聊时，在聊天窗口手动添加一条发的消息，群聊时，长轮询接口会返回自己发的消息
      //   succ && succ(msg);
      // }
      succ && succ(msg);
    }, function (err) {
      fail && fail(-4, err);
    });
  },

  /**
   * 获取unixTimestamp时间戳
   */
  getUnixTimestamp() {
    return Math.round(new Date().getTime() / 1000);
  },

  /**
   * 组织自定义消息体
   * @param {*} msg 要发送的消息
   * @param {*} succ 
   */
  formatCustomMsg(msg) {
    // custom消息
    var data = msg.data || '';
    var desc = msg.desc || '';
    var ext = msg.ext || '';

    if (!this.selSess) {
      this.selSess = new webim.Session(this.groupData.sessionType, this.groupData.groupId, this.groupData.groupId, this.selSessHeadUrl, Math.round(new Date().getTime() / 1000));
    }

    var isSend = true; //是否为自己发送
    var seq = -1; //消息序列，-1表示sdk自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296); //消息随机数，用于去重
    var msgTime = Math.round(new Date().getTime() / 1000); //消息时间戳
    var subType; //消息子类型
    if (this.groupData.sessionType == webim.SESSION_TYPE.GROUP) {
      //群消息子类型如下：
      //webim.GROUP_MSG_SUB_TYPE.COMMON-普通消息,
      //webim.GROUP_MSG_SUB_TYPE.LOVEMSG-点赞消息，优先级最低
      //webim.GROUP_MSG_SUB_TYPE.TIP-提示消息(不支持发送，用于区分群消息子类型)，
      //webim.GROUP_MSG_SUB_TYPE.REDPACKET-红包消息，优先级最高
      subType = webim.GROUP_MSG_SUB_TYPE.COMMON;
    } else {
      //C2C消息子类型如下：
      //webim.C2C_MSG_SUB_TYPE.COMMON-普通消息,
      subType = webim.C2C_MSG_SUB_TYPE.COMMON;
    }
    var msg = new webim.Msg(this.selSess, isSend, seq, random, msgTime, this.userData.identifier, subType, this.userData.identifierNick);

    var custom_obj = new webim.Msg.Elem.Custom(data, desc, ext);
    msg.addCustom(custom_obj);
    return msg;
  },

  /**
   * G
   * @param {*} toUserID 
   * @param {*} msg 
   */
  formatC2CCustomMsg(toUserID, msg) {
    // custom消息
    var data = msg.data || '';
    var desc = msg.desc || '';
    var ext = msg.ext || '';

    var msgLen = webim.Tool.getStrBytes(data);

    var session = new webim.Session(webim.SESSION_TYPE.C2C, toUserID, toUserID, '', Math.round(new Date().getTime() / 1000));
    var isSend = true; //是否为自己发送
    var seq = -1; //消息序列，-1表示sdk自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296); //消息随机数，用于去重
    var msgTime = Math.round(new Date().getTime() / 1000); //消息时间戳
    var subType = webim.C2C_MSG_SUB_TYPE.COMMON; //消息子类型 
    var msg = new webim.Msg(session, isSend, seq, random, msgTime, this.userData.identifier, subType, this.userData.identifierNick);

    var custom_obj = new webim.Msg.Elem.Custom(data, desc, ext);
    msg.addCustom(custom_obj);
    return msg;
  }
}