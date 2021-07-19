import { Tooltip, Select, MenuItem } from '@material-ui/core';
import a18n from 'a18n';
import React, { useState, useEffect, useContext } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Cookies from 'js-cookie';
import { getUrlParam } from '@utils/utils';
import { MyContext } from '@utils/context-manager';

const useStyles = makeStyles(props => ({
  'language-select': {
    minWidth: 70,
    color: (props && props.color) || '#00A4FF',
    fontSize: 14,
  },
}));

export default function LanguageChange(props) {
  const classes = useStyles(props);
  const { toolTipsVisible = true } = props;
  const [language, setLanguage] = useState('');
  const { changeLanguage } = useContext(MyContext);

  useEffect(() => {
    const language = Cookies.get('trtc-lang') || getUrlParam('lang') || navigator.language || 'zh-CN';
    a18n.setLocale(language);
    setLanguage(language);
  }, []);

  const languageChange = (event) => {
    const language = event.target.value;
    setLanguage(language);
    changeLanguage(language);
  };

  const selectComponent = () => <Select value={language} className={classes['language-select']} onChange={languageChange}>
    <MenuItem value='zh-CN'>{a18n('中文')}</MenuItem>
    <MenuItem value='en'>{a18n('英文')}</MenuItem>
  </Select>;

  return toolTipsVisible
    ? <Tooltip title={a18n('语言切换')} placement="right-end">{selectComponent()}</Tooltip>
    : selectComponent();
}
