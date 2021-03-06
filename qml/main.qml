import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.coderus.screentapshot 1.0

Item {
    id: root

    width: Screen.width
    height: Screen.height

    //Component.onCompleted: viewHelper.detachWindow()

    Screenshot {
        id: screenshot
        onCaptured: {
            shotPreview.width = root.width
            shotPreview.height = root.height
            shotPreview.opacity = 1.0
            shotPreview.source = path
            root.visible = true
            animate.start()
        }
    }

    Timer {
        id: delayTimer
        interval: 30
        repeat: true
        onTriggered: {
            captureProgress.value += 0.01
            if (captureProgress.value >= 1.0) {
                root.visible = false
                touchArea.count = 0
                delayTimer.stop()
                captureProgress.value = 0.0
                captureTimer.start()
            }
        }
    }

    Timer {
        id: captureTimer
        interval: 10
        onTriggered: screenshot.capture()
    }

    MouseArea {
        id: touchArea

        x: viewHelper.lastXPos
        y: viewHelper.lastYPos

        width: 80
        height: 80

        drag.target: touchArea
        drag.minimumX: 0
        drag.maximumX: root.width - touchArea.width
        drag.minimumY: 0
        drag.maximumY: root.height - touchArea.height

        property int count: 0
        onCountChanged: {
            if (count > 10) {
                count = 0
                mainIcon.rotation += 90
            }
        }

        onDoubleClicked: Qt.quit()
        onClicked: {
            count += 1
            if (delayTimer.running) {
                delayTimer.stop()
                captureProgress.value = 0.0
            }
            else {
                delayTimer.start()
            }
        }
        onReleased: viewHelper.setTouchRegion(Qt.rect(x, y, width, height))

        Image {
            id: mainIcon
            anchors.centerIn: parent
            source: "image://theme/icon-m-camera"
            Behavior on rotation {
                SmoothedAnimation { duration: 500 }
            }
        }

        ProgressCircle {
            id: captureProgress

            anchors.fill: parent
            value: 0.0
            visible: delayTimer.running
        }
    }

    Image {
        id: shotPreview

        anchors.centerIn: root

        opacity: 0.0

        PropertyAnimation {
            id: animate
            target: shotPreview
            properties: "height,width,opacity"
            to: 0
            duration: 500
        }
    }
}
