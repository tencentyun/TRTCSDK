import React, { useState } from 'react';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Collapse from '@material-ui/core/Collapse';
import './index.scss';

function SideBar(props) {
  const { data = [], activeId } = props;
  const [selectNavigatorObj] = data.filter(obj => `${activeId}`.startsWith(obj.id)) || [];
  const openIndexDefault = (selectNavigatorObj && selectNavigatorObj.type === 'group') ? selectNavigatorObj.id : 0;
  const [openIndex, setOpenIndex] = useState(openIndexDefault);

  const renderIcon = CustomIcon => (!CustomIcon ? null : <ListItemIcon><CustomIcon/></ListItemIcon>);
  const handleGroupClick = (item) => {
    if (openIndex === item.id) {
      setOpenIndex(0); // 关闭
      return;
    }
    setOpenIndex(item.id);
  };

  // 侧边导航栏点击处理
  const handleItemClick = (item) => {
    props.onItemClick && props.onItemClick(item);
  };

  return (
    <div className="side-bar">
      {props.data.map((item) => {
        const CustomIcon = item.icon;
        if (item.type === 'group') {
          return (
            <div key={item.id}>
              <ListItem
                button
                key={`${item.id}-groupItem`}
                onClick={handleGroupClick.bind(this, item)}
              >
                {renderIcon(CustomIcon)}
                <ListItemText primary={item.title} />
                {openIndex === item.id ? <ExpandLess /> : <ExpandMore />}
              </ListItem>
              <Collapse in={openIndex === item.id} timeout="auto" unmountOnExit key={`${item.id}-groupCollapse`}>
                <List component="div" disablePadding>
                  {item.content.map((groupItem) => {
                    const CustomIcon = groupItem.icon;
                    return (
                      <ListItem
                        button
                        className={ groupItem.id === activeId ? 'active-group-item' : 'nested' }
                        key={`${groupItem.id}-groupCollapse-Item`}
                        onClick={handleItemClick.bind(this, groupItem)}
                      >
                        {renderIcon(CustomIcon)}
                        <ListItemText primary={groupItem.title} />
                      </ListItem>
                    );
                  })}
                </List>
              </Collapse>
            </div>
          );
        }
        return (
          <div key={item.id}>
            <ListItem
              button
              className={item.id === activeId ? 'active-item' : ''}
              onClick={handleItemClick.bind(this, item)}
            >
              {renderIcon(CustomIcon)}
              <ListItemText primary={item.title} />
            </ListItem>
          </div>
        );
      })}
    </div>
  )
}

export default SideBar;