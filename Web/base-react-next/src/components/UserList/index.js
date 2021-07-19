import a18n from 'a18n';
import React, { useState, useEffect } from 'react';
import UserItem from './item';
import styles from './list.module.scss';
import { Typography, Accordion, AccordionSummary, AccordionDetails } from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';

function UserList(props) {
  const [localStreamConfig, setLocalStreamConfig] = useState(() => ({ ...props.localStreamConfig }));
  const [remoteStreamConfigList, setRemoteStreamConfigList] = useState(() => props.remoteStreamConfigList);

  useEffect(() => {
    const { localStreamConfig, remoteStreamConfigList } = props;
    setLocalStreamConfig(localStreamConfig);
    setRemoteStreamConfigList(remoteStreamConfigList && remoteStreamConfigList.filter(remoteStreamConfig => remoteStreamConfig.streamType !== 'auxiliary'));
  }, [props]);

  return (
    <div className={styles['user-list-title']}>
      <Accordion className={styles['accordion-container']} defaultExpanded={true}>
        <AccordionSummary
          expandIcon={<ExpandMoreIcon />}
          aria-controls="panel1a-content"
          id="panel1a-header"
          classes={{
            root: styles['accordion-summary-container'],
            content: styles['accordion-summary-content'],
          }}
        >
          <Typography>{a18n('成员列表')}</Typography>
        </AccordionSummary>
        <AccordionDetails className={styles['accordion-details-container']}>
          <ul className={`${styles['user-list-container']}`}>
            {
              localStreamConfig && <UserItem type="local" config={localStreamConfig}></UserItem>
            }
            {
              remoteStreamConfigList.length > 0
              && remoteStreamConfigList.map((remoteStreamConfig, index) => (
                <UserItem key={index} type="remote" config={remoteStreamConfig}></UserItem>
              ))
            }
            {!localStreamConfig && remoteStreamConfigList.length === 0
          && <li><Typography align="center" variant="body2">{a18n('暂无成员')}</Typography></li>}
          </ul>
        </AccordionDetails>
      </Accordion>
    </div>
  );
}

export default UserList;
