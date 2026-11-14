import QtQuick
import QtQuick.Shapes

// The island silhouette. With flare > 0 it hangs from the top edge and the
// top corners curve *outwards* into the bezel, like a hardware notch.
// The shape spans [-flare, w + flare] horizontally; position it at x = -flare.
Shape {
    id: root

    property real w: 100
    property real h: 32
    property real r: 14
    property real flare: 12
    property color color: "black"

    readonly property real f: Math.max(0, Math.min(flare, h / 2))
    readonly property real rr: Math.max(0, Math.min(r, h - f, w / 2))

    width: w + 2 * f
    height: h
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: root.color
        strokeWidth: -1
        strokeColor: "transparent"

        startX: 0
        startY: 0

        // left flare
        PathQuad { x: root.f; y: root.f; controlX: root.f; controlY: 0 }
        PathLine { x: root.f; y: root.h - root.rr }
        PathArc {
            x: root.f + root.rr; y: root.h
            radiusX: root.rr; radiusY: root.rr
            direction: PathArc.Counterclockwise
        }
        PathLine { x: root.f + root.w - root.rr; y: root.h }
        PathArc {
            x: root.f + root.w; y: root.h - root.rr
            radiusX: root.rr; radiusY: root.rr
            direction: PathArc.Counterclockwise
        }
        PathLine { x: root.f + root.w; y: root.f }
        // right flare
        PathQuad { x: root.w + 2 * root.f; y: 0; controlX: root.f + root.w; controlY: 0 }
        PathLine { x: 0; y: 0 }
    }
}
