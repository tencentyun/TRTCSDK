import React from 'react';
import AppBar from '@material-ui/core/AppBar';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import Box from '@material-ui/core/Box';
import Im from '../class-room-aside-bottom-im';
import WatchList from '../class-room-aside-bottom-watchList';
import ComVideoList from '../com-video-list';
import './index.scss';

interface TabPanelProps {
  // eslint-disable-next-line react/require-default-props
  children?: React.ReactNode;
  index: any;
  value: any;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`simple-tabpanel-${index}`}
      aria-labelledby={`simple-tab-${index}`}
      // eslint-disable-next-line react/jsx-props-no-spreading
      {...other}
    >
      {value === index && (
        <Box
          sx={{
            width: '100%',
            height: '100%',
          }}
        >
          {children}
        </Box>
      )}
    </div>
  );
}

export default function SimpleTabs(props: Record<string, any>) {
  const { userList, toggleMicMuteState, classMembers, messageList } = props;
  const [value, setValue] = React.useState(0);

  // eslint-disable-next-line @typescript-eslint/ban-types
  const handleChange = (event: React.ChangeEvent<{}>, newValue: number) => {
    setValue(newValue);
  };

  return (
    <div className="bottom-list">
      <AppBar position="static">
        <Tabs
          value={value}
          onChange={handleChange}
          aria-label="simple tabs example"
        >
          <Tab label="视频列表" />
          <Tab label="聊天互动" />
          <Tab label="成员列表" />
        </Tabs>
      </AppBar>
      <TabPanel value={value} index={0}>
        <div className="vide-list-bottom">
          <ComVideoList
            userList={userList}
            mode="vertical"
            toggleMicMuteState={toggleMicMuteState}
          />
        </div>
      </TabPanel>
      <TabPanel value={value} index={1}>
        <div className="im-bottom">
          <Im messageList={messageList} />
        </div>
      </TabPanel>
      <TabPanel value={value} index={2}>
        <WatchList classMembers={classMembers} />
      </TabPanel>
    </div>
  );
}
