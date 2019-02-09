/**
 * Filename: Onboarding.qml
 *
 * XCITE is a secure platform utilizing the XTRABYTES Proof of Signature
 * blockchain protocol to host decentralized applications
 *
 * Copyright (c) 2017-2018 Zoltan Szabo & XTRABYTES developers
 *
 * This file is part of an XTRABYTES Ltd. project.
 *
 */

import QtQuick 2.7
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3

import "qrc:/Controls" as Controls

Item {

    Image {
        id: pictureBG
        source: "qrc:/backgrounds/stars.jpg"
        height: Screen.height
        width: pictureBG.height/4741 * 7360
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: backgroundSplash
        width: Screen.width
        height: Screen.height
        color: "#14161B"
        state: loginTracker == 0? "hidden" : "inView"

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(0, parent.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00162124" }
                GradientStop { position: 1.0; color: "#FF162124" }
            }
        }

        states: [
            State {
                name: "hidden"
                PropertyChanges { target: backgroundSplash; opacity: 0}
            },
            State {
                name: "inView"
                PropertyChanges { target: backgroundSplash; opacity: 1}
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation { target: backgroundSplash; property: "opacity"; duration: 300; easing.type: Easing.OutCubic}
            }
        ]
    }

    Image {
        id: largeLogo
        source: 'qrc:/icons/XBY_logo_large.svg'
        width: backgroundSplash.width * 2
        height: (largeLogo.width / 75) * 65
        anchors.top: backgroundSplash.top
        anchors.topMargin: 63
        anchors.right: backgroundSplash.right
        opacity: 0.5
    }

    Rectangle {
        id: welcome
        width: welcomeText.implicitWidth
        height: 180
        anchors.horizontalCenter: backgroundSplash.horizontalCenter
        anchors.verticalCenter: backgroundSplash.verticalCenter
        anchors.verticalCenterOffset: -50
        color: "transparent"

        state: loginTracker == 0? "inView" : "hidden"

        states: [
            State {
                name: "inView"
                PropertyChanges { target: welcome; opacity: 1}
            },
            State {
                name: "hidden"
                PropertyChanges { target: welcome; opacity: 0}
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation { target: welcome; property: "opacity"; duration: 300}
            }
        ]

        Label {
            id: welcomeText
            text: "XCITE"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            color: "#F2F2F2"
            font.pixelSize: 64
            font.family: xciteMobile.name
        }

        Label {
            id: version
            text: "V 1.0"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: welcomeText.bottom
            anchors.topMargin: -20
            color: maincolor
            font.pixelSize: 24
            font.family: xciteMobile.name
        }

        Rectangle {
            id: startButton
            width: (doubbleButtonWidth - 10) / 2
            height: 34
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: "#1B2934"
            opacity: 0.5

            LinearGradient {
                anchors.fill: parent
                source: parent
                start: Qt.point(x, y)
                end: Qt.point(x, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#0ED8D2" }
                }
            }


            MouseArea {
                anchors.fill: startButton

                onReleased: {
                    loginTracker = 1
                }
            }
        }

        Text {
            id: qrButtonText
            text: "LET'S GO"
            font.family: xciteMobile.name
            font.pointSize: 14
            color: "#F2F2F2"
            font.bold: true
            anchors.horizontalCenter: startButton.horizontalCenter
            anchors.verticalCenter: startButton.verticalCenter
        }

        Rectangle {
            width: (doubbleButtonWidth - 10) / 2
            height: 33
            anchors.horizontalCenter: startButton.horizontalCenter
            anchors.bottom: startButton.bottom
            color: "transparent"
            opacity: 0.5
            border.width: 1
            border.color: "#0ED8D2"
        }
    }

    Label {
        id: closeButtonLabel
        text: "CLOSE"
        anchors.bottom: combinationMark.top
        anchors.bottomMargin: 50
        anchors.horizontalCenter: backgroundSplash.horizontalCenter
        font.pixelSize: 14
        font.family: "Brandon Grotesque"
        color: "#F2F2F2"

        Rectangle{
            id: closeButton
            height: 34
            width: doubbleButtonWidth
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
        }

        MouseArea {
            anchors.fill: closeButton

            onClicked: Qt.quit()
        }
    }

    Image {
        id: combinationMark
        source: 'qrc:/icons/xby_logo_TM.svg'
        height: 23.4
        width: 150
        anchors.horizontalCenter: backgroundSplash.horizontalCenter
        anchors.bottom: backgroundSplash.bottom
        anchors.bottomMargin: 35
    }

    Login {
        id: myLogin
    }
}
