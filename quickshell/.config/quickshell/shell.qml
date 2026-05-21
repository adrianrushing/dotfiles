import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications

ShellRoot {
  id: root

  property bool historyVisible: false
  property bool launcherVisible: false
  property bool doNotDisturb: false
  property var popupNotification: null
  property string launcherQuery: ""
  property var filteredEntries: root.sortedEntries(DesktopEntries.applications.values)
  property var notificationReceivedAtById: ({})
  property var groupCollapsedState: ({})
  property int localNotificationKeyCounter: 0

  property color bgBase: "#0D090B"
  property color bgTile: "#201F26"
  property color fgMain: "#7C9EA6"
  property color borderCool: "#4C6C73"
  property color borderAccent: "#734343"
  property color bgAlert: "#592533"
  property int radiusPx: 2
  property int borderWidthPx: 2
  property int spacingPx: 6
  property string fontFamilyName: "JetBrainsMono Nerd Font"
  property int fontSizePx: 14

  function screenshotPathForNotification(notification) {
    if (!notification) {
      return ""
    }

    const appName = notification.appName || ""
    const summary = notification.summary || ""
    const body = notification.body || ""

    const isScreenshot = appName === "Hyprshot" || summary.toLowerCase().indexOf("screenshot") !== -1
    if (!isScreenshot) {
      return ""
    }

    const candidates = [body, notification.appIcon || "", notification.image || ""]
    const pathRegex = /(\/[^\s<>()]+(?:\s+[^\s<>()]+)*\.(?:png|jpe?g|webp))/i

    for (const candidate of candidates) {
      const match = candidate.match(pathRegex)
      if (match && match[1]) {
        const candidatePath = match[1].trim()
        if (candidatePath.startsWith("/")) {
          return candidatePath
        }
      }
    }

    return ""
  }

  function openScreenshot(notification) {
    const path = screenshotPathForNotification(notification)
    if (!path) {
      console.log("[notifications] openScreenshot: no path resolved", {
        appName: notification ? notification.appName : "",
        summary: notification ? notification.summary : "",
        body: notification ? notification.body : "",
        appIcon: notification ? notification.appIcon : "",
        image: notification ? notification.image : "",
      })
      return
    }

    console.log("[notifications] openScreenshot: launching", path)

    Quickshell.execDetached(["loupe", path])
  }

  NotificationServer {
    id: notificationServer
    actionsSupported: true
    inlineReplySupported: false
    persistenceSupported: false
    bodySupported: true

    onNotification: notification => {
      notification.tracked = true
      const id = root.notificationId(notification)
      if (id && root.notificationReceivedAtById[id] === undefined) {
        root.notificationReceivedAtById = Object.assign({}, root.notificationReceivedAtById, { [id]: Date.now() })
      }

      if (!root.doNotDisturb) {
        root.popupNotification = notification
        popupTimer.restart()
      }
    }
  }

  GlobalShortcut {
    name: "toggle_notification_history"
    description: "Toggle Quickshell notification history"
    onPressed: root.toggleHistory()
  }

  HyprlandFocusGrab {
    id: historyFocusGrab
    windows: [historyWindow]
    onCleared: {
      if (root.historyVisible && historyWindow.visible) {
        root.closeHistory("focus_cleared")
      }
    }
  }

  function openHistory() {
    if (root.historyVisible) {
      return
    }

    root.historyVisible = true
  }

  function closeHistory(reason) {
    root.historyVisible = false
  }

  function toggleHistory() {
    if (root.historyVisible) {
      root.closeHistory("toggle")
    } else {
      root.openHistory()
    }
  }

  GlobalShortcut {
    name: "toggle_launcher"
    description: "Toggle Quickshell launcher"
    onPressed: {
      root.launcherVisible = !root.launcherVisible
      if (root.launcherVisible) {
        searchField.text = ""
        root.launcherQuery = ""
        root.filterApplications("")
      }
    }
  }

  function filterApplications(query) {
    root.launcherQuery = query || ""

    if (root.launcherQuery.length === 0) {
      root.filteredEntries = root.sortedEntries(DesktopEntries.applications.values)
      return
    }

    const lowered = root.launcherQuery.toLowerCase()
    const matches = DesktopEntries.applications.values.filter(entry => {
      const name = (entry.name || "").toLowerCase()
      const genericName = (entry.genericName || "").toLowerCase()
      const keywords = entry.keywords || []
      const keywordHit = keywords.some(keyword => keyword.toLowerCase().indexOf(lowered) !== -1)

      return name.indexOf(lowered) !== -1
        || genericName.indexOf(lowered) !== -1
        || keywordHit
    })

    root.filteredEntries = root.sortedEntries(matches)
  }

  function sortedEntries(entries) {
    return entries
      .slice()
      .sort((a, b) => (a.name || "").localeCompare((b.name || ""), undefined, { sensitivity: "base" }))
  }

  function launchApp(entry) {
    if (!entry) {
      return
    }

    entry.execute()
    root.launcherVisible = false
  }

  function notificationId(notification) {
    if (!notification) {
      return ""
    }

    if (notification.id !== undefined && notification.id !== null) {
      return String(notification.id)
    }

    if (!notification.__localPhase1Id) {
      root.localNotificationKeyCounter += 1
      notification.__localPhase1Id = "local-" + root.localNotificationKeyCounter
    }

    return notification.__localPhase1Id
  }

  function notificationReceivedAt(notification) {
    const id = root.notificationId(notification)
    if (!id) {
      return Date.now()
    }

    const known = root.notificationReceivedAtById[id]
    if (known !== undefined) {
      return known
    }

    const now = Date.now()
    root.notificationReceivedAtById = Object.assign({}, root.notificationReceivedAtById, { [id]: now })
    return now
  }

  function appLabelForNotification(notification) {
    const appName = (notification && notification.appName) ? notification.appName.trim() : ""
    if (appName.length > 0) {
      return appName
    }

    const desktopEntry = (notification && notification.desktopEntry) ? notification.desktopEntry.trim() : ""
    if (desktopEntry.length > 0) {
      return desktopEntry
    }

    return "Unknown App"
  }

  function bucketKeyForTimestamp(ts) {
    const now = new Date()
    const date = new Date(ts)

    if (date.toDateString() === now.toDateString()) {
      const diffMs = now.getTime() - date.getTime()
      if (diffMs <= 60 * 60 * 1000) {
        return "now"
      }

      return "earlier_today"
    }

    const yesterday = new Date(now)
    yesterday.setDate(now.getDate() - 1)
    if (date.toDateString() === yesterday.toDateString()) {
      return "yesterday"
    }

    return "older"
  }

  function sortedTrackedNotifications() {
    return [...notificationServer.trackedNotifications.values].sort((a, b) => {
      return root.notificationReceivedAt(b) - root.notificationReceivedAt(a)
    })
  }

  function groupedNotificationBuckets() {
    const sorted = root.sortedTrackedNotifications()
    const bucketOrder = ["now", "earlier_today", "yesterday", "older"]
    const buckets = {
      now: { key: "now", label: "Now", groups: [] },
      earlier_today: { key: "earlier_today", label: "Earlier Today", groups: [] },
      yesterday: { key: "yesterday", label: "Yesterday", groups: [] },
      older: { key: "older", label: "Older", groups: [] },
    }
    const groupIndex = {}

    for (const notification of sorted) {
      const bucketKey = root.bucketKeyForTimestamp(root.notificationReceivedAt(notification))
      const appLabel = root.appLabelForNotification(notification)
      const compositeKey = bucketKey + "|" + appLabel

      if (groupIndex[compositeKey] === undefined) {
        const group = {
          key: compositeKey,
          appLabel,
          notifications: [],
        }
        groupIndex[compositeKey] = buckets[bucketKey].groups.length
        buckets[bucketKey].groups.push(group)
      }

      buckets[bucketKey].groups[groupIndex[compositeKey]].notifications.push(notification)
    }

    const output = []
    for (const key of bucketOrder) {
      if (buckets[key].groups.length > 0) {
        output.push(buckets[key])
      }
    }

    return output
  }

  function toggleGroupCollapsed(groupKey) {
    const next = Object.assign({}, root.groupCollapsedState)
    next[groupKey] = !(next[groupKey] === true)
    root.groupCollapsedState = next
  }

  function isGroupCollapsed(groupKey) {
    return root.groupCollapsedState[groupKey] === true
  }

  function dismissNonCritical() {
    const items = notificationServer.trackedNotifications.values
    for (const notification of items) {
      if (notification.urgency !== NotificationUrgency.Critical) {
        notification.tracked = false
      }
    }
  }

  function visibleNotifications() {
    const visible = []
    const buckets = root.groupedNotificationBuckets()

    for (const bucket of buckets) {
      for (const group of bucket.groups) {
        if (!root.isGroupCollapsed(group.key)) {
          for (const notification of group.notifications) {
            visible.push(notification)
          }
        }
      }
    }

    return visible
  }

  function markVisibleRead() {
    const items = root.visibleNotifications()
    for (const notification of items) {
      notification.tracked = false
    }
  }

  function markGroupRead(groupNotifications) {
    for (const notification of groupNotifications) {
      notification.tracked = false
    }
  }

  function clearAllNotifications() {
    const items = notificationServer.trackedNotifications.values
    for (const notification of items) {
      notification.tracked = false
    }
  }

  Timer {
    id: popupTimer
    interval: 5000
    repeat: false
    onTriggered: root.popupNotification = null
  }

  component TileButton: Button {
    id: tileButton
    property color normalBg: root.bgTile
    property color normalBorder: root.borderCool
    property color normalText: root.fgMain
    property color hoverBg: root.borderCool
    property color hoverBorder: root.borderAccent
    property color hoverText: root.bgBase

    implicitHeight: 32
    implicitWidth: 88
    hoverEnabled: true
    font.family: root.fontFamilyName
    font.pixelSize: root.fontSizePx

    contentItem: Text {
      text: tileButton.text
      color: tileButton.hovered ? tileButton.hoverText : tileButton.normalText
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      font.family: root.fontFamilyName
      font.pixelSize: root.fontSizePx
      font.bold: true
      elide: Text.ElideRight
    }

    background: Rectangle {
      radius: root.radiusPx
      color: tileButton.hovered ? tileButton.hoverBg : tileButton.normalBg
      border.width: root.borderWidthPx
      border.color: tileButton.hovered ? tileButton.hoverBorder : tileButton.normalBorder
    }
  }

  PanelWindow {
    id: popupWindow
    visible: root.popupNotification !== null && !root.doNotDisturb
    implicitWidth: 360
    implicitHeight: popupContent.implicitHeight
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
      top: true
      right: true
    }

    margins {
      top: root.spacingPx
      right: root.spacingPx
    }

    Rectangle {
      id: popupContent
      width: parent.width
      radius: root.radiusPx
      color: root.popupNotification && root.popupNotification.urgency === NotificationUrgency.Critical ? root.bgAlert : root.bgTile
      border.color: root.popupNotification && root.popupNotification.urgency === NotificationUrgency.Critical ? root.borderAccent : root.borderCool
      border.width: root.borderWidthPx
      implicitHeight: popupColumn.implicitHeight + root.spacingPx * 2

      Column {
        id: popupColumn
        spacing: root.spacingPx
        anchors.fill: parent
        anchors.margins: root.spacingPx

        Text {
          text: root.popupNotification ? root.popupNotification.summary : ""
          color: root.fgMain
          font.family: root.fontFamilyName
          font.pixelSize: root.fontSizePx
          font.bold: true
          wrapMode: Text.Wrap
        }

        Text {
          text: root.popupNotification ? root.popupNotification.body : ""
          color: root.fgMain
          font.family: root.fontFamilyName
          font.pixelSize: root.fontSizePx
          wrapMode: Text.Wrap
          visible: text.length > 0
        }

        Row {
          spacing: root.spacingPx
          visible: root.popupNotification
            && (root.popupNotification.actions.length > 0 || root.screenshotPathForNotification(root.popupNotification).length > 0)

          TileButton {
            visible: root.popupNotification && root.screenshotPathForNotification(root.popupNotification).length > 0
            text: "Open"
            onClicked: {
              console.log("[notifications] popup Open clicked")
              root.openScreenshot(root.popupNotification)
            }
          }

          Repeater {
            model: root.popupNotification ? root.popupNotification.actions : []

            delegate: TileButton {
              required property var modelData
              text: modelData.text
              onClicked: modelData.invoke()
            }
          }
        }
      }
    }
  }

  PanelWindow {
    id: launcherOverlay
    visible: root.launcherVisible
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore
    onVisibleChanged: {
      if (visible) {
        Qt.callLater(function() {
          searchField.forceActiveFocus()
        })
      }
    }

    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }

    Item {
      anchors.fill: parent

      Rectangle {
        id: launcherCard
        width: 500
        height: 420
        anchors.centerIn: parent
        color: root.bgBase
        border.color: root.borderAccent
        border.width: 3
        radius: 10

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 15
          spacing: 10

          TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Search apps..."
            color: root.fgMain
            font.family: root.fontFamilyName
            font.pixelSize: 15
            selectByMouse: true

            background: Rectangle {
              color: root.bgTile
              border.color: searchField.activeFocus ? root.borderAccent : root.borderCool
              border.width: root.borderWidthPx
              radius: 4
            }

            onTextChanged: root.filterApplications(text)

            Keys.onEscapePressed: root.launcherVisible = false
            Keys.onDownPressed: {
              appListView.forceActiveFocus()
              if (appListView.count > 0) {
                appListView.currentIndex = 0
              }
            }
            Keys.onReturnPressed: {
              if (root.filteredEntries.length > 0) {
                root.launchApp(root.filteredEntries[0])
              }
            }
          }

          ListView {
            id: appListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.filteredEntries
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            keyNavigationWraps: true
            currentIndex: count > 0 ? 0 : -1
            reuseItems: true

            delegate: ItemDelegate {
              required property var modelData
              required property int index
              width: appListView.width
              height: 44
              hoverEnabled: true
              highlighted: ListView.isCurrentItem

              background: Rectangle {
                color: parent.highlighted || parent.hovered ? root.borderCool : "transparent"
                border.color: parent.highlighted ? root.borderAccent : "transparent"
                border.width: root.borderWidthPx
                radius: 4
              }

              contentItem: Text {
                text: modelData.name
                color: parent.highlighted || parent.hovered ? root.bgBase : root.fgMain
                font.family: root.fontFamilyName
                font.pixelSize: root.fontSizePx
                font.bold: parent.highlighted
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                elide: Text.ElideRight
              }

              onClicked: root.launchApp(modelData)
            }

            Keys.onReturnPressed: {
              if (currentIndex >= 0 && currentIndex < root.filteredEntries.length) {
                root.launchApp(root.filteredEntries[currentIndex])
              }
            }
            Keys.onEscapePressed: root.launcherVisible = false
          }
        }
      }
    }
  }

  PanelWindow {
    id: historyWindow
    visible: root.historyVisible
    implicitWidth: 440
    focusable: true
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    onVisibleChanged: {
      if (visible) {
        Qt.callLater(function() {
          if (historyWindow.visible) {
            historyFocusGrab.active = true
          }
        })
      } else {
        historyFocusGrab.active = false
      }
    }

    anchors {
      top: true
      right: true
      bottom: true
    }

    margins {
      top: 58
      right: 6
      bottom: 6
    }

    Item {
      anchors.fill: parent

      ColumnLayout {
        anchors.fill: parent
        spacing: 2 + root.borderWidthPx

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          Rectangle {
            anchors.fill: parent
            anchors.topMargin: tacticalShape.height + 3
            radius: root.radiusPx
            color: root.bgBase
            border.color: root.borderAccent
            border.width: root.borderWidthPx
            z: 1

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: root.spacingPx
              spacing: root.spacingPx + 2

              RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                spacing: root.spacingPx

                TileButton {
                  Layout.preferredWidth: 110
                  Layout.preferredHeight: 32
                  Layout.alignment: Qt.AlignVCenter
                  normalBorder: root.doNotDisturb ? root.borderAccent : root.borderCool
                  text: root.doNotDisturb ? "DND: ON" : "DND: OFF"
                  onClicked: root.doNotDisturb = !root.doNotDisturb
                }

                TileButton {
                  Layout.preferredWidth: 140
                  Layout.preferredHeight: 32
                  Layout.alignment: Qt.AlignVCenter
                  text: "Dismiss Non-Critical"
                  enabled: notificationServer.trackedNotifications.values.length > 0
                  onClicked: root.dismissNonCritical()
                }

                TileButton {
                  Layout.preferredWidth: 96
                  Layout.preferredHeight: 32
                  Layout.alignment: Qt.AlignVCenter
                  text: "Mark Read"
                  enabled: root.visibleNotifications().length > 0
                  onClicked: root.markVisibleRead()
                }

                Item {
                  Layout.fillWidth: true
                }

                TileButton {
                  Layout.preferredWidth: 36
                  Layout.preferredHeight: 32
                  Layout.alignment: Qt.AlignVCenter
                  implicitWidth: 36
                  implicitHeight: 32
                  text: "x"
                  onPressed: root.closeHistory("close_button")
                }
              }

              Flickable {
                id: historyFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                contentWidth: width
                contentHeight: historyContent.implicitHeight

                Column {
                  id: historyContent
                  width: historyFlick.width
                  spacing: root.spacingPx

                Repeater {
                  model: root.groupedNotificationBuckets()

                  delegate: Column {
                    required property var modelData
                    property var bucket: modelData
                    width: parent.width
                    spacing: root.spacingPx

                    Text {
                      text: bucket.label
                      color: root.fgMain
                      font.family: root.fontFamilyName
                      font.pixelSize: root.fontSizePx
                      font.bold: true
                    }

                    Repeater {
                      model: bucket.groups

                      delegate: Rectangle {
                        required property var modelData
                        property var group: modelData
                        width: parent.width
                        radius: root.radiusPx
                        color: root.bgTile
                        border.width: root.borderWidthPx
                        border.color: root.borderCool
                        implicitHeight: groupColumn.implicitHeight + root.spacingPx * 2

                        Column {
                          id: groupColumn
                          anchors.fill: parent
                          anchors.margins: root.spacingPx
                          spacing: root.spacingPx

                          RowLayout {
                            width: parent.width
                            spacing: root.spacingPx

                            TileButton {
                              text: root.isGroupCollapsed(group.key) ? ">" : "v"
                              implicitWidth: 32
                              implicitHeight: 32
                              onClicked: root.toggleGroupCollapsed(group.key)
                            }

                            Text {
                              Layout.fillWidth: true
                              text: group.appLabel + " (" + group.notifications.length + ")"
                              color: root.fgMain
                              font.family: root.fontFamilyName
                              font.pixelSize: root.fontSizePx
                              font.bold: true
                              verticalAlignment: Text.AlignVCenter
                              elide: Text.ElideRight
                            }

                            TileButton {
                              id: readGroupButton
                              text: "Read"
                              implicitWidth: 74
                              enabled: group.notifications.length > 0
                              onClicked: root.markGroupRead(group.notifications)
                            }
                          }

                          Column {
                            width: parent.width
                            spacing: root.spacingPx
                            visible: !root.isGroupCollapsed(group.key)

                            Repeater {
                              model: group.notifications

                              delegate: Rectangle {
                                required property var modelData
                                property var notification: modelData
                                property bool hovered: notificationHover.containsMouse
                                width: parent.width
                                radius: root.radiusPx
                                color: hovered ? root.borderCool : (notification.urgency === NotificationUrgency.Critical ? root.bgAlert : root.bgBase)
                                border.color: hovered ? root.borderAccent : (notification.urgency === NotificationUrgency.Critical ? root.borderAccent : root.borderCool)
                                border.width: root.borderWidthPx
                                implicitHeight: notificationColumn.implicitHeight + root.spacingPx * 2

                                MouseArea {
                                  id: notificationHover
                                  anchors.fill: parent
                                  hoverEnabled: true
                                  acceptedButtons: Qt.NoButton
                                }

                                Column {
                                  id: notificationColumn
                                  anchors.fill: parent
                                  anchors.margins: root.spacingPx
                                  spacing: root.spacingPx

                                  Text {
                                    text: notification.summary
                                    color: hovered ? root.bgBase : root.fgMain
                                    font.family: root.fontFamilyName
                                    font.pixelSize: root.fontSizePx
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                  }

                                  Text {
                                    text: notification.body
                                    color: hovered ? root.bgBase : root.fgMain
                                    font.family: root.fontFamilyName
                                    font.pixelSize: root.fontSizePx
                                    wrapMode: Text.Wrap
                                    visible: text.length > 0
                                  }

                                  Row {
                                    spacing: root.spacingPx

                                    TileButton {
                                      visible: root.screenshotPathForNotification(notification).length > 0
                                      text: "Open"
                                      onClicked: {
                                        console.log("[notifications] history Open clicked")
                                        root.openScreenshot(notification)
                                      }
                                    }

                                    TileButton {
                                      text: "Dismiss"
                                      onClicked: notification.dismiss()
                                    }

                                    Repeater {
                                      model: notification.actions

                                      delegate: TileButton {
                                        required property var modelData
                                        text: modelData.text
                                        onClicked: modelData.invoke()
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              }

              TileButton {
                Layout.fillWidth: true
                text: "Clear All"
                enabled: notificationServer.trackedNotifications.values.length > 0
                onClicked: root.clearAllNotifications()
              }
            }
          }

          Shape {
            id: tacticalShape
            width: 200
            height: 36
            anchors.top: parent.top
            anchors.left: parent.left
            z: 3
            antialiasing: true

            ShapePath {
              strokeWidth: root.borderWidthPx
              strokeColor: root.borderAccent
              fillColor: root.bgTile
              startX: 0
              startY: tacticalShape.height
              PathLine { x: 10; y: 0 }
              PathLine { x: tacticalShape.width; y: 0 }
              PathLine { x: tacticalShape.width; y: tacticalShape.height }
              PathLine { x: 0; y: tacticalShape.height }
            }

            Text {
              anchors.centerIn: parent
              text: "> NOTIFICATIONS _"
              color: root.fgMain
              font.family: root.fontFamilyName
              font.pixelSize: 16
              font.bold: true
            }
          }
        }
      }
    }
  }
}
