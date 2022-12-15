import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "signature_pad/signature_pad.js" as SignaturePad
 
Rectangle {
    id: root
    width: parent.width
    height: 200

    // current signature filename to save it on disk
    property string signatureFileName: "Signature1.png"
    // image url from eg FileDialog
    property string loadedImageUrl: ""

    // used to modify max line width of signature
    property real maxLineWidth: 2
    // pon color of signature
    property color drawColor: "black"

    property bool isDrawn: false

    // clear signature, when orientation of screen changes
    property bool isPortrait: Screen.primaryOrientation === Qt.PortraitOrientation || Screen.primaryOrientation === Qt.InvertedPortraitOrientation
    onIsPortraitChanged: {
        clear()
    }

    function clear() {
        if(canvas.available){
            if(loadedImageUrl !== "") {
                canvas.unloadImage(loadedImageUrl)
                loadedImageUrl = ""
            }
            signaturePad.clear();
            if(isDrawn)
                isDrawn = false
        }
    }

    function grabCanvasToImage(filename){
        canvas.grabToImage(function(result){
            if(result.saveToFile(/*path/to/image*/ + "/" + filename))
                console.log("canvas saved: " + result.url)
        });
    }
 
    // used to display
    function loadImageFromUrl(image) {
        clear()
        loadedImageUrl = image
        print(loadedImageUrl)
        signaturePad.fromDataURL(loadedImageUrl)
    }

    property var signaturePad

    Label {
        visible: isPortrait
        anchors.centerIn: parent
        width: parent.width
        anchors.margins: GlobalVars.appLargeSpacing
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        text: "Please turn your device to landscape format to create a signature"
    }

    Canvas {
        id:canvas
        anchors.fill: parent
        width: parent.width
        height: parent.height

        visible: !isPortrait

        onImageLoaded: {
            if(canvas.isImageError(loadedImageUrl))
                return

            var ctx = getContext('2d')
            ctx.drawImage(loadedImageUrl, 0, 0)
            canvas.requestPaint()
            ctx.save()
        }

        MouseArea {
            id:mousearea
            hoverEnabled:true
            propagateComposedEvents: false
            anchors.fill: parent

            onPressed: {
                if(!isDrawn)
                    isDrawn = true

                // needed object for propagating mousePressed event to signature pad
                var event = {
                    clientX: mouseX,
                    clientY: mouseY,
                    which: 1
                }

                // start mouse recognition
                signaturePad._handleMouseDown(event)
            }

            onPositionChanged: {
                if (mousearea.pressed){
                    // needed object for propagating mouseMove event to signature pad
                    var event = {
                        clientX: mouseX,
                        clientY: mouseY,
                        which: 1
                    }

                    // update mouse move event
                    signaturePad._handleMouseMove(event)
                }
            }

            onReleased: {
                // needed object for propagating mouseRelease event to signature pad
                var event = {
                    clientX: mouseX,
                    clientY: mouseY,
                    which: 1
                }

                // mouse release event
                signaturePad._handleMouseUp(event)

                var ctx = canvas.getContext('2d');
                ctx.save()
            }
        }

        Component.onCompleted: {
            // consider to init signature pad in a delayed task due to undefined reference errors
            // I have a function of a timer called delayedTask

            signaturePad = new SignaturePad.SignaturePad(canvas, {
                // It's Necessary to use an opaque color when saving image as JPEG;
                // this option can be omitted if only saving as PNG or SVG
                backgroundColor: 'rgb(255, 255, 255)',
                maxWidth: root.maxLineWidth,
                penColor: root.drawColor
            });
        }
    }
}
