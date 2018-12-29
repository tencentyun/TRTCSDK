# TRTCSDK
腾讯云实时音视频(TRTC)服务

## 检出 Android
```
git init TRTC_Android
cd TRTC_Android
git remote add origin https://github.com/TencentVideoCloudTRTC/TRTCSDK.git
git config core.sparsecheckout true
echo "Android/*" >> .git/info/sparse-checkout
git pull origin master
```

## 检出 iOS
```
git init TRTC_iOS
cd TRTC_iOS
git remote add origin https://github.com/TencentVideoCloudTRTC/TRTCSDK.git
git config core.sparsecheckout true
echo "iOS/*" >> .git/info/sparse-checkout
git pull origin master
```

## 检出 Mac
```
git init TRTC_Mac
cd TRTC_Mac
git remote add origin https://github.com/TencentVideoCloudTRTC/TRTCSDK.git
git config core.sparsecheckout true
echo "Mac/*" >> .git/info/sparse-checkout
git pull origin master
```

## 检出 Windows
```
git init TRTC_Windows
cd TRTC_Windows
git remote add origin https://github.com/TencentVideoCloudTRTC/TRTCSDK.git
git config core.sparsecheckout true
echo "Windows/*" >> .git/info/sparse-checkout
git pull origin master
```
