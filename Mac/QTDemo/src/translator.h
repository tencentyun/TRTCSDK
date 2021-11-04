#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QTranslator>

class Translator {
public:
    Translator(const Translator&) = delete;
    Translator& operator=(const Translator&) = delete;

    inline static Translator* getInstance() {
        static Translator instance;
        return &instance;
    }

    inline QTranslator& getTranslator() {
        return translator;
    }

    void changeLanguage(int language);

    void initLanguage();

private:
    enum LANGUAGE {
        CHINESE,
        ENGLISH,
    };

    Translator();
    ~Translator();
    QTranslator translator;
};

#endif // TRANSLATOR_H