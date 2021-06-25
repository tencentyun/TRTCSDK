import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import TRTC from 'trtc-js-sdk';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import { makeStyles } from '@material-ui/core/styles';
import { upperFirstLetter } from '@utils/utils';

const useStyles = makeStyles(theme => ({
  'form-control': {
    marginBottom: theme.spacing(2),
    minWidth: 120,
    width: 'calc(100%)',
  },
  'select-empty': {
    marginTop: theme.spacing(2),
  },
}));

const getDeviceList = async (deviceType) => {
  let deviceList = [];
  switch (deviceType) {
    case 'camera':
      deviceList = await TRTC.getCameras();
      break;
    case 'microphone':
      deviceList = await TRTC.getMicrophones();
      break;
    case 'speaker':
      deviceList = await TRTC.getSpeakers();
      break;
    default:
      break;
  }
  return deviceList;
};

DeviceSelect.propTypes = {
  deviceType: PropTypes.string.isRequired,
  onChange: PropTypes.func,
};

export default function DeviceSelect({ deviceType, onChange }) {
  const classes = useStyles();
  const [deviceList, setDeviceList] = useState([]);
  const [activeDeviceId, setActiveDeviceId] = useState('');

  useEffect(async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({ audio: deviceType === 'microphone', video: deviceType === 'camera' });
      mediaStream.getTracks()[0].stop();
    } catch (error) {
      if (error.name === 'NotAllowedError') {
        alert(`请允许网页访问${deviceType === 'microphone' ? '麦克风' : '摄像头'}的权限！`);
      } else if (error.name === 'NotFoundError') {
        alert(`请检查${deviceType === 'microphone' ? '麦克风' : '摄像头'}设备连接是否正常！`);
      }
    }

    const list = await getDeviceList(deviceType);
    const activeDeviceId = list[0].deviceId;
    onChange && onChange(activeDeviceId);

    setDeviceList(list);
    setActiveDeviceId(activeDeviceId);
  }, []);

  navigator.mediaDevices.ondevicechange = async () => {
    setDeviceList(await getDeviceList(deviceType));
  };

  const handleChange = (event) => {
    setActiveDeviceId(event.target.value);
    onChange && onChange(event.target.value);
  };

  return (
    <FormControl className={classes['form-control']}>
      <InputLabel id={`${deviceType}-input-label`}>{`${upperFirstLetter(deviceType)} Select`}</InputLabel>
      <Select
        labelId={`${deviceType}-input-label`}
        id={`${deviceType}-select`}
        value={activeDeviceId}
        onChange={handleChange}
        label={`${deviceType} Select`}
        className={classes.select}
      >
        {
          deviceList.map((item, index) => <MenuItem value={item.deviceId} key={index}>{item.label}</MenuItem>)
        }
      </Select>
    </FormControl>
  );
}
