import React, { useEffect } from 'react';
import { Message, Dropdown, Icon } from 'element-react';

interface UserListProps {
  rtcClient: any,
  role: string,
  tab: string,
  memberList: any,
  getMemberList: Function,
  isBegin: boolean
}

export default function UserList(props: UserListProps) {
  const {rtcClient, role, tab, isBegin} = props;
  const memberList = props.memberList;
  useEffect(() => {
    if(tab === '2') {//成员列表
      props.getMemberList()
    }
  }, [tab])

  function finishAnswering(toUserID:string) {
    rtcClient.finishAnswering(toUserID).then(() => {
      Message({
        message: '禁言成功',
        type: 'success'
      });
    }).catch(() => {
      Message({
        message: '禁言失败',
        type: 'error'
      });
    });
  }
  //点名学生发言
  function inviteToPlatform(toUserID:string) {
    rtcClient.inviteToPlatform(toUserID).then(() => {
      Message({
        message: '邀请学生发言成功',
        type: 'success'
      });
    }).catch(() => {
      Message({
        message: '邀请学生发言失败',
        type: 'error'
      });
    });
  }
  return (
    <div style={{height: 500, overflowY: 'auto', padding: 10}}>
      {
        memberList && memberList.map((item:any) => {
          return (
            <div style={{position: 'relative', height: 40, lineHeight: '40px', borderBottom: '1px solid #111'}} key={item['userID']}>{item['userID']}{item['nick'] ? '-' + item['nick'] : ''}{item['role'] === 'Owner' ? '(老师)' : '' }
              {role === 'teacher' && item['role'] !== 'Owner' && isBegin ?
              <Dropdown style={{position: 'absolute',right:0}} menu={(
                <Dropdown.Menu style={{width: 100}}>
                  <Dropdown.Item>
                    <p onClick={() => finishAnswering(item['userID'])}>禁言</p>
                  </Dropdown.Item>
                  <Dropdown.Item>
                    <p onClick={() => inviteToPlatform(item['userID'])}>点名</p>
                  </Dropdown.Item>
                </Dropdown.Menu>
                )}
              >
                <span className="el-dropdown-link">
                  <Icon style={{cursor: 'pointer'}} name={'setting'} />
                </span>
              </Dropdown>
              : null}
            </div>
          )
        })
      }
    </div>
  )
}
