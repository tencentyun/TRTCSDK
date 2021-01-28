//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[]) {
    QApplication a(argc, argv);
    MainWindow *w = new MainWindow();
    w->show();
    int res = a.exec();
    delete w;
    destroyTRTCShareInstance();
    return res;
}
