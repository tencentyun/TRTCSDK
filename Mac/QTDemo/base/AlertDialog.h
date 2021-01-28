//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef QTMACDEMO_BASE_ALERTDIALOG_H_
#define QTMACDEMO_BASE_ALERTDIALOG_H_

#include <QDialog>

namespace Ui {
class AlertDialog;
}

class AlertDialog : public QDialog {
    Q_OBJECT

 public:
    explicit AlertDialog(QWidget *parent = nullptr);
    ~AlertDialog();
    void showMessageTip(const char *tip);

 private:
    Ui::AlertDialog *ui;
};

#endif  // QTMACDEMO_BASE_ALERTDIALOG_H_
