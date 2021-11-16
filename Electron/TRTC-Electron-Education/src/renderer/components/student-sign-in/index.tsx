import React, { useEffect, useState } from 'react';
import { trtcUtil } from 'renderer/utils/trtc-edu-sdk';
import { clearInterval } from 'timers';
import './index.scss';

function StudentSignIn(props: any) {
  const { callRollTime, userID } = props;
  const [time, setTime] = useState(0);
  const logPrefix = 'StudentSignIn';

  console.warn(`${logPrefix}.callRollTime:`, callRollTime, time);
  useEffect(() => {
    let timer: ReturnType<typeof setInterval> | null = null;
    if (callRollTime && callRollTime > 0) {
      setTime(callRollTime);
      timer = setTimeout(() => {
        setTime(0);
      }, callRollTime * 1000);
    }
    return () => {
      if (timer) {
        clearInterval(timer);
      }
    };
  }, [callRollTime]);

  const signOn = () => {
    setTime(0);
    const currentTime = new Date().getTime();
    trtcUtil.trtcEducation?.callRollReply(
      userID,
      currentTime,
      trtcUtil.trtcEducation.ownerID
    );
  };

  return (
    <div
      className={callRollTime > 0 && time > 0 ? 'sign-in' : 'sign-out'}
      onClick={signOn}
    >
      {' '}
      签到
    </div>
  );
}

export default StudentSignIn;
