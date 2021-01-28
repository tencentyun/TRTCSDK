//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "AlertDialog.h"
#include "ui_AlertDialog.h"

AlertDialog::AlertDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::AlertDialog) {
    ui->setupUi(this);
}

AlertDialog::~AlertDialog() {
    delete ui;
}

void AlertDialog::showMessageTip(const char *tip) {
    QString tipStr(QString::fromLocal8Bit(tip).toUtf8());
    ui->tip->setText(tipStr);

    this->show();
    this->raise();
}

