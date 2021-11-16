import React, { useState, useEffect } from 'react';
import Notice from './notice';
import Toast from './index';

export default function Notification() {
  const [notices, setNotices] = useState([]);

  const addNotice = (notice) => {
    const key = `${notice.type}_${Date.now()}`;
    const newNotice = {
      key,
      ...notice,
    };
    setNotices([...notices, newNotice]);
  };

  useEffect(() => {
    Toast.info = (message, duration, onClose) => {
      addNotice({ type: 'info', message, duration, onClose });
    };
    Toast.success = (message, duration, onClose) => {
      addNotice({ type: 'success', message, duration, onClose });
    };
    Toast.warning = (message, duration, onClose) => {
      addNotice({ type: 'warning', message, duration, onClose });
    };
    Toast.error = (message, duration, onClose) => {
      addNotice({ type: 'error', message, duration, onClose });
    };
    Toast.loading = (message, duration, onClose) => {
      addNotice({ type: 'loading', message, duration, onClose });
    };
  });

  return (
    notices.length > 0 && (
      // eslint-disable-next-line react/jsx-filename-extension
      <div>
        {notices.map((notice) => (
          // eslint-disable-next-line react/jsx-props-no-spreading
          <Notice key={notice.key} {...notice} />
        ))}
      </div>
    )
  );
}
