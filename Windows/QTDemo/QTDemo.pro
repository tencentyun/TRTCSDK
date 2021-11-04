QT       += core gui network multimedia

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11
CONFIG += debug_and_release warn_on
CONFIG += thread exceptions rtti stl

# set path for auto-generated ui header files
UI_DIR=./ui_auto_gen

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

msvc {
    QMAKE_CFLAGS += /utf-8
    QMAKE_CXXFLAGS += /utf-8
}

SOURCE_PATHS = \
    $$PWD/src/. \
    $$PWD/src/Util/. \
    $$PWD/src/Util/Widget/. \
    $$PWD/src/TestAudioDetect/. \
    $$PWD/src/TestAudioRecord/. \
    $$PWD/src/TestAudioSetting/. \
    $$PWD/src/TestBaseScene/. \
    $$PWD/src/TestBaseScene/. \
    $$PWD/src/TestBaseScene/. \
    $$PWD/src/TestBeautyAndWatermark/. \
    $$PWD/src/TestBgmSetting/. \
    $$PWD/src/TestCDNPlayer/. \
    $$PWD/src/TestCDNPublish/. \
    $$PWD/src/TestConnectOtherRoom/. \
    $$PWD/src/TestCustomCapture/. \
    $$PWD/src/TestCustomMessage/. \
    $$PWD/src/TestCustomRender/. \
    $$PWD/src/TestDeviceManager/. \
    $$PWD/src/TestLogSetting/. \
    $$PWD/src/TestMixStreamPublish/. \
    $$PWD/src/TestNetworkCheck/. \
    $$PWD/src/TestScreenShare/. \
    $$PWD/src/TestScreenShare/. \
    $$PWD/src/TestScreenShare/. \
    $$PWD/src/TestScreenShare/. \
    $$PWD/src/TestSubCloudSetting/. \
    $$PWD/src/TestVideoDetect/. \
    $$PWD/src/TestVideoSetting/.

SOURCES += \
    src/base_dialog.cpp \
    src/main.cpp \
    src/main_window.cpp \
    src/translator.cpp \
    src/TestAudioDetect/test_audio_detect.cpp \
    src/TestAudioRecord/test_audio_record.cpp \
    src/TestAudioSetting/test_audio_setting.cpp \
    src/TestBaseScene/test_base_scene.cpp \
    src/TestBaseScene/test_user_screen_share_view.cpp \
    src/TestBaseScene/test_user_video_group.cpp \
    src/TestBaseScene/test_user_video_item.cpp \
    src/TestBeautyAndWatermark/test_beauty_and_watermark.cpp \
    src/TestBgmSetting/test_bgm_setting.cpp \
    src/TestCDNPlayer/test_cdn_player.cpp \
    src/TestCDNPublish/test_cdn_publish.cpp \
    src/TestConnectOtherRoom/test_connect_other_room.cpp \
    src/TestCustomCapture/test_custom_capture.cpp \
    src/TestCustomMessage/test_custom_message.cpp \
    src/TestCustomRender/test_custom_render.cpp \
    src/TestDeviceManager/test_device_manager.cpp \
    src/TestLogSetting/test_log_setting.cpp \
    src/TestMixStreamPublish/test_mix_stream_publish.cpp \
    src/TestNetworkCheck/test_network_check.cpp \
    src/TestScreenShare/screen_share_selection_item.cpp \
    src/TestScreenShare/test_screen_share_select_screen.cpp \
    src/TestScreenShare/test_screen_share_select_window.cpp \
    src/TestScreenShare/test_screen_share_setting.cpp \
    src/TestSubCloudSetting/test_subcloud_setting.cpp \
    src/TestVideoDetect/test_video_detect.cpp \
    src/TestVideoSetting/test_video_setting.cpp \
    src/Util/room_info_holder.cpp \
    src/Util/Widget/gl_yuv_widget.cpp

HEADERS += \
    src/base_dialog.h \
    src/main_window.h \
    src/translator.h \
    src/TestAudioDetect/test_audio_detect.h \
    src/TestAudioRecord/test_audio_record.h \
    src/TestAudioSetting/test_audio_setting.h \
    src/TestBaseScene/test_base_scene.h \
    src/TestBaseScene/test_user_screen_share_view.h \
    src/TestBaseScene/test_user_video_group.h \
    src/TestBaseScene/test_user_video_item.h \
    src/TestBeautyAndWatermark/test_beauty_and_watermark.h \
    src/TestBgmSetting/test_bgm_setting.h \
    src/TestCDNPlayer/test_cdn_player.h \
    src/TestCDNPublish/test_cdn_publish.h \
    src/TestConnectOtherRoom/test_connect_other_room.h \
    src/TestCustomCapture/test_custom_capture.h \
    src/TestCustomMessage/test_custom_message.h \
    src/TestCustomRender/test_custom_render.h \
    src/TestDeviceManager/test_device_manager.h \
    src/TestLogSetting/test_log_setting.h \
    src/TestMixStreamPublish/test_mix_stream_publish.h \
    src/TestNetworkCheck/test_network_check.h \
    src/TestScreenShare/screen_share_selection_item.h \
    src/TestScreenShare/test_screen_share_select_screen.h \
    src/TestScreenShare/test_screen_share_select_window.h \
    src/TestScreenShare/test_screen_share_setting.h \
    src/TestSubCloudSetting/test_subcloud_setting.h \
    src/TestVideoDetect/test_video_detect.h \
    src/TestVideoSetting/test_video_setting.h \
    src/Util/defs.h \
    src/Util/room_info_holder.h \
    src/Util/trtc_cloud_callback_default_impl.h \
    src/Util/tx_liveplayer_proxy.h \
    src/Util/Widget/gl_yuv_widget.h

FORMS += \
    src/MainWindow.ui \
    src/TestAudioDetect/TestAudioDetectDialog.ui \
    src/TestAudioRecord/TestAudioRecordDialog.ui \
    src/TestAudioSetting/TestAudioSettingDialog.ui \
    src/TestBaseScene/TestUserScreenShareViewDialog.ui \
    src/TestBaseScene/TestUserVideoGroup.ui \
    src/TestBaseScene/TestUserVideoItem.ui \
    src/TestBeautyAndWatermark/TestBeautyAndWaterMarkDialog.ui \
    src/TestBgmSetting/TestBGMSettingDialog.ui \
    src/TestCDNPlayer/TestCdnPlayerDialog.ui \
    src/TestCDNPublish/TestCdnPublishDialog.ui \
    src/TestCustomCapture/TestCustomCaptureDialog.ui \
    src/TestCustomMessage/TestCustomMessageDialog.ui \
    src/TestCustomRender/TestCustomRenderDialog.ui \
    src/TestDeviceManager/TestDeviceManagerDialog.ui \
    src/TestLogSetting/TestLogSettingDialog.ui \
    src/TestMixStreamPublish/TestMixStreamPublishDialog.ui \
    src/TestNetworkCheck/TestNetworkCheckDialog.ui \
    src/TestScreenShare/TestScreenShareSelectScreenDialog.ui \
    src/TestScreenShare/TestScreenShareSelectWindowDialog.ui \
    src/TestScreenShare/TestScreenShareSettingDialog.ui \
    src/TestScreenShare/ScreenShareSelectionItem.ui \
    src/TestVideoDetect/TestVideoDetectDialog.ui \
    src/TestVideoSetting/TestVideoSettingDialog.ui

RESOURCES += \
    resources/audio.qrc \
    resources/image.qrc \
    resources/translation.qrc

QMAKE_CFLAGS_RELEASE   = $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_CXXFLAGS_RELEASE = $$QMAKE_CXXFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE   = $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO

TRANSLATIONS +=  \
    QTDemo_I18N_en.ts \
    QTDemo_I18N_ZH_cn.ts

macx {

INCLUDEPATH += $${SOURCE_PATHS}
DEPENDPATH += $${SOURCE_PATHS}

QMAKE_INFO_PLIST += Info.plist

# 添加库依赖
LIBS += "-F$$PWD/src/Util/mac/usersig"
LIBS += "-F$$PWD/../SDK"
LIBS += -framework TXLiteAVSDK_TRTC_Mac
LIBS += -framework Accelerate
LIBS += -framework AudioUnit
LIBS += -lbz2
LIBS += -lresolv
#without c++11 & AppKit library compiler can't solve address for symbols
LIBS += -framework AppKit

# 添加TXLiteAVSDK_TRTC_Mac.framework头文件
INCLUDEPATH += $$PWD/../SDK/TXLiteAVSDK_TRTC_Mac.framework/Headers/cpp_interface \
               $$PWD/../SDK/TXLiteAVSDK_TRTC_Mac.framework/Headers

macx: LIBS += -L$$PWD/src/Util/mac/usersig/ -lTXLiteAVTestUserSig
macx: PRE_TARGETDEPS += $$PWD/src/Util/mac/usersig/libTXLiteAVTestUserSig.a
QMAKE_CXXFLAGS += -std=gnu++11
CONFIG += console

INCLUDEPATH += $$PWD/src/Util/mac/usersig/include
DEPENDPATH += $$PWD/src/Util/mac/usersig/include

DISTFILES += \
    src/Util/mac/usersig/libTXLiteAVTestUserSig.a

SOURCES += \
    $$PWD/src/Util/mac/cdnplayer/tx_liveplayer_proxy.mm

}



win32 {

INCLUDEPATH += $${SOURCE_PATHS}
INCLUDEPATH += $$PWD/src/Util/win/zlib/include \
               $$PWD/src/Util/win/usersig \
               $$PWD/../SDK/CPlusPlus/Win32/include \
               $$PWD/../SDK/CPlusPlus/Win32/include/TRTC

DEPENDPATH += $${SOURCE_PATHS}
DEPENDPATH += $$PWD/src/Util/win/zlib/include/ \
              $$PWD/../SDK/CPlusPlus/Win32/include \
              $$PWD/../SDK/CPlusPlus/Win32/include/TRTC

HEADERS += $$PWD/src/Util/win/usersig/GenerateTestUserSig.h
SOURCES += $$PWD/src/Util/win/usersig/GenerateTestUserSig.cpp \
           $$PWD/src/Util/win/cdnplayer/tx_liveplayer_proxy.cpp


CONFIG += opengl
CONFIG += debug_and_release


LIBS += user32.lib


debug {
contains(QT_ARCH,i386) {
LIBS += -L$$PWD/src/Util/win/zlib/x86 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win32/lib -lliteav
} else {
LIBS += -L$$PWD/src/Util/win/zlib/x86_64 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win64/lib -lliteav
}
}


release {
contains(QT_ARCH,i386) {
LIBS +=	-L$$PWD/src/Util/win/zlib/x86 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win32/lib -lliteav
} else {
LIBS +=	-L$$PWD/src/Util/win/zlib/x86_64 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win64/lib -lliteav
}
}
}
