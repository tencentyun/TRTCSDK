package com.tencent.liteav.demo;

import android.os.Build;
import android.os.StrictMode;
import android.support.multidex.MultiDexApplication;
import android.util.Log;

import com.tencent.bugly.Bugly;
import com.tencent.bugly.beta.Beta;
import com.tencent.bugly.beta.download.DownloadListener;
import com.tencent.bugly.beta.download.DownloadTask;
import com.tencent.bugly.beta.upgrade.UpgradeStateListener;
import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.rtmp.TXLiveBase;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

//import com.squareup.leakcanary.LeakCanary;
//import com.squareup.leakcanary.RefWatcher;


public class DemoApplication extends MultiDexApplication {
    private static String TAG = "DemoApplication";

    //配置bugly组件的appId
    private static final String BUGLY_APPID = "";
    // 配置bugly组件的APP渠道号
    private static final String BUGLY_APP_CHANNEL = "";
    //配置bugly组件的调试模式（true或者false）
    private static final boolean BUGLY_ENABLE_DEBUG = true;

    //    private RefWatcher mRefWatcher;
    private static DemoApplication instance;

    // 如何获取License? 请参考官网指引 https://cloud.tencent.com/document/product/454/34750
    String licenceUrl = "请替换成您的licenseUrl";
    String licenseKey = "请替换成您的licenseKey";

    @Override
    public void onCreate() {

        super.onCreate();

        instance = this;

        TXLiveBase.setConsoleEnabled(true);
        initBugly();
        TXLiveBase.getInstance().setLicence(instance, licenceUrl, licenseKey);

        // 短视频licence设置
        StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
        StrictMode.setVmPolicy(builder.build());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            builder.detectFileUriExposure();
        }
        closeAndroidPDialog();
    }

    //    public static RefWatcher getRefWatcher(Context context) {
    //        DemoApplication application = (DemoApplication) context.getApplicationContext();
    //        return application.mRefWatcher;
    //    }

    public static DemoApplication getApplication() {
        return instance;
    }

    private void closeAndroidPDialog() {
        try {
            Class       aClass              = Class.forName("android.content.pm.PackageParser$Package");
            Constructor declaredConstructor = aClass.getDeclaredConstructor(String.class);
            declaredConstructor.setAccessible(true);
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            Class  cls            = Class.forName("android.app.ActivityThread");
            Method declaredMethod = cls.getDeclaredMethod("currentActivityThread");
            declaredMethod.setAccessible(true);
            Object activityThread         = declaredMethod.invoke(null);
            Field  mHiddenApiWarningShown = cls.getDeclaredField("mHiddenApiWarningShown");
            mHiddenApiWarningShown.setAccessible(true);
            mHiddenApiWarningShown.setBoolean(activityThread, true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //配置bugly组件的APP ID，bugly组件为腾讯提供的用于crash上报,分析和升级的开放组件，如果您不需要该组件，可以自行移除
    private void initBugly() {
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
        strategy.setAppVersion(TXLiveBase.getSDKVersionStr());
        strategy.setAppChannel(BUGLY_APP_CHANNEL);
        //监听安装包下载状态
        Beta.downloadListener = new DownloadListener() {
            @Override
            public void onReceive(DownloadTask downloadTask) {
            }

            @Override
            public void onCompleted(DownloadTask downloadTask) {
                Log.d(TAG,"downloadListener download apk file success");
            }

            @Override
            public void onFailed(DownloadTask downloadTask, int i, String s) {
                Log.d(TAG,"downloadListener download apk file fail");
            }
        };

        //监听APP升级状态
        Beta.upgradeStateListener = new UpgradeStateListener(){
            @Override
            public void onUpgradeFailed(boolean b) {
                Log.d(TAG,"upgradeStateListener upgrade failed");
            }

            @Override
            public void onUpgradeSuccess(boolean b) {
                Log.d(TAG,"upgradeStateListener upgrade success");
            }

            @Override
            public void onUpgradeNoVersion(boolean b) {
                Log.d(TAG,"upgradeStateListener upgrade has no new version");
            }

            @Override
            public void onUpgrading(boolean b) {
                Log.d(TAG,"upgradeStateListener upgrading");
            }

            @Override
            public void onDownloadCompleted(boolean b) {
                Log.d(TAG,"upgradeStateListener download apk file success");
            }
        };
        Bugly.init(getApplicationContext(), BUGLY_APPID, BUGLY_ENABLE_DEBUG, strategy);
    }

}