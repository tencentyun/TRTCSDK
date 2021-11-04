//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//
#include "main_window.h"
#include "translator.h"

#include <QApplication>
#include <QStyleFactory>
#include <QTextCodec>
#include <QFont>

#include "ITRTCCloud.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    app.installTranslator(&(Translator::getInstance()->getTranslator()));
#ifdef _DEBUG
    getTRTCShareInstance()->setConsoleEnabled(true);
#endif

    QFont font;

#ifndef _WIN32
    font.setFamily("PingFang SC");
#else
    font.setFamily("Microsoft YaHei");
#endif
    font.setStyle(QFont::Style::StyleNormal);
    font.setStyleStrategy(QFont::PreferAntialias);
    font.setPointSize(13);
    app.setFont(font);
    MainWindow *mainWindow = new MainWindow();
    mainWindow->show();

    int res = app.exec();
    delete mainWindow;
    destroyTRTCShareInstance();
    return res;
}
