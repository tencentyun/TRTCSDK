## 使用说明
DeviceSelect 是一个设备选择器组件。根据传入的 deviceType 参数确定下拉框中的数据。

## 接受参数
| 参数    |     类型     |    可取值 | 说明 |
| :------ | :---------------- | :---------- | :---------- |
| deviceType | String         | 'camera'/'microphone'/'speaker'| 选择器类型         |
| onChange   | Function       | -      | select值发生变化的回调函数      |

## 使用示例
```
const DynamicDeviceSelect = dynamic(import('@components/DeviceSelect'), { ssr: false });

function App() {
    const [activeCameraId, setActiveCameraId] = useState(0);
  
    const handleChange = (newValue) => {
      setActiveCameraId(newValue);
    };
    return (
      <div className="App">
        <DynamicDeviceSelect
          deviceType="camera"
          onChange={handleChange}>
        </DynamicDeviceSelect>
      </div>
    );
}

```
