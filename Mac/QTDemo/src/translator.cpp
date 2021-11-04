#include "translator.h"

#include <QLocale>

Translator::Translator() {
}

Translator::~Translator() {
}

void Translator::changeLanguage(int language) {
    switch (language) {
    case LANGUAGE::CHINESE:
        translator.load(":/translations/translation/QTDemo_I18N_cn.qm");
        break;
    case LANGUAGE::ENGLISH:
        translator.load(":/translations/translation/QTDemo_I18N_en.qm");
        break;
    }
}

void Translator::initLanguage() {
    QLocale locale;
    switch (locale.language()) {
    case QLocale::Chinese:
        changeLanguage(LANGUAGE::CHINESE);
        break;
    default:
        changeLanguage(LANGUAGE::ENGLISH);
        break;
    }
}
