QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    TestBGMSetting.cpp \
    TestGeneralSetting.cpp \
    TestVideoSetting.cpp \
    base/AlertDialog.cpp \
    base/GLYuvWidget.cpp \
    base/VideoListView.cpp \
    base/main.cpp \
    TestAdvanceSetting.cpp \
    TestAudioSetting.cpp \
    TestCdnSetting.cpp \
    TestScreenSharing.cpp \
    mainwindow.cpp

HEADERS += \
    TestBGMSetting.h \
    TestGeneralSetting.h \
    TestVideoSetting.h \
    base/VideoListView.h \
    mainwindow.h \
    base/AlertDialog.h \
    base/Defs.h \
    base/GLYuvWidget.h \
    TestAdvanceSetting.h \
    TestAudioSetting.h \
    TestCdnSetting.h \
    TestScreenSharing.h

FORMS += \
    TestBGMSetting.ui \
    TestGeneralSetting.ui \
    TestVideoSetting.ui \
    base/VideoListView.ui \
    mainwindow.ui \
    base/AlertDialog.ui \
    TestAdvanceSetting.ui \
    TestAudioSetting.ui \
    TestCdnSetting.ui \
    TestScreenSharing.ui

RESOURCES += \
    resources/audio.qrc \
    resources/image.qrc

QMAKE_CFLAGS_RELEASE   = $$QMAKE_CFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_CXXFLAGS_RELEASE = $$QMAKE_CXXFLAGS_RELEASE_WITH_DEBUGINFO
QMAKE_LFLAGS_RELEASE   = $$QMAKE_LFLAGS_RELEASE_WITH_DEBUGINFO


macx {

INCLUDEPATH += $$PWD/.
DEPENDPATH += $$PWD/.

TRANSLATIONS += \
    QTDemo_zh_CN.ts

QMAKE_INFO_PLIST += Info.plist

# 添加库依赖
LIBS += "-F$$PWD/base/util/mac/usersig"
LIBS += "-F$$PWD/../SDK"
LIBS += -framework TXLiteAVSDK_TRTC_Mac
LIBS += -framework Accelerate
LIBS += -framework AudioUnit
LIBS += -lbz2

# 添加TXLiteAVSDK_TRTC_Mac.framework头文件
INCLUDEPATH += $$PWD/../SDK/TXLiteAVSDK_TRTC_Mac.framework/Headers/cpp_interface

macx: LIBS += -L$$PWD/base/util/mac/usersig/ -lTXLiteAVTestUserSig
macx: PRE_TARGETDEPS += $$PWD/base/util/mac/usersig/libTXLiteAVTestUserSig.a
QMAKE_CXXFLAGS += -std=gnu++11
CONFIG += console

INCLUDEPATH += $$PWD/base/util/mac/usersig/include
DEPENDPATH += $$PWD/base/util/mac/usersig/include

}



win32 {

TRANSLATIONS += \
    QTDemo_zh_CN.ts
SOURCES += base/util/win/usersig/GenerateTestUsersig.cpp
HEADERS += base/util/win/usersig/GenerateTestUsersig.h

INCLUDEPATH += $$PWD/.
INCLUDEPATH += $$PWD/base/util/win/zlib/include \
               $$PWD/base/util/win/usersig \
               $$PWD/../SDK/CPlusPlus/Win32/include \
               $$PWD/../SDK/CPlusPlus/Win32/include/TRTC

DEPENDPATH += $$PWD/.
DEPENDPATH +=  $$PWD/base/util/win/zlib/include \
               $$PWD/../SDK/CPlusPlus/Win32/include \
               $$PWD/../SDK/CPlusPlus/Win32/include/TRTC

CONFIG += opengl
CONFIG += debug_and_release


debug {
contains(QT_ARCH,i386) {
LIBS += -L$$PWD/base/util/win/zlib/x86 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win32/lib -lliteav
} else {
LIBS += -L$$PWD/base/util/win/zlib/x86_64 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win64/lib -lliteav
}
}


release {
contains(QT_ARCH,i386) {
LIBS +=	-L$$PWD/base/util/win/zlib/x86 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win32/lib -lliteav
} else {
LIBS +=	-L$$PWD/base/util/win/zlib/x86_64 -lzlibstatic
LIBS += -L$$PWD/../SDK/CPlusPlus/Win64/lib -lliteav
}
}


}
