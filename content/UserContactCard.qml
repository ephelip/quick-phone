import QtQuick 2.1
import Process 1.0
import "../app.js" as JS

Item {
  id: contactCard

  property alias name: usernameText.text
  property alias ext: userphoneText.text
  property alias jobTitle: jobTitleText.text
  property alias team: teamText.text
  property alias pictureLocation: contactPicture.source

  anchors.fill: parent

  MouseArea {
    //MouseArea will fill the zone behind the user card
    anchors.fill: parent

    // If user clic outside the user card, go back to list view and hangup if needed
    onClicked: {
      process.terminate();
      contactCard.remove();
    }
  }

  Rectangle {
    id: card

    property real widthRatio: contactCard.width * 2 / 3
    property real heightRatio: contactCard.height * 1 / 2

    color: "#000000"
    border.color: "#2d3435"
    border.width: 5
    radius: 15

    MouseArea {
      // overide onClic event for clic on the user card
      anchors.fill: parent
    }

    // Contact Picture holder
    Rectangle {
      id: pictureHolder

      width: parent.height * 2 / 5
      height: parent.height * 2 / 5

      anchors.verticalCenter: parent.verticalCenter
      x: parent.width * 1/10

      color: "white"

      Image {
        id: contactPicture
        property int errorCount: 0
        anchors.centerIn: parent
        height: parent.height
        fillMode: Image.PreserveAspectFit
        source: "../img/default_contact_picture.png"

        onStatusChanged: {
          // if we cannot load contact picture, use default image
          if (contactPicture.status == Image.Error) {
            errorCount += 1;
            if (errorCount != 0) {
              contactPicture.source = ""
              contactPicture.source = "../img/default_contact_picture.png";
            }
          }
        }
      }
    }

    // Contact name
    Text {
      id: usernameText
      color: "white"
      font.pixelSize: 32
      text: "Name"
      anchors.top: pictureHolder.top
      anchors.left: pictureHolder.right
      anchors.leftMargin: 20
      anchors.right: card.right
      wrapMode: Text.WordWrap
    }

    // Contact job title
    Text {
      id: jobTitleText
      color: "white"
      font.pixelSize: 20
      text: "Title"
      anchors.top: usernameText.bottom
      anchors.left: pictureHolder.right
      anchors.leftMargin: 20
      anchors.right: card.right
      wrapMode: Text.WordWrap
    }

    // Contact team
    Text {
      id: teamText
      color: "white"
      font.pixelSize: 20
      text: "team"
      anchors.top: jobTitleText.bottom
      anchors.left: pictureHolder.right
      anchors.leftMargin: 20
      anchors.right: card.right
      wrapMode: Text.WordWrap
    }

    // Contact sip extension
    Text {
      id: userphoneText
      text: "ext"
      visible: false
    }

    // Call button
    Rectangle {
      id: callButton

      color: "transparent"

      anchors.top: pictureHolder.bottom
      anchors.topMargin: 20
      anchors.bottom: card.bottom
      anchors.bottomMargin: 20
      anchors.horizontalCenter: pictureHolder.horizontalCenter

      width: callButton.height

      Image {
        anchors.fill: parent
        source: "../img/phone_call.png"
      }
      MouseArea {
        id: callButtonClicEvent
        anchors.fill: parent

        Process {
            id: process
            onReadyRead: console.info(readAll());
            onReadyReadStandardError: console.info(readAllStandardError());

            onFinished: {
              // Go back to home page
              console.info('Contact has finished the call');
              process.terminate();
              contactCard.remove();
              userListModelView.reset();
              stackView.pop();
            }
        }
        // call the user using pjsip
        onClicked: {
          console.info("Calling sip extension:", ext);
          if (ext === "reception") {
            process.start("./caller.py", [ "-c", "ts_7990_config.ini", "-r"]);
          } else {
            process.start("./caller.py", [ "-c", "ts_7990_config.ini", "-e", ext ]);
          }

          callButton.visible = false
          callButtonClicEvent.enabled = false
          hangupButton.visible = true
          hangupButtonClicEvent.enabled = true
        }
      }
    }

    // Hangup Button
    Rectangle {
      id: hangupButton

      visible: false
      color: "transparent"

      anchors.top: pictureHolder.bottom
      anchors.topMargin: 20
      anchors.bottom: card.bottom
      anchors.bottomMargin: 20
      anchors.horizontalCenter: pictureHolder.horizontalCenter

      width: hangupButton.height

      Image {
        anchors.fill: parent
        source: "../img/phone_hangup.png"
      }
      MouseArea {
        id: hangupButtonClicEvent
        anchors.fill: parent
        enabled: false

        onClicked: {
          // Hang up and go back to list view
          console.info('User has finished the call');
          process.terminate();
          contactCard.remove();
          userListModelView.reset();
          stackView.pop();
        }
      }
    }
  }

  ParallelAnimation {
      id: onCreateAnimation
      running: true
      NumberAnimation { target: card; property: "width" ; duration: 200 ;
                        from: 0; to: card.widthRatio}
      NumberAnimation { target: card; property: "height"; duration: 200 ;
                        from: 0; to: card.heightRatio}
      NumberAnimation { target: card; property: "x"; duration: 200 ;
                        from: contactCard.width  / 2; to: (contactCard.width  - card.widthRatio)  / 2}
      NumberAnimation { target: card; property: "y"; duration: 200 ;
                        from: contactCard.height / 2; to: (contactCard.height - card.heightRatio) / 2}
      NumberAnimation { target: usernameText; property: "font.pixelSize"; duration: 200 ;
                        from: 0; to: 32}
      NumberAnimation { target: jobTitleText; property: "font.pixelSize"; duration: 200 ;
                        from: 0; to: 20}
      NumberAnimation { target: teamText; property: "font.pixelSize"; duration: 200 ;
                        from: 0; to: 20}
  }

  function remove() {
      onDeleteAnimation.running = true;
  }

  ParallelAnimation {
      id: onDeleteAnimation
      running: false
      NumberAnimation { target: card; property: "width" ; duration: 200 ;
                        from: card.widthRatio; to: 0}
      NumberAnimation { target: card; property: "height"; duration: 200 ;
                        from: card.heightRatio; to: 0}
      NumberAnimation { target: card; property: "x"; duration: 200 ;
                        from: (contactCard.width  - card.widthRatio)  / 2; to: contactCard.width  / 2}
      NumberAnimation { target: card; property: "y"; duration: 200 ;
                        from: (contactCard.height - card.heightRatio) / 2; to: contactCard.height / 2}

      NumberAnimation { target: usernameText; property: "font.pixelSize"; duration: 200 ;
                        from: 32; to: 0}
      NumberAnimation { target: jobTitleText; property: "font.pixelSize"; duration: 200 ;
                        from: 20; to: 0}
      NumberAnimation { target: teamText; property: "font.pixelSize"; duration: 200 ;
                        from: 20; to: 0}

      onRunningChanged: {
        if(running == false ) {
          JS.deleteContactCard(contactCard);
        }
      }
  }
}
