const webim = require('../../webrtc-room/webim_wx');

module.exports = {
  /**
   * 处理群组消息
   * @param {*} msgs 
   * @param {*} callback 
   */
  handleGroupMessage(msgs, callback) {
    for (var i = msgs.length - 1; i >= 0; i--) { //遍历消息，按照时间从后往前
      var msg = msgs[i];
      callback && callback(this.showMsg(msg));
    }
  },

  /**
   * 格式化消息
   * @param {*} msg 
   */
  showMsg(msg) {
    var isSelfSend, fromAccount, fromAccountNick, sessType, subType;
    var ul, li, paneDiv, textDiv, nickNameSpan, contentSpan;

    fromAccount = msg.getFromAccount();
    if (!fromAccount) {
      fromAccount = '';
    }
    fromAccountNick = msg.getFromAccountNick();
    if (!fromAccountNick) {
      fromAccountNick = '未知用户';
    }
    //解析消息
    //获取会话类型，目前只支持群聊
    //webim.SESSION_TYPE.GROUP-群聊，
    //webim.SESSION_TYPE.C2C-私聊，
    sessType = msg.getSession().type();
    //获取消息子类型
    //会话类型为群聊时，子类型为：webim.GROUP_MSG_SUB_TYPE
    //会话类型为私聊时，子类型为：webim.C2C_MSG_SUB_TYPE
    subType = msg.getSubType();

    isSelfSend = msg.getIsSend(); //消息是否为自己发的
    var content = "";
    switch (subType) {
      case webim.GROUP_MSG_SUB_TYPE.COMMON: //群普通消息
        content = this.convertMsgtoHtml(msg);
        break;
      case webim.GROUP_MSG_SUB_TYPE.TIP: //群提示消息
        content = "[群提示消息]" + this.convertMsgtoHtml(msg);
        break;
      default:
        wx.showToast({
          title: 'DEMO中展示普通消息'
        });
        break;
    }

    return {
      fromAccountNick: fromAccountNick,
      content: content
    }
  },

  // 将msg转换为html
  convertMsgtoHtml(msg) {
    var html = "",
      elems, elem, type, content;
    elems = msg.getElems(); //获取消息包含的元素数组
    for (var i in elems) {
      elem = elems[i];
      type = elem.getType(); //获取元素类型
      content = elem.getContent(); //获取元素对象
      switch (type) {
        case webim.MSG_ELEMENT_TYPE.TEXT:
          html += this.convertTextMsgToHtml(content);
          break;
        case webim.MSG_ELEMENT_TYPE.CUSTOM:
          html += this.convertCustomMsgToHtml(content);
          break;

        // case webim.MSG_ELEMENT_TYPE.FACE:
        //   html += convertFaceMsgToHtml(content);
        //   break;
        // case webim.MSG_ELEMENT_TYPE.IMAGE:
        //   html += convertImageMsgToHtml(content);
        //   break;
        // case webim.MSG_ELEMENT_TYPE.SOUND:
        //   html += convertSoundMsgToHtml(content);
        //   break;
        // case webim.MSG_ELEMENT_TYPE.FILE:
        //   html += convertFileMsgToHtml(content);
        //   break;
        // case webim.MSG_ELEMENT_TYPE.LOCATION: //暂不支持地理位置
        //   //html += convertLocationMsgToHtml(content);
        //   break;
        case webim.MSG_ELEMENT_TYPE.GROUP_TIP:
          html += this.convertGroupTipMsgToHtml(content);
          break;

        default:
          wx.showToast({
            title: '未知消息元素类型: elemType=' + type
          });
          break;
      }
    }
    return webim.Tool.formatHtml2Text(html);
  },

  /**
   * 群提示消息
   * @param {*} content 
   */
  convertGroupTipMsgToHtml(content) {
    var WEB_IM_GROUP_TIP_MAX_USER_COUNT = 10;
    var text = "";
    var maxIndex = WEB_IM_GROUP_TIP_MAX_USER_COUNT - 1;
    var opType, opUserId, userIdList;
    var memberCount;
    opType = content.getOpType(); //群提示消息类型（操作类型）
    opUserId = content.getOpUserId(); //操作人id
    switch (opType) {
      case webim.GROUP_TIP_TYPE.JOIN: //加入群
        userIdList = content.getUserIdList();
        //text += opUserId + "邀请了";
        for (var m in userIdList) {
          text += userIdList[m] + ",";
          if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + userIdList.length + "人";
            break;
          }
        }
        text = text.substring(0, text.length - 1);
        text += "进入房间";
        text += ';{"type":' + opType + ',"userIdList":"' + userIdList.join(',') + '"}';
        //房间成员数加1
        // memberCount = $('#user-icon-fans').html();
        memberCount = parseInt(memberCount) + 1;
        break;
      case webim.GROUP_TIP_TYPE.QUIT: //退出群
        text += opUserId + "离开房间";
        text += ';{"type":' + opType + ',"userIdList":"' + opUserId + '"}';
        //房间成员数减1
        if (memberCount > 0) {
          memberCount = parseInt(memberCount) - 1;
        }
        break;
      case webim.GROUP_TIP_TYPE.KICK: //踢出群
        text += opUserId + "将";
        userIdList = content.getUserIdList();
        for (var m in userIdList) {
          text += userIdList[m] + ",";
          if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + userIdList.length + "人";
            break;
          }
        }
        text += "踢出该群";
        break;
      case webim.GROUP_TIP_TYPE.SET_ADMIN: //设置管理员
        text += opUserId + "将";
        userIdList = content.getUserIdList();
        for (var m in userIdList) {
          text += userIdList[m] + ",";
          if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + userIdList.length + "人";
            break;
          }
        }
        text += "设为管理员";
        break;
      case webim.GROUP_TIP_TYPE.CANCEL_ADMIN: //取消管理员
        text += opUserId + "取消";
        userIdList = content.getUserIdList();
        for (var m in userIdList) {
          text += userIdList[m] + ",";
          if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + userIdList.length + "人";
            break;
          }
        }
        text += "的管理员资格";
        break;

      case webim.GROUP_TIP_TYPE.MODIFY_GROUP_INFO: //群资料变更
        text += opUserId + "修改了群资料：";
        var groupInfoList = content.getGroupInfoList();
        var type, value;
        for (var m in groupInfoList) {
          type = groupInfoList[m].getType();
          value = groupInfoList[m].getValue();
          switch (type) {
            case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.FACE_URL:
              text += "群头像为" + value + "; ";
              break;
            case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NAME:
              text += "群名称为" + value + "; ";
              break;
            case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.OWNER:
              text += "群主为" + value + "; ";
              break;
            case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NOTIFICATION:
              text += "群公告为" + value + "; ";
              break;
            case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.INTRODUCTION:
              text += "群简介为" + value + "; ";
              break;
            default:
              text += "未知信息为:type=" + type + ",value=" + value + "; ";
              break;
          }
        }
        break;

      case webim.GROUP_TIP_TYPE.MODIFY_MEMBER_INFO: //群成员资料变更(禁言时间)
        text += opUserId + "修改了群成员资料:";
        var memberInfoList = content.getMemberInfoList();
        var userId, shutupTime;
        for (var m in memberInfoList) {
          userId = memberInfoList[m].getUserId();
          shutupTime = memberInfoList[m].getShutupTime();
          text += userId + ": ";
          if (shutupTime != null && shutupTime !== undefined) {
            if (shutupTime == 0) {
              text += "取消禁言; ";
            } else {
              text += "禁言" + shutupTime + "秒; ";
            }
          } else {
            text += " shutupTime为空";
          }
          if (memberInfoList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + memberInfoList.length + "人";
            break;
          }
        }
        break;
      default:
        text += "未知群提示消息类型：type=" + opType;
        break;
    }
    return text;
  },

  convertTextMsgToHtml(content) {
    return content.getText();
  },


  /**
   * 自定义消息转换为字符串
   * @param {*} content 
   */
  convertCustomMsgToHtml(content) {
    var data = content.getData();
    var desc = content.getDesc();
    var ext = content.getExt();
    return JSON.stringify({
      data,
      desc,
      ext
    });
  }
}