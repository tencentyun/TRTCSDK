ThirdBeauty:
1. 下载依赖的第三方美颜SDK:https://www.faceunity.com/sdk/FaceUnity-SDK-iOS-v7.4.0.zip
2. 导入SDK
	- 下载完成并解压后将库文件夹拖入到工程中，并勾选上 Copy items if needed.
	- libCNamaSDK.framework是动态库，需要在General->Framworks，Libraries,and Embedded Content
	  中添加依赖关系，并将Embed设置为Embed&Sign，否则会导致运行后因找不到库而崩.
3. 下载FUTRTCDemo：https://github.com/Faceunity/FUTRTCDemo
4. 将FUTRTCDemo工程中FaceUnity目录下的以下文件：
	- authpack.h
	- FUBeautyParam.h
	- FUBeautyParam.m
	- FUDateHandle.h
	- FUDateHandle.m
	- FUManager.h
	- FUManager.m
	拖入到工程中，并勾选上 Copy items if needed.
5. 证书添加：authpack.h中的证书key请联系Faceunity获取测试证书并替换到此处（替换后请注释掉或删除此错误警告）。
6. 取消ThirdBeautyViewController.m文件中的以下注释：

	```
	//#import "FUManager.h"
	```

	```
	//@property (strong, nonatomic) FUBeautyParam *beautyParam;
	```

	```
	//- (FUBeautyParam *)beautyParam {
	//    if (!_beautyParam) {
	//        _beautyParam = [[FUBeautyParam alloc] init];
	//        _beautyParam.type = FUDataTypeBeautify;
	//        _beautyParam.mParam = @"blur_level";
	//    }
	//    return _beautyParam;
	//}
	```

	```
	//    [[FUManager shareManager] loadFilter];
	//    [FUManager shareManager].isRender = YES;
	//    [FUManager shareManager].flipx = YES;
	//    [FUManager shareManager].trackFlipx = YES;
	```

	```
	//    self.beautyParam.mValue = sender.value;
	//    [[FUManager shareManager] filterValueChange:self.beautyParam];
	```

	```
	//    [[FUManager shareManager] renderItemsToPixelBuffer:frame.pixelBuffer];
	```

	```
	//    [[FUManager shareManager] destoryItems];
	```
7. Command + R 运行


