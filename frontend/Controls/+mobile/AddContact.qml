/**
 * Filename: AddContact.qml
 *
 * XCITE is a secure platform utilizing the XTRABYTES Proof of Signature
 * blockchain protocol to host decentralized applications
 *
 * Copyright (c) 2017-2018 Zoltan Szabo & XTRABYTES developers
 *
 * This file is part of an XTRABYTES Ltd. project.
 *
 */

import QtQuick.Controls 2.3
import QtQuick 2.7
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2

import "qrc:/Controls" as Controls

Rectangle {
    id: addContactModal
    width: 325
    state: addContactTracker == 1? "up" : "down"
    height: editSaved == 1? 360 : 465
    color: "transparent"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top

    states: [
        State {
            name: "up"
            PropertyChanges { target: addContactModal; anchors.topMargin: 50}
        },
        State {
            name: "down"
            PropertyChanges { target: addContactModal; anchors.topMargin: Screen.height}
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation { target: addContactModal; property: "anchors.topMargin"; duration: 300; easing.type: Easing.OutCubic}
        }
    ]

    property int editSaved: 0
    property int contactExists: 0
    property var photoBackground: photoSelect == 0? profilePictures.get(0).photo : (photoSelect == 1? profilePictures.get(1).photo : (photoSelect == 2? profilePictures.get(2).photo : (profilePictures.get(3).photo)))

    function compareName() {
        contactExists = 0
        for(var i = 0; i < contactList.count; i++) {
            if (contactList.get(i).firstName === newFirstname.text && contactList.get(i).lastName === newLastname.text  && contactList.get(i).remove === false) {
                contactExists = 1
            }
        }
    }

    Rectangle {
        id: contactTitleBar
        width: parent.width
        height: 50
        anchors.top: parent.top
        anchors.left: parent.left
        color: "transparent"
        visible: editSaved == 0


        Text {
            id: transferModalLabel
            text: "ADD NEW CONTACT"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: 27
            font.pixelSize: 18
            font.family: "Brandon Grotesque"
            color: darktheme == false? "#F2F2F2" : maincolor
            font.letterSpacing: 2
        }

    }

    Rectangle {
        id: contactBodyModal
        width: parent.width
        height: parent.height - 50
        radius: 4
        color: darktheme == false? "#42454F" : "transparent"
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter

        DropShadow {
            id: shadowPhoto
            anchors.fill: newPhoto
            source: newPhoto
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0
            color: "black"
            opacity: 0.3
            transparentBorder: true
            visible: editSaved == 0
        }

        Image {
            id: newPhoto
            source: photoBackground
            height: 100
            width: 100
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.top: parent.top
            anchors.topMargin: 20
            visible: editSaved == 0
        }

        Controls.TextInput {
            id: newFirstname
            height: 34
            placeholder: "FIRST NAME"
            anchors.bottom: newPhoto.verticalCenter
            anchors.bottomMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.left: newPhoto.right
            anchors.leftMargin: 25
            color: newFirstname.text != "" ? "#F2F2F2" : "#727272"
            font.pixelSize: 14
            validator: RegExpValidator { regExp: /[0-9A-Za-z]+/ }
            visible: editSaved == 0
            mobile: 1
            onTextChanged: compareName()
        }

        Controls.TextInput {
            id: newLastname
            height: 34
            placeholder: "LAST NAME"
            anchors.left: newFirstname.left
            anchors.right: newFirstname.right
            anchors.top: newFirstname.bottom
            anchors.topMargin: 10
            color: newLastname.text !== "" ? "#F2F2F2" : "#727272"
            font.pixelSize: 14
            validator: RegExpValidator { regExp: /[0-9A-Za-z]+/ }
            visible: editSaved == 0
            mobile: 1
            onTextChanged: compareName()
        }

        Label {
            id: nameWarning1
            text: "Contact alreade exists!"
            color: "#FD2E2E"
            anchors.horizontalCenter: newLastname.horizontalCenter
            anchors.top: newLastname.bottom
            anchors.topMargin: 2
            font.pixelSize: 11
            font.family: "Brandon Grotesque"
            font.weight: Font.Normal
            visible: editSaved == 0
                     && newFirstname.text != ""
                     && newLastname.text != ""
                     && contactExists == 1
        }

        Rectangle {
            id: photoColor1
            width: 20
            height: 20
            anchors.top: newPhoto.bottom
            anchors.topMargin: 10
            anchors.left: newPhoto.left
            radius: 4
            border.color: photoSelect == 0? maincolor : "#F2F2F2"
            border.width: photoSelect == 0? 2 : 1
            color: "#2C3E50"
            visible: editSaved == 0

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    photoSelect = 0
                }
            }
        }

        Rectangle {
            id: photoColor2
            width: 20
            height: 20
            anchors.top: newPhoto.bottom
            anchors.topMargin: 10
            anchors.left: photoColor1.right
            anchors.leftMargin: 20/3
            radius: 4
            border.color: photoSelect == 1? maincolor : "#F2F2F2"
            border.width: photoSelect == 1? 2 : 1
            color: "#590E03"
            visible: editSaved == 0

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    photoSelect = 1
                }
            }
        }

        Rectangle {
            id: photoColor3
            width: 20
            height: 20
            anchors.top: newPhoto.bottom
            anchors.topMargin: 10
            anchors.left: photoColor2.right
            anchors.leftMargin: 20/3
            radius: 4
            border.color: photoSelect == 2? maincolor : "#F2F2F2"
            border.width: photoSelect == 2? 2 : 1
            color: "#034B2E"
            visible: editSaved == 0

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    photoSelect = 2
                }
            }
        }

        Rectangle {
            id: photoColor4
            width: 20
            height: 20
            anchors.top: newPhoto.bottom
            anchors.topMargin: 10
            anchors.left: photoColor3.right
            anchors.leftMargin: 20/3
            radius: 4
            border.color: photoSelect == 3? maincolor : "#F2F2F2"
            border.width: photoSelect == 3? 2 : 1
            color: "#C77007"
            visible: editSaved == 0

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    photoSelect = 3
                }
            }
        }

        Controls.TextInput {
            id: newTel
            height: 34
            placeholder: "TELEPHONE NUMBER"
            anchors.left: newPhoto.left
            anchors.right: newLastname.right
            anchors.top: photoColor1.bottom
            anchors.topMargin: 15
            color: newTel.text != "" ? "#F2F2F2" : "#727272"
            font.pixelSize: 14
            validator: RegExpValidator { regExp: /[0-9+]+/ }
            visible: editSaved == 0
            mobile: 1
        }

        Controls.TextInput {
            id: newCell
            height: 34
            placeholder: "CELLPHONE NUMBER"
            anchors.left: newTel.left
            anchors.right: newTel.right
            anchors.top: newTel.bottom
            anchors.topMargin: 10
            color: newCell.text != "" ? "#F2F2F2" : "#727272"
            font.pixelSize: 14
            validator: RegExpValidator { regExp: /[0-9+]+/ }
            visible: editSaved == 0
            mobile: 1
        }

        Controls.TextInput {
            id: newMail
            height: 34
            placeholder: "EMAIL ADDRESS"
            anchors.left: newCell.left
            anchors.right: newCell.right
            anchors.top: newCell.bottom
            anchors.topMargin: 10
            color: newMail.text != "" ? "#F2F2F2" : "#727272"
            font.pixelSize: 14
            visible: editSaved == 0
            mobile: 1
        }

        Controls.TextInput {
            id: newChat
            height: 34
            placeholder: "X-CHAT ID"
            anchors.left: newMail.left
            anchors.right: newMail.right
            anchors.top: newMail.bottom
            anchors.topMargin: 10
            color: newChat.text != "" ? "#F2F2F2" : "#727272"
            font.pixelSize: 14
            visible: editSaved == 0
            mobile: 1
        }

        /**Controls.PictureList {
            id: myPictures
            visible: pictureTracker == 1
        }*/

        Rectangle {
            id: saveButton
            width: parent.width - 28
            height: 34
            radius: 5
            color: (newFirstname.text !== ""
                    && newLastname.text !== ""
                    && contactExists == 0) ? maincolor : "#727272"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            visible: editSaved == 0

            MouseArea {
                anchors.fill: saveButton

                onPressed: {
                }

                onReleased: {
                    if (newFirstname.text !== ""
                            && newLastname.text !== ""
                            && contactExists == 0) {
                        contactList.append({"firstName": newFirstname.text, "lastName": newLastname.text, "photo": photoBackground, "telNR": newTel.text, "cellNR": newCell.text, "mailAddress": newMail.text, "chatID": newChat.text, "favorite": false, "active": true, "contactNR": contactID, "remove": false});
                        contactID = contactID +1;
                        editSaved = 1
                    }
                }
            }

            Text {
                text: "SAVE"
                font.family: "Brandon Grotesque"
                font.pointSize: 14
                font.bold: true
                color: (newFirstname.text !== ""
                        && newLastname.text !== ""
                        && contactExists == 0) ? "#F2F2F2" : "#979797"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // save state

        DropShadow {
            id: shadowPhotoSave
            anchors.fill: saveSuccess
            source: saveSuccess
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0
            color: "black"
            opacity: 0.3
            transparentBorder: true
            visible: editSaved == 1
        }

        Image {
            id: saveSuccess
            source: newPhoto.source
            height: 100
            width: 100
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 50
            visible: editSaved == 1
        }

        Label {
            id: saveSuccessName
            text: newFirstname.text + " " + newLastname.text
            anchors.top: saveSuccess.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: saveSuccess.horizontalCenter
            color: "#F2F2F2"
            font.pixelSize: 18
            font.family: "Brandon Grotesque"
            font.bold: true
            visible: editSaved == 1
        }

        Label {
            id: saveSuccessLabel
            text: "Saved!"
            anchors.top: saveSuccess.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: saveSuccess.horizontalCenter
            color: maincolor
            font.pixelSize: 18
            font.family: "Brandon Grotesque"
            font.bold: true
            visible: editSaved == 1
        }

        Rectangle {
            id: closeSave
            width: doubbleButtonWidth / 2
            height: 33
            radius: 5
            color: maincolor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            visible: editSaved == 1

            MouseArea {
                anchors.fill: closeSave

                onClicked: {
                    addContactTracker = 0;
                    newFirstname.text = "";
                    newLastname.text = "";
                    newTel.text = "";
                    newCell.text = "";
                    newMail.text = "";
                    newChat.text = "";
                    contactExists = 0;
                    photoSelect = 0;
                    editSaved = 0
                }
            }
            Text {
                text: "OK"
                font.family: "Brandon Grotesque"
                font.pointSize: 14
                font.bold: true
                color: "#F2F2F2"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Label {
        id: closeAddressModal
        z: 10
        text: "CLOSE"
        anchors.top: addContactModal.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: addContactModal.horizontalCenter
        font.pixelSize: 14
        font.family: "Brandon Grotesque"
        color: darktheme == false? "#F2F2F2" : maincolor
        visible: addContactTracker == 1
                 && editSaved == 0

        Rectangle{
            id: closeButton
            height: 34
            width: doubbleButtonWidth
            radius: 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            border.width: 2
            border.color: darktheme == false? "transparent" : maincolor
        }

        MouseArea {
            anchors.fill: closeButton

            onClicked: {
                addContactTracker = 0;
                newFirstname.text = "";
                newLastname.text = "";
                newTel.text = "";
                newCell.text = "";
                newMail.text = "";
                newChat.text = "";
                contactExists = 0;
                photoSelect = 0
            }
        }
    }
}
