/**
 * Filename: Settings.cpp
 *
 * XCITE is a secure platform utilizing the XTRABYTES Proof of Signature
 * blockchain protocol to host decentralized applications
 *
 * Copyright (c) 2017-2018 Zoltan Szabo & XTRABYTES developers
 *
 * This file is part of an XTRABYTES Ltd. project.
 *
 */

#include "Settings.hpp"

Settings::Settings(QObject *parent) :
    QObject(parent)
{
}

Settings::Settings(QQmlApplicationEngine *engine, QSettings *settings, QObject *parent) :
    QObject(parent)
{
    m_engine = engine;
    m_settings = settings;
}

void Settings::setLocale(QString locale) {
    if (!m_translator.isEmpty()) {
        QCoreApplication::removeTranslator(&m_translator);
    }

    if (locale != "en_us") {
        QString localeFile = QStringLiteral(":/i18n/lang_") + locale;
        if (!m_translator.load(localeFile)) {
            return;
        }

        QCoreApplication::installTranslator(&m_translator);
    }

    m_engine->retranslate();
}

void Settings::onLocaleChange(QString locale) {
    setLocale(locale);
}

void Settings::onClearAllSettings() {
    bool fallbacks = m_settings->fallbacksEnabled();
    m_settings->setFallbacksEnabled(false);

    m_settings->remove("developer");
    m_settings->remove("xchat");
    m_settings->remove("width");
    m_settings->remove("height");
    m_settings->remove("locale");
    m_settings->remove("x");
    m_settings->remove("y");
    m_settings->remove("onboardingCompleted");
    m_settings->remove("defaultCurrency");
    m_settings->sync();

    m_settings->setFallbacksEnabled(fallbacks);
}

// Onboarding and login functions

bool Settings::UserExists(QString username){
    QUrlQuery queryString;
    queryString.addQueryItem("userId", username);
    QString url = "/v1/user/" + username;

    QString userinfo = RestAPIGetCall(url);
    if (userinfo != ""){
        emit userAlreadyExists();
        return true;
    }else {
        emit usernameAvailable();
        return false;
    }
}

void Settings::CreateUser(QString username, QString password){
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("Latin1"));

    if(UserExists(username)){
        return;
    } else {

        QVariantMap settings;
        settings.insert("app","xtrabytes");

        QByteArray settingsByte =  QJsonDocument::fromVariant(settings).toJson(QJsonDocument::Compact);
        QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);

        QByteArray encodedText = encryption.encode(settingsByte, (password + "xtrabytesxtrabytes").toLatin1());
        QString DataAsString = QString::fromLatin1(encodedText, encodedText.length());

        QVariantMap feed;
        feed.insert("dateCreated", QDateTime::currentDateTime());
        feed.insert("dateUpdated", QDateTime::currentDateTime());
        feed.insert("settings", DataAsString);
        feed.insert("username", username);
        feed.insert("id", "1");

        QByteArray payload =  QJsonDocument::fromVariant(feed).toJson(QJsonDocument::Compact);
        bool success = RestAPIPostCall("/v1/user", payload);

        if (UserExists(username)){
            m_username = username;
            m_password = password;
            emit userCreationSucceeded();
        } else {
            emit userCreationFailed();
        }
    }

}

void Settings::login(QString username, QString password){
    if(!UserExists(username)){
        return;
    }
    QUrlQuery queryString;
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QString url = "/v1/user/" + username;

    QByteArray result = RestAPIGetCall(url);
    QByteArray settings = QJsonDocument::fromJson(result).array()[0].toString().toLatin1(); //JSON is returned as a one item array.  Item is the settings value
    QString DataAsString = QString::fromLatin1(settings, settings.length()); //adding settings.length or string is truncated


    QByteArray decodedSettings = encryption.decode(DataAsString.toLatin1(), (password + "xtrabytesxtrabytes").toLatin1());
    int pos = decodedSettings.lastIndexOf(QChar('}')); // find last bracket to mark the end of the json
    decodedSettings = decodedSettings.left(pos+1); //remove everything after the valid json

    QJsonObject decodedJson = QJsonDocument::fromJson(decodedSettings).object();

    if(decodedJson.value("app").toString().startsWith("xtrabytes")){
        m_username = username;
        m_password = password;
        emit loginSucceededChanged();
        LoadSettings(decodedSettings);

    }
    else
        emit loginFailedChanged();
}

bool Settings::SaveSettings(){
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QVariantMap settings;

    foreach (const QString &key, m_settings->childKeys()) {//iterate through m_settings to add everything to settings file we write to DB
        settings.insert(key,m_settings->value(key).toString());
        qDebug().noquote() << settings;
    }
    settings.insert("pincode", m_pincode); //may be able to remove this

    /*      Add contacts to DB       */
    QJsonArray contactsArray = QJsonDocument::fromJson(m_contacts.toLatin1()).array();
    settings.insert("contacts",contactsArray.toVariantList()); // add contacts array to our existing settings
    qDebug().noquote() << contactsArray;


    /*      Add addresses to DB       */
    QJsonArray addressesArray = QJsonDocument::fromJson(m_addresses.toLatin1()).array(); //save addresses saves array to m_addresses
    settings.insert("addresses",addressesArray.toVariantList()); // add address array to our existing settings

    /*    Convert Settings Variant to QByteArray  and encode it   */
    QByteArray settingsOutput =  QJsonDocument::fromVariant(QVariant(settings)).toJson(QJsonDocument::Compact); //Convert settings to byteArray/Json
    QByteArray encodedText = encryption.encode(settingsOutput, (m_password + "xtrabytesxtrabytes").toLatin1()); //encode settings after adding address
    QString DataAsString = QString::fromLatin1(encodedText, encodedText.length());

    QVariantMap feed;
    feed.insert("dateUpdated", QDateTime::currentDateTime());
    feed.insert("settings", DataAsString); //only updating time and settings
    feed.insert("username",m_username);

    // Build json to call API
    QByteArray payload =  QJsonDocument::fromVariant(QVariant(feed)).toJson(QJsonDocument::Compact);
    bool success = RestAPIPutCall("/v1/user", payload); //Calling PUT for update
    return true;
}

void Settings::LoadSettings(QByteArray settings){
    QJsonObject json = QJsonDocument::fromJson(settings).object();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        m_settings->setValue(key,value.toString());
        qDebug().noquote() << settings;
    }

    /* Load contacts from JSON from DB */
    QJsonArray contactArray = json["contacts"].toArray(); //get contactList from settings from DB
    QJsonDocument docContact;
    docContact.setArray(contactArray);
    QString contacts(docContact.toJson(QJsonDocument::Compact));
    m_contacts.clear();
    m_contacts = contacts;

    /* Load addresses from JSON from DB */
    QJsonArray addressArray = json["addresses"].toArray(); //get contactList from settings from DB
    QJsonDocument doc;
    doc.setArray(addressArray);
    QString addresses(doc.toJson(QJsonDocument::Compact));
    m_addresses.clear();
    m_addresses = addresses;

    // Send contacts to front end
    emit contactsLoaded(m_contacts);
    emit addressesLoaded(m_addresses);
    m_settings->sync();

}

void Settings::SaveAddresses(QString addresslist){
    m_addresses = addresslist;
    SaveSettings();
}

void Settings::SaveContacts(QString contactlist){
    m_contacts = contactlist;
    SaveSettings();
}

void Settings::onSavePincode(QString pincode){
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    m_pincode = pincode; //encryption.encode((QString("<xtrabytes>") + pincode).toUtf8(), (m_password + "xtrabytesxtrabytes").toUtf8());
    SaveSettings();
}

bool Settings::checkPincode(QString pincode){
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QString enc_pincode = encryption.encode((QString("<xtrabytes>") + pincode).toUtf8(), (m_password + "xtrabytesxtrabytes").toUtf8());
    if (enc_pincode == m_pincode)
        return true;
    else
        return false;
}

bool Settings::RestAPIPostCall(QString apiURL, QByteArray payload){

    QUrl Url;
    Url.setScheme("http");
    Url.setHost("37.59.57.212");
    Url.setPort(8080);
    Url.setPath(apiURL);
    qDebug() << Url.toString();

    QNetworkRequest request;
    request.setUrl(Url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json; charset=utf-8");

    QNetworkAccessManager *restclient;
    restclient = new QNetworkAccessManager(this);
    QNetworkReply *reply = restclient->post(request, payload);

    QEventLoop loop;
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), &loop, SLOT(quit()));
    loop.exec(); // Adding a loop makes the request go through now.  Prevents user creation being delayed and future GET request not seeing it
    qDebug() << reply->readAll();
    qDebug() << payload;

    return true;
}


bool Settings::RestAPIPutCall(QString apiURL, QByteArray payload){

    QUrl Url;
    Url.setScheme("http");
    Url.setHost("37.59.57.212");
    Url.setPort(8080);
    Url.setPath(apiURL);
    qDebug() << Url.toString();

    QNetworkRequest request;
    request.setUrl(Url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json; charset=utf-8");

    QNetworkAccessManager *restclient;
    restclient = new QNetworkAccessManager(this);
    QNetworkReply *reply = restclient->put(request, payload);

    QEventLoop loop;
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), &loop, SLOT(quit()));
    loop.exec(); // Adding a loop makes the request go through now.  Prevents user creation being delayed and future GET request not seeing it
    qDebug() << reply->readAll();
    qDebug() << payload;

    return true;
}


QByteArray Settings::RestAPIGetCall(QString apiURL){

    QUrl Url;
    Url.setScheme("http");
    Url.setHost("37.59.57.212");
    Url.setPort(8080);
    Url.setPath(apiURL);

    QNetworkRequest request;
    request.setUrl(Url);

    QNetworkAccessManager *restclient;
    restclient = new QNetworkAccessManager(this);
    request.setRawHeader("Accept", "application/json");

    QNetworkReply *reply = restclient->get(request);
    QByteArray bytes = reply->readAll();

    qDebug() << bytes;

    QEventLoop loop;
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), &loop, SLOT(quit()));
    loop.exec();

    QByteArray bts = reply->readAll();

    return bts;
}
