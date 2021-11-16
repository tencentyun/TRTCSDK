import React, { useEffect, useState } from 'react';

function ClassTime(props: any) {
  const { enterRoomTime } = props;
  const [second, setSecond] = useState(0);
  const [minutes, setMinutes] = useState(0);
  const [hour, setHour] = useState(0);

  useEffect(() => {
    console.warn('class-room-time useEffect enterRoomTime:', enterRoomTime);
    let timer: ReturnType<typeof setInterval> | null = null;
    if (enterRoomTime && enterRoomTime > 0) {
      timer = setInterval(() => {
        const currentTime = new Date().getTime();
        const diffTime = currentTime - enterRoomTime;
        const count = diffTime / 1000;
        const secondTime = parseInt((count % 60).toString(), 10);
        const minutesTime = parseInt(((count / 60) % 60).toString(), 10);
        const hourTime = parseInt((count / 60 / 60).toString(), 10);
        setHour(hourTime);
        setMinutes(minutesTime);
        setSecond(secondTime);
      }, 1000);
    }
    return () => {
      if (timer) {
        clearInterval(timer);
      }
    };
  }, [enterRoomTime]);

  return (
    <span className="class-time">
      {hour > 9 ? hour : `0${hour}`}:{minutes > 9 ? minutes : `0${minutes}`}:
      {second > 9 ? second : `0${second}`}
    </span>
  );
}

export default ClassTime;
