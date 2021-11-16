import React from 'react';
import VideoWrapper from './video-wrapper';
import './index.scss';

interface Props {
  userList?: Array<Record<string, any>>;
  mode?: string;
  toggleMicMuteState: (user: Record<string, any>) => void;
}

function VideoList(props: Props) {
  const logPrefix = '[VideoList]';
  const { userList, mode, toggleMicMuteState } = props;

  console.warn(`${logPrefix} props: `, props);

  return (
    <div className={`trtc-edu-video-list list-mode-${mode}`}>
      <div className="video-list-content">
        {userList &&
          userList.length > 0 &&
          userList.map((user: Record<string, any>) => {
            return (
              <VideoWrapper
                key={user.userID}
                user={user}
                toggleMicMuteState={toggleMicMuteState}
              />
            );
          })}
      </div>
    </div>
  );
}

VideoList.defaultProps = {
  userList: [],
  mode: 'horizontal',
};

export default VideoList;
