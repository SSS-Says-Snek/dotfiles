import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import App from "resource:///com/github/Aylur/ags/app.js";
import { monitorFile, exec } from 'resource:///com/github/Aylur/ags/utils.js';

const BAR_SPACING = 8

const moveToWorkspace = ws => Hyprland.sendMessage(`dispatch workspace ${ws}`) 
const hyprWorkspaces = Widget.Box({
    className: 'hypr',
    children: Array.from({length: 10}, (_, i) => i + 1).map(i => Widget.Button({
        class_name: 'button-workspace',
        attribute: i,
        label: `${i}`,
        onClicked: () => moveToWorkspace(i),
    })),
    setup: self => self.hook(Hyprland, () => self.children.forEach(btn => {
        btn.visible = Hyprland.workspaces.some(ws => ws.id === btn.attribute);
    })), 
})

const leftBar = Widget.Box({
    className: 'bar-left',
    hpack: 'start',
    spacing: BAR_SPACING,
    children: [
        Widget.Label({label: 'hi'}),
        hyprWorkspaces
    ]
})

const centerBar = Widget.Box({
    className: 'bar-center',
    hexpand: true,
    spacing: BAR_SPACING,
    children: [
        Widget.Label({label: 'hi'}),
        Widget.Label({label: 'bye'})
    ]
})

const rightBar = Widget.Box({
    className: 'bar-right',
    hpack: 'end',
    spacing: BAR_SPACING,
    children: [
        Widget.Label({label: 'hi'}),
        Widget.Label({label: 'bye'})
    ]
})

const mainBar = Widget.Window({
    name: 'bar',
    className: 'main-bar',
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    child: Widget.CenterBox({
        startWidget: leftBar,
        centerWidget: centerBar,
        endWidget: rightBar
    }),
});

const scss = `${App.configDir}/scss/main.scss`
const css = `${App.configDir}/style.css`
const applyCss = () => {
    exec(`sassc ${scss} ${css}`)
    App.resetCss()
    App.applyCss(css)
}
applyCss()

// monitorFile(
//     `${App.configDir}/scss`,
//     applyCss,
//     'directory',
// )

export default {
    windows: [
        mainBar
    ]
}
