pragma Singleton

import QtQuick
import Quickshell

// Launcher maths: plain arithmetic ("12*4.5", "2^10") and unit conversion
// ("10km to miles", "160kg in lb", "72f to c"). evaluate() returns
// { value, display, detail } or null when the text isn't something to compute.
Singleton {
    id: root

    // factor = how many base units one unit is; aliases are lowercase
    readonly property var units: [
        // length (metre)
        { dim: "length", f: 0.001, label: "mm", names: ["mm", "millimeter", "millimeters", "millimetre", "millimetres"] },
        { dim: "length", f: 0.01, label: "cm", names: ["cm", "centimeter", "centimeters", "centimetre", "centimetres"] },
        { dim: "length", f: 1, label: "m", names: ["m", "meter", "meters", "metre", "metres"] },
        { dim: "length", f: 1000, label: "km", names: ["km", "kilometer", "kilometers", "kilometre", "kilometres"] },
        { dim: "length", f: 0.0254, label: "in", names: ["in", "inch", "inches", "\""] },
        { dim: "length", f: 0.3048, label: "ft", names: ["ft", "foot", "feet", "'"] },
        { dim: "length", f: 0.9144, label: "yd", names: ["yd", "yard", "yards"] },
        { dim: "length", f: 1609.344, label: "mi", names: ["mi", "mile", "miles"] },
        { dim: "length", f: 1852, label: "nmi", names: ["nmi", "nautical mile", "nautical miles"] },
        // mass (kilogram)
        { dim: "mass", f: 1e-6, label: "mg", names: ["mg", "milligram", "milligrams"] },
        { dim: "mass", f: 0.001, label: "g", names: ["g", "gram", "grams"] },
        { dim: "mass", f: 1, label: "kg", names: ["kg", "kilo", "kilos", "kilogram", "kilograms"] },
        { dim: "mass", f: 1000, label: "t", names: ["t", "tonne", "tonnes", "metric ton", "metric tons"] },
        { dim: "mass", f: 0.028349523125, label: "oz", names: ["oz", "ounce", "ounces"] },
        { dim: "mass", f: 0.45359237, label: "lb", names: ["lb", "lbs", "pound", "pounds"] },
        { dim: "mass", f: 6.35029318, label: "st", names: ["st", "stone", "stones"] },
        // volume (litre)
        { dim: "volume", f: 0.001, label: "ml", names: ["ml", "milliliter", "milliliters", "millilitre", "millilitres"] },
        { dim: "volume", f: 0.01, label: "cl", names: ["cl", "centiliter", "centilitre"] },
        { dim: "volume", f: 1, label: "L", names: ["l", "liter", "liters", "litre", "litres"] },
        { dim: "volume", f: 0.00492892159375, label: "tsp", names: ["tsp", "teaspoon", "teaspoons"] },
        { dim: "volume", f: 0.01478676478125, label: "tbsp", names: ["tbsp", "tablespoon", "tablespoons"] },
        { dim: "volume", f: 0.0295735295625, label: "fl oz", names: ["floz", "fl oz", "fluid ounce", "fluid ounces"] },
        { dim: "volume", f: 0.2365882365, label: "cups", names: ["cup", "cups"] },
        { dim: "volume", f: 0.473176473, label: "pt", names: ["pt", "pint", "pints"] },
        { dim: "volume", f: 0.946352946, label: "qt", names: ["qt", "quart", "quarts"] },
        { dim: "volume", f: 3.785411784, label: "gal", names: ["gal", "gallon", "gallons"] },
        // time (second)
        { dim: "time", f: 0.001, label: "ms", names: ["ms", "millisecond", "milliseconds"] },
        { dim: "time", f: 1, label: "s", names: ["s", "sec", "secs", "second", "seconds"] },
        { dim: "time", f: 60, label: "min", names: ["min", "mins", "minute", "minutes"] },
        { dim: "time", f: 3600, label: "h", names: ["h", "hr", "hrs", "hour", "hours"] },
        { dim: "time", f: 86400, label: "days", names: ["d", "day", "days"] },
        { dim: "time", f: 604800, label: "weeks", names: ["wk", "week", "weeks"] },
        { dim: "time", f: 31557600, label: "years", names: ["yr", "yrs", "year", "years"] },
        // speed (metre per second)
        { dim: "speed", f: 1, label: "m/s", names: ["m/s", "mps"] },
        { dim: "speed", f: 1 / 3.6, label: "km/h", names: ["km/h", "kmh", "kph", "kmph"] },
        { dim: "speed", f: 0.44704, label: "mph", names: ["mph", "mi/h"] },
        { dim: "speed", f: 0.514444, label: "kn", names: ["kn", "kt", "knot", "knots"] },
        // data (byte)
        { dim: "data", f: 0.125, label: "bits", names: ["bit", "bits"] },
        { dim: "data", f: 1, label: "B", names: ["b", "byte", "bytes"] },
        { dim: "data", f: 1e3, label: "KB", names: ["kb", "kilobyte", "kilobytes"] },
        { dim: "data", f: 1e6, label: "MB", names: ["mb", "megabyte", "megabytes"] },
        { dim: "data", f: 1e9, label: "GB", names: ["gb", "gigabyte", "gigabytes"] },
        { dim: "data", f: 1e12, label: "TB", names: ["tb", "terabyte", "terabytes"] },
        { dim: "data", f: 1024, label: "KiB", names: ["kib", "kibibyte", "kibibytes"] },
        { dim: "data", f: 1048576, label: "MiB", names: ["mib", "mebibyte", "mebibytes"] },
        { dim: "data", f: 1073741824, label: "GiB", names: ["gib", "gibibyte", "gibibytes"] },
        { dim: "data", f: 1099511627776, label: "TiB", names: ["tib", "tebibyte", "tebibytes"] },
        // area (square metre)
        { dim: "area", f: 1, label: "m²", names: ["m2", "m²", "sqm", "square meter", "square meters", "square metre", "square metres"] },
        { dim: "area", f: 1e6, label: "km²", names: ["km2", "km²", "square kilometer", "square kilometers"] },
        { dim: "area", f: 0.09290304, label: "ft²", names: ["ft2", "ft²", "sqft", "square foot", "square feet"] },
        { dim: "area", f: 4046.8564224, label: "acres", names: ["acre", "acres", "ac"] },
        { dim: "area", f: 10000, label: "ha", names: ["ha", "hectare", "hectares"] },
        // energy (joule)
        { dim: "energy", f: 1, label: "J", names: ["j", "joule", "joules"] },
        { dim: "energy", f: 1000, label: "kJ", names: ["kj", "kilojoule", "kilojoules"] },
        { dim: "energy", f: 4184, label: "kcal", names: ["kcal", "calorie", "calories", "cal"] },
        { dim: "energy", f: 3.6e6, label: "kWh", names: ["kwh"] },
        // temperature (handled specially)
        { dim: "temp", label: "°C", names: ["c", "°c", "celsius", "centigrade", "degc"] },
        { dim: "temp", label: "°F", names: ["f", "°f", "fahrenheit", "degf"] },
        { dim: "temp", label: "K", names: ["k", "kelvin", "kelvins"] }
    ]

    function unit(name: string): var {
        const n = name.trim().toLowerCase().replace(/\s+/g, " ").replace(/^degrees? /, "");
        if (n === "")
            return null;
        return units.find(u => u.names.includes(n)) ?? null;
    }

    function toKelvin(v: real, label: string): real {
        return label === "°C" ? v + 273.15 : label === "°F" ? (v - 32) * 5 / 9 + 273.15 : v;
    }
    function fromKelvin(v: real, label: string): real {
        return label === "°C" ? v - 273.15 : label === "°F" ? (v - 273.15) * 9 / 5 + 32 : v;
    }

    // Up to 6 significant digits, thousands separated, no trailing zeros.
    function format(v: real): string {
        if (v === 0)
            return "0";
        const a = Math.abs(v);
        if (a >= 1e15 || a < 1e-6)
            return v.toExponential(4).replace(/\.?0+e/, "e");
        const s = String(Number(v.toPrecision(a >= 1e6 ? 12 : 6)));
        const [i, f] = s.split(".");
        return i.replace(/\B(?=(\d{3})+(?!\d))/g, ",") + (f ? "." + f : "");
    }

    function arithmetic(expr: string): var {
        const e = expr.replace(/×/g, "*").replace(/÷/g, "/").replace(/,/g, "").trim();
        // digits, operators and parentheses only — never arbitrary code
        if (e === "" || !/^[\d\s+\-*/().%^e]+$/i.test(e) || !/\d/.test(e))
            return null;
        try {
            const v = Function(`"use strict"; return (${e.replace(/\^/g, "**")});`)();
            return typeof v === "number" && isFinite(v) ? v : null;
        } catch (err) {
            return null;
        }
    }

    // "10km to miles", "160 kg in lb", "72°F to C"
    function convert(text: string): var {
        const m = text.trim().match(/^([-+]?[\d.,]*\d(?:e[-+]?\d+)?)\s*(.+?)\s+(?:to|in|into|as|->|=)\s+(.+)$/i);
        if (!m)
            return null;
        const v = parseFloat(m[1].replace(/,/g, ""));
        const from = unit(m[2]);
        const to = unit(m[3]);
        if (!isFinite(v) || !from || !to || from.dim !== to.dim)
            return null;
        const out = from.dim === "temp" ? fromKelvin(toKelvin(v, from.label), to.label) : v * from.f / to.f;
        return {
            value: out,
            display: format(out) + " " + to.label,
            detail: format(v) + " " + from.label + " ="
        };
    }

    function evaluate(text: string): var {
        const c = convert(text);
        if (c)
            return c;
        const t = text.trim();
        // a bare number isn't a calculation
        if (/^[-+]?[\d.,]+$/.test(t))
            return null;
        const v = arithmetic(t);
        if (v === null)
            return null;
        return { value: v, display: format(v), detail: t + " =" };
    }
}
