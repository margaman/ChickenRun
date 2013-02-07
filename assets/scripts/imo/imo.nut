
emo.Runtime.import("emo-framework/physics.nut");

imo <- {}

// statics
class imo.S {
    static FPS = 60.0;
    static WINDOW_WIDTH = emo.Stage.getWindowWidth();
    static WINDOW_HEIGHT = emo.Stage.getWindowHeight();
    
    static LAYOUT_VERTICAL = "LAYOUT_VERTICAL";
    static LAYOUT_HORIZONTAL = "LAYOUT_HORIZONTAL";
}

class imo.TemplateMember {
    name = null;
    value = null;
    
    constructor(_name, _value) {
        name = _name;
        value = _value;
    }
}

class imo.Template {
    members = [];
    
    static function apply(template, classes) {
        for (local i = 0; i < classes.len(); i++) {
            local c = classes[i];
            for (local j = 0; j < template.members.len(); j++) {
                local m = template.members[j];
                c.newmember(m.name, m.value);
            }
        }
    }
}

class imo.SpriteTemplate extends imo.Template {
    members = [
        imo.TemplateMember(
            "update", null),
        imo.TemplateMember(
            "hasUpdateHandler",
            function() {
                return this.rawin("update") && "function" == (typeof this.update);
            }),
        imo.TemplateMember(
            "isBackground", false),
        imo.TemplateMember(
            "distance", 0),
        imo.TemplateMember(
            "setAsBackground", 
            function(_isBackground = true) {
                this.isBackground = _isBackground;
            }),
        imo.TemplateMember(
            "isVisible", 
            function() {
                return (10.0*alpha()) > 0;
            }),
        imo.TemplateMember(
            "onMotionEvent",
            null),
        imo.TemplateMember(
            "hasOnMotionEventHandler",
            function() {
                return this.rawin("onMotionEvent") && "function" == (typeof this.onMotionEvent);
            }),
    ];
}

// apply immediately
imo.Template.apply(
    imo.SpriteTemplate(), 
    [
        emo.Sprite,
        emo.SpriteSheet,
        emo.Rectangle,
        emo.MapSprite]);


class imo.Dialog extends emo.Rectangle {
    
    abstractStage = null;
    buttons = [];
    backgroundLayer = null;
    layout = imo.S.LAYOUT_VERTICAL;
    
    backgroundColor = {
        r = 0
        g = 0
        b = 0
        a = 0.7
    };
    buttonMargin = {
        top = 0
        bottom = 0
        left = 0
        right = 0
    };
    
    constructor(_abstractStage, r = 0, g = 0, b = 0, a = 0.7) {
        base.constructor();
        abstractStage = _abstractStage;
        setSize(imo.S.WINDOW_WIDTH, imo.S.WINDOW_HEIGHT);
        color(r, g, b, a);
    }
    
    function setZ(z) {
        base.setZ(z);
        for (local i = 0; i < buttons.len(); i++) {
            buttons[i].setZ(++z);
        }
    }
    
    function getFloats() {
        local floats = clone buttons;
        floats.append(backgroundLayer);
        return floats;
    }
    
    function color(r, g, b, a) {
        backgroundColor.r = r;
        backgroundColor.g = g;
        backgroundColor.b = b;
        backgroundColor.a = a;
        return base.color(r, g, b, a);
    }
    
    function red(r = null) {
        if (r) {
            backgroundColor.r = r;
            return base.red(r);
        } else {
            return base.red();
        }
    }
    function green(g = null) {
        if (g) {
            backgroundColor.g = g;
            return base.red(g);
        } else {
            return base.green();
        }
    }
    function blue(b = null) {
        if (b) {
            backgroundColor.b = b;
            return base.blue(b);
        } else {
            return base.blue();
        }
    }
    function alpha(a = null) {
        if (a) {
            backgroundColor.a = a;
            return base.alpha(a);
        } else {
            return base.alpha();
        }
    }
    
    function show() {
        local result = base.show();
        color(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a);
        layOut();
        for (local i = 0; i < buttons.len(); i++) {
            buttons[i].show();
        }
        return result;
    }
    
    function hide() {
        local result = base.hide();
        for (local i = 0; i < buttons.len(); i++) {
            buttons[i].hide();
        }
        return result;
    }
    
    function appendButton(button) {
        buttons.append(button);
    }
    
    function load() {
        local result = base.load();
        for (local i = 0; i < buttons.len(); i++) {
            buttons[i].load();
        }
        return result;
    }
    
    function setLayout(_layout) {
        layout = _layout;
    }
    
    function layOut() {
        base.move(abstractStage.cameraX, abstractStage.cameraY);
        switch (layout) {
            case imo.S.LAYOUT_HORIZONTAL:
                layoutHorizontal();
                break;
            case imo.S.LAYOUT_VERTICAL:
            default:
                layOutVertical();
                break;
        }
    }
    
    function layOutVertical() {
        local heightTotal = 0;
        for (local i = 0; i < buttons.len(); i++) {
            heightTotal += buttons[i].getHeight();
        }
        heightTotal += (buttonMargin.top + buttonMargin.bottom) * buttons.len();
        
        local offsetY = abstractStage.cameraY + (imo.S.WINDOW_HEIGHT - heightTotal)/2;
        for (local i = 0; i < buttons.len(); i++) {
            local x = abstractStage.cameraX + (imo.S.WINDOW_WIDTH - buttons[i].getWidth())/2;
            local y = offsetY + buttonMargin.top;
            buttons[i].move(x, y);
            offsetY += buttons[i].getHeight() + buttonMargin.bottom;
        }
    }
    
    function layOutHorizontal() {
    
    }
    
    function onMotionEvent(mevent) {
        print("dialog.onMotionEvent()");
        for (local i = 0; i < buttons.len(); i++) {
            local b = buttons[i];
            if (b.contains(abstractStage.eventAbsoluteX(mevent), abstractStage.eventAbsoluteY(mevent))) {
                if (b.hasOnMotionEventHandler()) {
                    if (b.onMotionEvent(mevent)) {
                        continue;
                    } else {
                        break;
                    }
                }
            }
        }
    }
    
    function update(elapsedTime) {
        for (local i = 0; i < buttons.len(); i++) {
            if (buttons[i].hasUpdateHandler()) {
                buttons[i].update(elapsedTime);
            }
        }
    }
}

class imo.DialogButton extends emo.SpriteSheet {
    relativeX = 0;
    relativeY = 0;
    
    function constructor(rawname, frameWidth = 1, frameHeight = 1, border = 0, margin = 0, frameIndex = 0, centerFlag = false) {
        base.constructor(rawname, frameWidth, frameHeight, border, margin, frameIndex, centerFlag);
    }
    
    function setRelativePosition(_relativeX, _relativeY) {
        relativeX = _relativeX;
        relativeY = _relativeY;
    }
        
    function getRelativeX() {
        return relativeX;
    }
    
    function getRelativeY() {
        return relativeY;
    }
}

class imo.AbstractStage {
    world = null;
    floats = [];
    chaseTarget = null;
    
    width = 1000;
    height = 1000;
    
    cameraX = 0;
    cameraY = 0;
    cameraMovedX = 0;
    cameraMovedY = 0;
    cameraAbsoluteOffsetX = 0;
    cameraAbsoluteOffsetY = 0;
    
    function loadWorld() {}
    function loadFloats() {}
    
    constructor() {
    
    }
    
    /*
     * Called when this class is loaded
     */
    function onLoad() {
        print("onLoad");
        world = loadWorld();
        floats = loadFloats();
        emo.Event.enableOnDrawCallback(1000.0 / imo.S.FPS);
        
        rewind();
    }
    
    function rewind() {
    
    }
    
    function setChaseTarget(element) {
        chaseTarget = element;
        updateCameraAbsoluteOffset();
    }
    
    function updateCameraAbsoluteOffset() {
        if (!chaseTarget) return;
        
        cameraAbsoluteOffsetX = imo.S.WINDOW_WIDTH/2;
        cameraAbsoluteOffsetY = (imo.S.WINDOW_HEIGHT - chaseTarget.getY()) / 2;
    }
    
    /*
     * Called when the app has gained focus
     */
    function onGainedFocus() {
        print("onGainedFocus");
    }

    /*
     * Called when the app has lost focus
     */
    function onLostFocus() {
        print("onLostFocus"); 
    }

    /*
     * Called when the class ends
     */
    function onDispose() {
        print("onDispose");
        for (local i = 0; i < floats.len(); i++) {
            floats[i].remove();
        }
    }
    
    function stepWorld(elapsedTime) {
        world.step(elapsedTime/1000.0, 6, 2);
        world.clearForces();
    }
    
    function onDrawFrame(elapsedTime) {
        stepWorld(elapsedTime);
        updateFloats(elapsedTime);
        updateCamera();
        updateParallax();
    }
    
    function appendFloat(float) {
        floats.append(float);
    }
    
    function removeFloat(float) {
        local index = floats.find(float);
        if (index != null) {
            floats.remove(index);
            return true;
        } else {
            return false;
        }
    }
    
    function moveParallax(float) {
        local parallaxBase = 100.0;
        local parallax = float.distance;
        local parallaxX = cameraMovedX * (parallax/parallaxBase);
        float.move(parallaxX + float.getX(), float.getY());
    }
    
    function updateParallax() {
        for (local i = 0; i < floats.len(); i++) {
            if (floats[i].isBackground) moveParallax(floats[i]);
        }
    }
    
    function updateFloats(elapsedTime) {
        for (local i = 0; i < floats.len(); i++) {
            local f = floats[i];
            if (f.hasUpdateHandler()) {
                f.update(elapsedTime);
            }
        }
    }
    
    function updateCamera() {
        if (!chaseTarget) return;
        
        local targetX = chaseTarget.getX();
        local targetY = chaseTarget.getY();
        local newCameraX = 0;
        local newCameraY = 0;
        if (targetX < cameraAbsoluteOffsetX) {
            newCameraX = 0;
        } else if (targetX > width - cameraAbsoluteOffsetX) {
            newCameraX = width - imo.S.WINDOW_WIDTH;
        } else {
            newCameraX = targetX - cameraAbsoluteOffsetX;
        }
        
        if (targetY < cameraAbsoluteOffsetY) {
            newCameraY = 0;
        } else if (targetY > height - cameraAbsoluteOffsetY) {
            newCameraY = height - imo.S.WINDOW_HEIGHT;
        } else {
            newCameraY = targetY - cameraAbsoluteOffsetY;
        }

        emo.Stage.moveCamera(newCameraX, newCameraY);
        cameraMovedX = newCameraX - cameraX;
        cameraMovedY = newCameraY - cameraY;
        cameraX = newCameraX;
        cameraY = newCameraY;
    }
    
    function eventAbsoluteX(mevent) {
        return cameraX + mevent.getX();
    }
    
    function eventAbsoluteY(mevent) {
        return cameraY + mevent.getY();
    }
    
    /*
     * touch event
     */
    function onMotionEvent(mevent) {
        for (local i = 0; i < floats.len(); i++) {
            local f = floats[i];
            if (f.isVisible() && f.contains(eventAbsoluteX(mevent), eventAbsoluteY(mevent))) {
                if (f.hasOnMotionEventHandler()) {
                    print("f.onMotionEvent()");
                    if (f.onMotionEvent(mevent)) {
                        continue;
                    } else {
                        break;
                    }
                }
            }
        }
    }
}

