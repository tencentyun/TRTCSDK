import a18n from 'a18n';
import React, { useState, useEffect } from 'react';
import AppBar from '@material-ui/core/AppBar';
import CssBaseline from '@material-ui/core/CssBaseline';
import Divider from '@material-ui/core/Divider';
import Drawer from '@material-ui/core/Drawer';
import Hidden from '@material-ui/core/Hidden';
import IconButton from '@material-ui/core/IconButton';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import MenuIcon from '@material-ui/icons/Menu';
import Toolbar from '@material-ui/core/Toolbar';
import Collapse from '@material-ui/core/Collapse';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import TopBar from '@components/TopBar';
import clsx from 'clsx';
import { getLanguage } from '@utils/common';
import styles from './index.module.scss';

const drawerWidth = 260;
const useStyles = makeStyles(() => ({
  'drawer-container': {
    background: '#00182F',
    backgroundColor: '#00182F',
    color: '#ffffff',
  },
  'drawer-paper': {
    width: drawerWidth,
    background: '#00182F',
    backgroundColor: '#00182F',
    color: '#ffffff',
  },
  'sidebar-header-container': {
    display: 'flex',
    alignItems: 'center',
    padding: '15px 13px 37px 10px',
    justifyContent: 'space-between',
  },
  'active-group-item': {
    backgroundColor: '#1890fe',
    paddingLeft: 48,
  },
  nested: {
    paddingLeft: 48,
  },
  'active-item': {
    backgroundColor: '#1890fe',
  },
}));
/**
 * @param {object} props
 * @param {number} props.extendActiveId 选中导航栏 id, 外部传入后内部不再自己处理选中的导航栏 id; 不传时, 组件自身维护导航栏的切换及选中状态
 * @param {array} props.data 导航栏列表, 具体如下, 最多支持到 二级导航栏
 * @param {element} props.extendPage 外部页面组件, 如果传递外部页面组件时, 此时不会渲染 props.data 中对应的页面组件
 */
function SideBar(props) {
  let { data = [] } = props;
  const { extendActiveId, isMobile = false, activeTitle = '', mountFlag = false } = props;
  // 美颜 demo 不支持移动端, 需要从 sideBar 去除, 通过页面的 props 传递, 只能在 sideBar 中处理
  if (isMobile) {
    data = data.map(obj => ((obj.content || []).length > 0
      ? {
        ...obj,
        content: obj.content.filter(subObj => subObj.path !== 'improve-beauty'),
      }
      : obj));
  }
  const theme = useTheme();
  const classes = useStyles();
  const [drawerOpen, setDrawerOpen] = useState(false);
  const defaultActiveId = extendActiveId ? extendActiveId : (data[0] && (data[0].type === 'group' ? data[0].content[0].id : data[0].id));
  const [activeId, setActiveId] = useState(defaultActiveId); // 默认选中的侧边导航条
  const activeIdFirstNumber = `${extendActiveId}`.slice(0, 1);
  const [selectNavigatorObj] = data.filter(obj => activeIdFirstNumber === `${obj.id}`) || [];
  const openIndexDefault = (selectNavigatorObj && selectNavigatorObj.type === 'group') ? selectNavigatorObj.id : 0;
  const [openIndex, setOpenIndex] = useState(openIndexDefault);
  const [language, setLanguage] = useState('');

  const handleDrawerToggle = () => setDrawerOpen(!drawerOpen); // drawer 组件折叠、隐藏
  const renderIcon = CustomIcon => (!CustomIcon ? null : <ListItemIcon><CustomIcon/></ListItemIcon>);
  const handleGroupClick = (item) => {
    props.onActiveExampleChange && props.onActiveExampleChange(item); // 移除其他 item 高亮
    if (openIndex === item.id) {
      setOpenIndex(0); // 关闭
      return;
    }
    setOpenIndex(item.id);
  };

  // 侧边导航栏点击处理: 一是设置选中态; 二是调用父组件 onActiveExampleChange 进行路由的切换
  const handleItemClick = (item) => {
    item.id && setActiveId(extendActiveId || item.id);
    props.onActiveExampleChange && props.onActiveExampleChange(item);
  };

  useEffect(() => {
    const language = getLanguage();
    setLanguage(language);
  }, [props]);

  // 生成导航栏信息
  const drawer = () => (
    <div>
      <div className={classes['sidebar-header-container']}>
        <img src={language === 'zh-CN' ? './trtc-logo-cn-w.png' : './trtc-logo-en-w.png'} alt="me" width="230" height="30"></img>
      </div>
      <Divider />
      {(data || []).map((item) => {
        const CustomIcon = item.icon;
        if (item.type === 'group') {
          return (
            <div key={item.id}>
              <ListItem button key={`${item.id}-groupItem`} onClick={handleGroupClick.bind(this, item)}>
                {renderIcon(CustomIcon)}
                <ListItemText primary={a18n(item.title)} />
                {openIndex === item.id ? <ExpandLess /> : <ExpandMore />}
              </ListItem>
              <Collapse in={openIndex === item.id} timeout="auto" unmountOnExit key={`${item.id}-groupCollapse`}>
                <List component="div" disablePadding>
                  {item.content.map((groupItem) => {
                    const CustomIcon = groupItem.icon;
                    return (
                      <ListItem button key={`${groupItem.id}-groupCollapse-Item`}
                        className={ groupItem.id === activeId ? classes['active-group-item'] : classes.nested }
                        onClick={handleItemClick.bind(this, groupItem)}
                      >
                        {renderIcon(CustomIcon)}
                        <ListItemText primary={a18n(groupItem.title)} />
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
            <ListItem button onClick={handleItemClick.bind(this, item)}
              className={item.id === activeId ? classes['active-item'] : ''}
            >
              {renderIcon(CustomIcon)}
              <ListItemText primary={a18n(item.title)} />
            </ListItem>
          </div>
        );
      })}
    </div>
  );

  return (
    <div className={clsx(styles['sidebar-container'], isMobile && styles.rootDevice)}>
      <CssBaseline />
      <AppBar position='fixed' className={clsx(styles['header-container'], isMobile && styles['header-container-mobile'])}>
        <Toolbar
          disableGutters={true}
          classes = {{
            root: styles['tool-bar-root'],
            regular: styles['tool-bar-regular'],
          }}>
          <IconButton color='inherit' aria-label='open drawer' edge='start' onClick={handleDrawerToggle}
            className={clsx(styles['menu-button'], isMobile && styles['menu-button-mobile'])}
          >
            <MenuIcon />
          </IconButton>
          {mountFlag && <TopBar title={a18n(activeTitle)} isMobile={isMobile}></TopBar>}
        </Toolbar>
      </AppBar>
      <div className={styles['drawer-container']} aria-label='mailbox folders'>
        <Hidden implementation='css'>
          {isMobile
            ? <Drawer variant='temporary' anchor={theme.direction === 'rtl' ? 'right' : 'left'}
              open={drawerOpen}
              onClose={handleDrawerToggle}
              classes={{ paper: classes['drawer-paper'] }}
              ModalProps={{ keepMounted: true }}
            >
              {mountFlag && drawer()}
            </Drawer>
            : <Drawer classes={{ paper: classes['drawer-paper'] }} variant='permanent' open>
              {mountFlag && drawer()}
            </Drawer>}
        </Hidden>
      </div>
    </div>
  );
}

export default SideBar;
