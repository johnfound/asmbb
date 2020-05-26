/*! highlight.js v9.18.1 | BSD3 License | git.io/hljslicense */ ! function (e) {
    var n = "object" == typeof window && window || "object" == typeof self && self;
    "undefined" == typeof exports || exports.nodeType ? n && (n.hljs = e({}), "function" == typeof define && define.amd && define([], function () {
        return n.hljs
    })) : e(exports)
}(function (a) {
    var f = [],
        i = Object.keys,
        _ = {},
        c = {},
        C = !0,
        n = /^(no-?highlight|plain|text)$/i,
        l = /\blang(?:uage)?-([\w-]+)\b/i,
        t = /((^(<[^>]+>|\t|)+|(?:\n)))/gm,
        r = {
            case_insensitive: "cI",
            lexemes: "l",
            contains: "c",
            keywords: "k",
            subLanguage: "sL",
            className: "cN",
            begin: "b",
            beginKeywords: "bK",
            end: "e",
            endsWithParent: "eW",
            illegal: "i",
            excludeBegin: "eB",
            excludeEnd: "eE",
            returnBegin: "rB",
            returnEnd: "rE",
            variants: "v",
            IDENT_RE: "IR",
            UNDERSCORE_IDENT_RE: "UIR",
            NUMBER_RE: "NR",
            C_NUMBER_RE: "CNR",
            BINARY_NUMBER_RE: "BNR",
            RE_STARTERS_RE: "RSR",
            BACKSLASH_ESCAPE: "BE",
            APOS_STRING_MODE: "ASM",
            QUOTE_STRING_MODE: "QSM",
            PHRASAL_WORDS_MODE: "PWM",
            C_LINE_COMMENT_MODE: "CLCM",
            C_BLOCK_COMMENT_MODE: "CBCM",
            HASH_COMMENT_MODE: "HCM",
            NUMBER_MODE: "NM",
            C_NUMBER_MODE: "CNM",
            BINARY_NUMBER_MODE: "BNM",
            CSS_NUMBER_MODE: "CSSNM",
            REGEXP_MODE: "RM",
            TITLE_MODE: "TM",
            UNDERSCORE_TITLE_MODE: "UTM",
            COMMENT: "C",
            beginRe: "bR",
            endRe: "eR",
            illegalRe: "iR",
            lexemesRe: "lR",
            terminators: "t",
            terminator_end: "tE"
        },
        m = "</span>",
        O = "Could not find the language '{}', did you forget to load/include a language module?",
        B = {
            classPrefix: "hljs-",
            tabReplace: null,
            useBR: !1,
            languages: void 0
        },
        o = "of and for in not or if then".split(" ");

    function x(e) {
        return e.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    }

    function g(e) {
        return e.nodeName.toLowerCase()
    }

    function u(e) {
        return n.test(e)
    }

    function s(e) {
        var n, t = {},
            r = Array.prototype.slice.call(arguments, 1);
        for (n in e) t[n] = e[n];
        return r.forEach(function (e) {
            for (n in e) t[n] = e[n]
        }), t
    }

    function E(e) {
        var a = [];
        return function e(n, t) {
            for (var r = n.firstChild; r; r = r.nextSibling) 3 === r.nodeType ? t += r.nodeValue.length : 1 === r.nodeType && (a.push({
                event: "start",
                offset: t,
                node: r
            }), t = e(r, t), g(r).match(/br|hr|img|input/) || a.push({
                event: "stop",
                offset: t,
                node: r
            }));
            return t
        }(e, 0), a
    }

    function d(e, n, t) {
        var r = 0,
            a = "",
            i = [];

        function o() {
            return e.length && n.length ? e[0].offset !== n[0].offset ? e[0].offset < n[0].offset ? e : n : "start" === n[0].event ? e : n : e.length ? e : n
        }

        function c(e) {
            a += "<" + g(e) + f.map.call(e.attributes, function (e) {
                return " " + e.nodeName + '="' + x(e.value).replace(/"/g, "&quot;") + '"'
            }).join("") + ">"
        }

        function l(e) {
            a += "</" + g(e) + ">"
        }

        function u(e) {
            ("start" === e.event ? c : l)(e.node)
        }
        for (; e.length || n.length;) {
            var s = o();
            if (a += x(t.substring(r, s[0].offset)), r = s[0].offset, s === e) {
                for (i.reverse().forEach(l); u(s.splice(0, 1)[0]), (s = o()) === e && s.length && s[0].offset === r;);
                i.reverse().forEach(c)
            } else "start" === s[0].event ? i.push(s[0].node) : i.pop(), u(s.splice(0, 1)[0])
        }
        return a + x(t.substr(r))
    }

    function R(n) {
        return n.v && !n.cached_variants && (n.cached_variants = n.v.map(function (e) {
            return s(n, {
                v: null
            }, e)
        })), n.cached_variants ? n.cached_variants : function e(n) {
            return !!n && (n.eW || e(n.starts))
        }(n) ? [s(n, {
            starts: n.starts ? s(n.starts) : null
        })] : Object.isFrozen(n) ? [s(n)] : [n]
    }

    function p(e) {
        if (r && !e.langApiRestored) {
            for (var n in e.langApiRestored = !0, r) e[n] && (e[r[n]] = e[n]);
            (e.c || []).concat(e.v || []).forEach(p)
        }
    }

    function v(n, r) {
        var a = {};
        return "string" == typeof n ? t("keyword", n) : i(n).forEach(function (e) {
            t(e, n[e])
        }), a;

        function t(t, e) {
            r && (e = e.toLowerCase()), e.split(" ").forEach(function (e) {
                var n = e.split("|");
                a[n[0]] = [t, function (e, n) {
                    return n ? Number(n) : function (e) {
                        return -1 != o.indexOf(e.toLowerCase())
                    }(e) ? 0 : 1
                }(n[0], n[1])]
            })
        }
    }

    function S(r) {
        function s(e) {
            return e && e.source || e
        }

        function f(e, n) {
            return new RegExp(s(e), "m" + (r.cI ? "i" : "") + (n ? "g" : ""))
        }

        function a(a) {
            var i, e, o = {},
                c = [],
                l = {},
                t = 1;

            function n(e, n) {
                o[t] = e, c.push([e, n]), t += function (e) {
                    return new RegExp(e.toString() + "|").exec("").length - 1
                }(n) + 1
            }
            for (var r = 0; r < a.c.length; r++) {
                n(e = a.c[r], e.bK ? "\\.?(?:" + e.b + ")\\.?" : e.b)
            }
            a.tE && n("end", a.tE), a.i && n("illegal", a.i);
            var u = c.map(function (e) {
                return e[1]
            });
            return i = f(function (e, n) {
                for (var t = /\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\./, r = 0, a = "", i = 0; i < e.length; i++) {
                    var o = r += 1,
                        c = s(e[i]);
                    for (0 < i && (a += n), a += "("; 0 < c.length;) {
                        var l = t.exec(c);
                        if (null == l) {
                            a += c;
                            break
                        }
                        a += c.substring(0, l.index), c = c.substring(l.index + l[0].length), "\\" == l[0][0] && l[1] ? a += "\\" + String(Number(l[1]) + o) : (a += l[0], "(" == l[0] && r++)
                    }
                    a += ")"
                }
                return a
            }(u, "|"), !0), l.lastIndex = 0, l.exec = function (e) {
                var n;
                if (0 === c.length) return null;
                i.lastIndex = l.lastIndex;
                var t = i.exec(e);
                if (!t) return null;
                for (var r = 0; r < t.length; r++)
                    if (null != t[r] && null != o["" + r]) {
                        n = o["" + r];
                        break
                    } return "string" == typeof n ? (t.type = n, t.extra = [a.i, a.tE]) : (t.type = "begin", t.rule = n), t
            }, l
        }
        if (r.c && -1 != r.c.indexOf("self")) {
            if (!C) throw new Error("ERR: contains `self` is not supported at the top-level of a language.  See documentation.");
            r.c = r.c.filter(function (e) {
                return "self" != e
            })
        }! function n(t, e) {
            t.compiled || (t.compiled = !0, t.k = t.k || t.bK, t.k && (t.k = v(t.k, r.cI)), t.lR = f(t.l || /\w+/, !0), e && (t.bK && (t.b = "\\b(" + t.bK.split(" ").join("|") + ")\\b"), t.b || (t.b = /\B|\b/), t.bR = f(t.b), t.endSameAsBegin && (t.e = t.b), t.e || t.eW || (t.e = /\B|\b/), t.e && (t.eR = f(t.e)), t.tE = s(t.e) || "", t.eW && e.tE && (t.tE += (t.e ? "|" : "") + e.tE)), t.i && (t.iR = f(t.i)), null == t.relevance && (t.relevance = 1), t.c || (t.c = []), t.c = Array.prototype.concat.apply([], t.c.map(function (e) {
                return R("self" === e ? t : e)
            })), t.c.forEach(function (e) {
                n(e, t)
            }), t.starts && n(t.starts, e), t.t = a(t))
        }(r)
    }

    function T(n, e, a, t) {
        var i = e;

        function o(e, n) {
            if (function (e, n) {
                    var t = e && e.exec(n);
                    return t && 0 === t.index
                }(e.eR, n)) {
                for (; e.endsParent && e.parent;) e = e.parent;
                return e
            }
            if (e.eW) return o(e.parent, n)
        }

        function c(e, n, t, r) {
            if (!t && "" === n) return "";
            if (!e) return n;
            var a = '<span class="' + (r ? "" : B.classPrefix);
            return (a += e + '">') + n + (t ? "" : m)
        }

        function l() {
            p += null != d.sL ? function () {
                var e = "string" == typeof d.sL;
                if (e && !_[d.sL]) return x(v);
                var n = e ? T(d.sL, v, !0, R[d.sL]) : w(v, d.sL.length ? d.sL : void 0);
                return 0 < d.relevance && (M += n.relevance), e && (R[d.sL] = n.top), c(n.language, n.value, !1, !0)
            }() : function () {
                var e, n, t, r, a, i, o;
                if (!d.k) return x(v);
                for (r = "", n = 0, d.lR.lastIndex = 0, t = d.lR.exec(v); t;) r += x(v.substring(n, t.index)), a = d, i = t, void 0, o = g.cI ? i[0].toLowerCase() : i[0], (e = a.k.hasOwnProperty(o) && a.k[o]) ? (M += e[1], r += c(e[0], x(t[0]))) : r += x(t[0]), n = d.lR.lastIndex, t = d.lR.exec(v);
                return r + x(v.substr(n))
            }(), v = ""
        }

        function u(e) {
            p += e.cN ? c(e.cN, "", !0) : "", d = Object.create(e, {
                parent: {
                    value: d
                }
            })
        }

        function s(e) {
            var n = e[0],
                t = e.rule;
            return t && t.endSameAsBegin && (t.eR = function (e) {
                return new RegExp(e.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&"), "m")
            }(n)), t.skip ? v += n : (t.eB && (v += n), l(), t.rB || t.eB || (v = n)), u(t), t.rB ? 0 : n.length
        }
        var f = {};

        function r(e, n) {
            var t = n && n[0];
            if (v += e, null == t) return l(), 0;
            if ("begin" == f.type && "end" == n.type && f.index == n.index && "" === t) return v += i.slice(n.index, n.index + 1), 1;
            if ("begin" === (f = n).type) return s(n);
            if ("illegal" === n.type && !a) throw new Error('Illegal lexeme "' + t + '" for mode "' + (d.cN || "<unnamed>") + '"');
            if ("end" === n.type) {
                var r = function (e) {
                    var n = e[0],
                        t = i.substr(e.index),
                        r = o(d, t);
                    if (r) {
                        var a = d;
                        for (a.skip ? v += n : (a.rE || a.eE || (v += n), l(), a.eE && (v = n)); d.cN && (p += m), d.skip || d.sL || (M += d.relevance), (d = d.parent) !== r.parent;);
                        return r.starts && (r.endSameAsBegin && (r.starts.eR = r.eR), u(r.starts)), a.rE ? 0 : n.length
                    }
                }(n);
                if (null != r) return r
            }
            return v += t, t.length
        }
        var g = D(n);
        if (!g) throw console.error(O.replace("{}", n)), new Error('Unknown language: "' + n + '"');
        S(g);
        var E, d = t || g,
            R = {},
            p = "";
        for (E = d; E !== g; E = E.parent) E.cN && (p = c(E.cN, "", !0) + p);
        var v = "",
            M = 0;
        try {
            for (var b, h, N = 0; d.t.lastIndex = N, b = d.t.exec(i);) h = r(i.substring(N, b.index), b), N = b.index + h;
            for (r(i.substr(N)), E = d; E.parent; E = E.parent) E.cN && (p += m);
            return {
                relevance: M,
                value: p,
                i: !1,
                language: n,
                top: d
            }
        } catch (e) {
            if (e.message && -1 !== e.message.indexOf("Illegal")) return {
                i: !0,
                relevance: 0,
                value: x(i)
            };
            if (C) return {
                relevance: 0,
                value: x(i),
                language: n,
                top: d,
                errorRaised: e
            };
            throw e
        }
    }

    function w(t, e) {
        e = e || B.languages || i(_);
        var r = {
                relevance: 0,
                value: x(t)
            },
            a = r;
        return e.filter(D).filter(L).forEach(function (e) {
            var n = T(e, t, !1);
            n.language = e, n.relevance > a.relevance && (a = n), n.relevance > r.relevance && (a = r, r = n)
        }), a.language && (r.second_best = a), r
    }

    function M(e) {
        return B.tabReplace || B.useBR ? e.replace(t, function (e, n) {
            return B.useBR && "\n" === e ? "<br>" : B.tabReplace ? n.replace(/\t/g, B.tabReplace) : ""
        }) : e
    }

    function b(e) {
        var n, t, r, a, i, o = function (e) {
            var n, t, r, a, i = e.className + " ";
            if (i += e.parentNode ? e.parentNode.className : "", t = l.exec(i)) {
                var o = D(t[1]);
                return o || (console.warn(O.replace("{}", t[1])), console.warn("Falling back to no-highlight mode for this block.", e)), o ? t[1] : "no-highlight"
            }
            for (n = 0, r = (i = i.split(/\s+/)).length; n < r; n++)
                if (u(a = i[n]) || D(a)) return a
        }(e);
        u(o) || (B.useBR ? (n = document.createElement("div")).innerHTML = e.innerHTML.replace(/\n/g, "").replace(/<br[ \/]*>/g, "\n") : n = e, i = n.textContent, r = o ? T(o, i, !0) : w(i), (t = E(n)).length && ((a = document.createElement("div")).innerHTML = r.value, r.value = d(t, E(a), i)), r.value = M(r.value), e.innerHTML = r.value, e.className = function (e, n, t) {
            var r = n ? c[n] : t,
                a = [e.trim()];
            return e.match(/\bhljs\b/) || a.push("hljs"), -1 === e.indexOf(r) && a.push(r), a.join(" ").trim()
        }(e.className, o, r.language), e.result = {
            language: r.language,
            re: r.relevance
        }, r.second_best && (e.second_best = {
            language: r.second_best.language,
            re: r.second_best.relevance
        }))
    }

    function h() {
        if (!h.called) {
            h.called = !0;
            var e = document.querySelectorAll("pre code");
            f.forEach.call(e, b)
        }
    }
    var N = {
        disableAutodetect: !0
    };

    function D(e) {
        return e = (e || "").toLowerCase(), _[e] || _[c[e]]
    }

    function L(e) {
        var n = D(e);
        return n && !n.disableAutodetect
    }
    return a.highlight = T, a.highlightAuto = w, a.fixMarkup = M, a.highlightBlock = b, a.configure = function (e) {
        B = s(B, e)
    }, a.initHighlighting = h, a.initHighlightingOnLoad = function () {
        window.addEventListener("DOMContentLoaded", h, !1), window.addEventListener("load", h, !1)
    }, a.registerLanguage = function (n, e) {
        var t;
        try {
            t = e(a)
        } catch (e) {
            if (console.error("Language definition for '{}' could not be registered.".replace("{}", n)), !C) throw e;
            console.error(e), t = N
        }
        p(_[n] = t), t.rawDefinition = e.bind(null, a), t.aliases && t.aliases.forEach(function (e) {
            c[e] = n
        })
    }, a.listLanguages = function () {
        return i(_)
    }, a.getLanguage = D, a.requireLanguage = function (e) {
        var n = D(e);
        if (n) return n;
        throw new Error("The '{}' language is required, but not loaded.".replace("{}", e))
    }, a.autoDetection = L, a.inherit = s, a.debugMode = function () {
        C = !1
    }, a.IR = a.IDENT_RE = "[a-zA-Z]\\w*", a.UIR = a.UNDERSCORE_IDENT_RE = "[a-zA-Z_]\\w*", a.NR = a.NUMBER_RE = "\\b\\d+(\\.\\d+)?", a.CNR = a.C_NUMBER_RE = "(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)", a.BNR = a.BINARY_NUMBER_RE = "\\b(0b[01]+)", a.RSR = a.RE_STARTERS_RE = "!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~", a.BE = a.BACKSLASH_ESCAPE = {
        b: "\\\\[\\s\\S]",
        relevance: 0
    }, a.ASM = a.APOS_STRING_MODE = {
        cN: "string",
        b: "'",
        e: "'",
        i: "\\n",
        c: [a.BE]
    }, a.QSM = a.QUOTE_STRING_MODE = {
        cN: "string",
        b: '"',
        e: '"',
        i: "\\n",
        c: [a.BE]
    }, a.PWM = a.PHRASAL_WORDS_MODE = {
        b: /\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b/
    }, a.C = a.COMMENT = function (e, n, t) {
        var r = a.inherit({
            cN: "comment",
            b: e,
            e: n,
            c: []
        }, t || {});
        return r.c.push(a.PWM), r.c.push({
            cN: "doctag",
            b: "(?:TODO|FIXME|NOTE|BUG|XXX):",
            relevance: 0
        }), r
    }, a.CLCM = a.C_LINE_COMMENT_MODE = a.C("//", "$"), a.CBCM = a.C_BLOCK_COMMENT_MODE = a.C("/\\*", "\\*/"), a.HCM = a.HASH_COMMENT_MODE = a.C("#", "$"), a.NM = a.NUMBER_MODE = {
        cN: "number",
        b: a.NR,
        relevance: 0
    }, a.CNM = a.C_NUMBER_MODE = {
        cN: "number",
        b: a.CNR,
        relevance: 0
    }, a.BNM = a.BINARY_NUMBER_MODE = {
        cN: "number",
        b: a.BNR,
        relevance: 0
    }, a.CSSNM = a.CSS_NUMBER_MODE = {
        cN: "number",
        b: a.NR + "(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px|deg|grad|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)?",
        relevance: 0
    }, a.RM = a.REGEXP_MODE = {
        cN: "regexp",
        b: /\//,
        e: /\/[gimuy]*/,
        i: /\n/,
        c: [a.BE, {
            b: /\[/,
            e: /\]/,
            relevance: 0,
            c: [a.BE]
        }]
    }, a.TM = a.TITLE_MODE = {
        cN: "title",
        b: a.IR,
        relevance: 0
    }, a.UTM = a.UNDERSCORE_TITLE_MODE = {
        cN: "title",
        b: a.UIR,
        relevance: 0
    }, a.METHOD_GUARD = {
        b: "\\.\\s*" + a.UIR,
        relevance: 0
    }, [a.BE, a.ASM, a.QSM, a.PWM, a.C, a.CLCM, a.CBCM, a.HCM, a.NM, a.CNM, a.BNM, a.CSSNM, a.RM, a.TM, a.UTM, a.METHOD_GUARD].forEach(function (e) {
        ! function n(t) {
            Object.freeze(t);
            var r = "function" == typeof t;
            Object.getOwnPropertyNames(t).forEach(function (e) {
                !t.hasOwnProperty(e) || null === t[e] || "object" != typeof t[e] && "function" != typeof t[e] || r && ("caller" === e || "callee" === e || "arguments" === e) || Object.isFrozen(t[e]) || n(t[e])
            });
            return t
        }(e)
    }), a
});
hljs.registerLanguage("less", function (e) {
    function r(e) {
        return {
            cN: "string",
            b: "~?" + e + ".*?" + e
        }
    }

    function t(e, r, t) {
        return {
            cN: e,
            b: r,
            relevance: t
        }
    }
    var a = "[\\w-]+",
        c = "(" + a + "|@{" + a + "})",
        s = [],
        n = [],
        b = {
            b: "\\(",
            e: "\\)",
            c: n,
            relevance: 0
        };
    n.push(e.CLCM, e.CBCM, r("'"), r('"'), e.CSSNM, {
        b: "(url|data-uri)\\(",
        starts: {
            cN: "string",
            e: "[\\)\\n]",
            eE: !0
        }
    }, t("number", "#[0-9A-Fa-f]+\\b"), b, t("variable", "@@?" + a, 10), t("variable", "@{" + a + "}"), t("built_in", "~?`[^`]*?`"), {
        cN: "attribute",
        b: a + "\\s*:",
        e: ":",
        rB: !0,
        eE: !0
    }, {
        cN: "meta",
        b: "!important"
    });
    var i = n.concat({
            b: "{",
            e: "}",
            c: s
        }),
        l = {
            bK: "when",
            eW: !0,
            c: [{
                bK: "and not"
            }].concat(n)
        },
        o = {
            b: c + "\\s*:",
            rB: !0,
            e: "[;}]",
            relevance: 0,
            c: [{
                cN: "attribute",
                b: c,
                e: ":",
                eE: !0,
                starts: {
                    eW: !0,
                    i: "[<=$]",
                    relevance: 0,
                    c: n
                }
            }]
        },
        u = {
            cN: "keyword",
            b: "@(import|media|charset|font-face|(-[a-z]+-)?keyframes|supports|document|namespace|page|viewport|host)\\b",
            starts: {
                e: "[;{}]",
                rE: !0,
                c: n,
                relevance: 0
            }
        },
        v = {
            cN: "variable",
            v: [{
                b: "@" + a + "\\s*:",
                relevance: 15
            }, {
                b: "@" + a
            }],
            starts: {
                e: "[;}]",
                rE: !0,
                c: i
            }
        },
        C = {
            v: [{
                b: "[\\.#:&\\[>]",
                e: "[;{}]"
            }, {
                b: c,
                e: "{"
            }],
            rB: !0,
            rE: !0,
            i: "[<='$\"]",
            relevance: 0,
            c: [e.CLCM, e.CBCM, l, t("keyword", "all\\b"), t("variable", "@{" + a + "}"), t("selector-tag", c + "%?", 0), t("selector-id", "#" + c), t("selector-class", "\\." + c, 0), t("selector-tag", "&", 0), {
                cN: "selector-attr",
                b: "\\[",
                e: "\\]"
            }, {
                cN: "selector-pseudo",
                b: /:(:)?[a-zA-Z0-9\_\-\+\(\)"'.]+/
            }, {
                b: "\\(",
                e: "\\)",
                c: i
            }, {
                b: "!important"
            }]
        };
    return s.push(e.CLCM, e.CBCM, u, v, o, C), {
        cI: !0,
        i: "[=>'/<($\"]",
        c: s
    }
});
hljs.registerLanguage("armasm", function (s) {
    return {
        cI: !0,
        aliases: ["arm"],
        l: "\\.?" + s.IR,
        k: {
            meta: ".2byte .4byte .align .ascii .asciz .balign .byte .code .data .else .end .endif .endm .endr .equ .err .exitm .extern .global .hword .if .ifdef .ifndef .include .irp .long .macro .rept .req .section .set .skip .space .text .word .arm .thumb .code16 .code32 .force_thumb .thumb_func .ltorg ALIAS ALIGN ARM AREA ASSERT ATTR CN CODE CODE16 CODE32 COMMON CP DATA DCB DCD DCDU DCDO DCFD DCFDU DCI DCQ DCQU DCW DCWU DN ELIF ELSE END ENDFUNC ENDIF ENDP ENTRY EQU EXPORT EXPORTAS EXTERN FIELD FILL FUNCTION GBLA GBLL GBLS GET GLOBAL IF IMPORT INCBIN INCLUDE INFO KEEP LCLA LCLL LCLS LTORG MACRO MAP MEND MEXIT NOFP OPT PRESERVE8 PROC QN READONLY RELOC REQUIRE REQUIRE8 RLIST FN ROUT SETA SETL SETS SN SPACE SUBT THUMB THUMBX TTL WHILE WEND ",
            built_in: "r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 pc lr sp ip sl sb fp a1 a2 a3 a4 v1 v2 v3 v4 v5 v6 v7 v8 f0 f1 f2 f3 f4 f5 f6 f7 p0 p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 q0 q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 cpsr_c cpsr_x cpsr_s cpsr_f cpsr_cx cpsr_cxs cpsr_xs cpsr_xsf cpsr_sf cpsr_cxsf spsr_c spsr_x spsr_s spsr_f spsr_cx spsr_cxs spsr_xs spsr_xsf spsr_sf spsr_cxsf s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23 s24 s25 s26 s27 s28 s29 s30 s31 d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24 d25 d26 d27 d28 d29 d30 d31 {PC} {VAR} {TRUE} {FALSE} {OPT} {CONFIG} {ENDIAN} {CODESIZE} {CPU} {FPU} {ARCHITECTURE} {PCSTOREOFFSET} {ARMASM_VERSION} {INTER} {ROPI} {RWPI} {SWST} {NOSWST} . @"
        },
        c: [{
            cN: "keyword",
            b: "\\b(adc|(qd?|sh?|u[qh]?)?add(8|16)?|usada?8|(q|sh?|u[qh]?)?(as|sa)x|and|adrl?|sbc|rs[bc]|asr|b[lx]?|blx|bxj|cbn?z|tb[bh]|bic|bfc|bfi|[su]bfx|bkpt|cdp2?|clz|clrex|cmp|cmn|cpsi[ed]|cps|setend|dbg|dmb|dsb|eor|isb|it[te]{0,3}|lsl|lsr|ror|rrx|ldm(([id][ab])|f[ds])?|ldr((s|ex)?[bhd])?|movt?|mvn|mra|mar|mul|[us]mull|smul[bwt][bt]|smu[as]d|smmul|smmla|mla|umlaal|smlal?([wbt][bt]|d)|mls|smlsl?[ds]|smc|svc|sev|mia([bt]{2}|ph)?|mrr?c2?|mcrr2?|mrs|msr|orr|orn|pkh(tb|bt)|rbit|rev(16|sh)?|sel|[su]sat(16)?|nop|pop|push|rfe([id][ab])?|stm([id][ab])?|str(ex)?[bhd]?|(qd?)?sub|(sh?|q|u[qh]?)?sub(8|16)|[su]xt(a?h|a?b(16)?)|srs([id][ab])?|swpb?|swi|smi|tst|teq|wfe|wfi|yield)(eq|ne|cs|cc|mi|pl|vs|vc|hi|ls|ge|lt|gt|le|al|hs|lo)?[sptrx]?",
            e: "\\s"
        }, s.C("[;@]", "$", {
            relevance: 0
        }), s.CBCM, s.QSM, {
            cN: "string",
            b: "'",
            e: "[^\\\\]'",
            relevance: 0
        }, {
            cN: "title",
            b: "\\|",
            e: "\\|",
            i: "\\n",
            relevance: 0
        }, {
            cN: "number",
            v: [{
                b: "[#$=]?0x[0-9a-f]+"
            }, {
                b: "[#$=]?0b[01]+"
            }, {
                b: "[#$=]\\d+"
            }, {
                b: "\\b\\d+"
            }],
            relevance: 0
        }, {
            cN: "symbol",
            v: [{
                b: "^[a-z_\\.\\$][a-z0-9_\\.\\$]+"
            }, {
                b: "^\\s*[a-z_\\.\\$][a-z0-9_\\.\\$]+:"
            }, {
                b: "[=#]\\w+"
            }],
            relevance: 0
        }]
    }
});
hljs.registerLanguage("plaintext", function (e) {
    return {
        disableAutodetect: !0
    }
});
hljs.registerLanguage("scss", function (e) {
    var t = "@[a-z-]+",
        r = {
            cN: "variable",
            b: "(\\$[a-zA-Z-][a-zA-Z0-9_-]*)\\b"
        },
        i = {
            cN: "number",
            b: "#[0-9A-Fa-f]+"
        };
    e.CSSNM, e.QSM, e.ASM, e.CBCM;
    return {
        cI: !0,
        i: "[=/|']",
        c: [e.CLCM, e.CBCM, {
            cN: "selector-id",
            b: "\\#[A-Za-z0-9_-]+",
            relevance: 0
        }, {
            cN: "selector-class",
            b: "\\.[A-Za-z0-9_-]+",
            relevance: 0
        }, {
            cN: "selector-attr",
            b: "\\[",
            e: "\\]",
            i: "$"
        }, {
            cN: "selector-tag",
            b: "\\b(a|abbr|acronym|address|area|article|aside|audio|b|base|big|blockquote|body|br|button|canvas|caption|cite|code|col|colgroup|command|datalist|dd|del|details|dfn|div|dl|dt|em|embed|fieldset|figcaption|figure|footer|form|frame|frameset|(h[1-6])|head|header|hgroup|hr|html|i|iframe|img|input|ins|kbd|keygen|label|legend|li|link|map|mark|meta|meter|nav|noframes|noscript|object|ol|optgroup|option|output|p|param|pre|progress|q|rp|rt|ruby|samp|script|section|select|small|span|strike|strong|style|sub|sup|table|tbody|td|textarea|tfoot|th|thead|time|title|tr|tt|ul|var|video)\\b",
            relevance: 0
        }, {
            cN: "selector-pseudo",
            b: ":(visited|valid|root|right|required|read-write|read-only|out-range|optional|only-of-type|only-child|nth-of-type|nth-last-of-type|nth-last-child|nth-child|not|link|left|last-of-type|last-child|lang|invalid|indeterminate|in-range|hover|focus|first-of-type|first-line|first-letter|first-child|first|enabled|empty|disabled|default|checked|before|after|active)"
        }, {
            cN: "selector-pseudo",
            b: "::(after|before|choices|first-letter|first-line|repeat-index|repeat-item|selection|value)"
        }, r, {
            cN: "attribute",
            b: "\\b(src|z-index|word-wrap|word-spacing|word-break|width|widows|white-space|visibility|vertical-align|unicode-bidi|transition-timing-function|transition-property|transition-duration|transition-delay|transition|transform-style|transform-origin|transform|top|text-underline-position|text-transform|text-shadow|text-rendering|text-overflow|text-indent|text-decoration-style|text-decoration-line|text-decoration-color|text-decoration|text-align-last|text-align|tab-size|table-layout|right|resize|quotes|position|pointer-events|perspective-origin|perspective|page-break-inside|page-break-before|page-break-after|padding-top|padding-right|padding-left|padding-bottom|padding|overflow-y|overflow-x|overflow-wrap|overflow|outline-width|outline-style|outline-offset|outline-color|outline|orphans|order|opacity|object-position|object-fit|normal|none|nav-up|nav-right|nav-left|nav-index|nav-down|min-width|min-height|max-width|max-height|mask|marks|margin-top|margin-right|margin-left|margin-bottom|margin|list-style-type|list-style-position|list-style-image|list-style|line-height|letter-spacing|left|justify-content|initial|inherit|ime-mode|image-orientation|image-resolution|image-rendering|icon|hyphens|height|font-weight|font-variant-ligatures|font-variant|font-style|font-stretch|font-size-adjust|font-size|font-language-override|font-kerning|font-feature-settings|font-family|font|float|flex-wrap|flex-shrink|flex-grow|flex-flow|flex-direction|flex-basis|flex|filter|empty-cells|display|direction|cursor|counter-reset|counter-increment|content|column-width|column-span|column-rule-width|column-rule-style|column-rule-color|column-rule|column-gap|column-fill|column-count|columns|color|clip-path|clip|clear|caption-side|break-inside|break-before|break-after|box-sizing|box-shadow|box-decoration-break|bottom|border-width|border-top-width|border-top-style|border-top-right-radius|border-top-left-radius|border-top-color|border-top|border-style|border-spacing|border-right-width|border-right-style|border-right-color|border-right|border-radius|border-left-width|border-left-style|border-left-color|border-left|border-image-width|border-image-source|border-image-slice|border-image-repeat|border-image-outset|border-image|border-color|border-collapse|border-bottom-width|border-bottom-style|border-bottom-right-radius|border-bottom-left-radius|border-bottom-color|border-bottom|border|background-size|background-repeat|background-position|background-origin|background-image|background-color|background-clip|background-attachment|background-blend-mode|background|backface-visibility|auto|animation-timing-function|animation-play-state|animation-name|animation-iteration-count|animation-fill-mode|animation-duration|animation-direction|animation-delay|animation|align-self|align-items|align-content)\\b",
            i: "[^\\s]"
        }, {
            b: "\\b(whitespace|wait|w-resize|visible|vertical-text|vertical-ideographic|uppercase|upper-roman|upper-alpha|underline|transparent|top|thin|thick|text|text-top|text-bottom|tb-rl|table-header-group|table-footer-group|sw-resize|super|strict|static|square|solid|small-caps|separate|se-resize|scroll|s-resize|rtl|row-resize|ridge|right|repeat|repeat-y|repeat-x|relative|progress|pointer|overline|outside|outset|oblique|nowrap|not-allowed|normal|none|nw-resize|no-repeat|no-drop|newspaper|ne-resize|n-resize|move|middle|medium|ltr|lr-tb|lowercase|lower-roman|lower-alpha|loose|list-item|line|line-through|line-edge|lighter|left|keep-all|justify|italic|inter-word|inter-ideograph|inside|inset|inline|inline-block|inherit|inactive|ideograph-space|ideograph-parenthesis|ideograph-numeric|ideograph-alpha|horizontal|hidden|help|hand|groove|fixed|ellipsis|e-resize|double|dotted|distribute|distribute-space|distribute-letter|distribute-all-lines|disc|disabled|default|decimal|dashed|crosshair|collapse|col-resize|circle|char|center|capitalize|break-word|break-all|bottom|both|bolder|bold|block|bidi-override|below|baseline|auto|always|all-scroll|absolute|table|table-cell)\\b"
        }, {
            b: ":",
            e: ";",
            c: [r, i, e.CSSNM, e.QSM, e.ASM, {
                cN: "meta",
                b: "!important"
            }]
        }, {
            b: "@(page|font-face)",
            l: t,
            k: "@page @font-face"
        }, {
            b: "@",
            e: "[{;]",
            rB: !0,
            k: "and or not only",
            c: [{
                b: t,
                cN: "keyword"
            }, r, e.QSM, e.ASM, i, e.CSSNM]
        }]
    }
});
hljs.registerLanguage("javascript", function (e) {
    var r = "<>",
        a = "</>",
        t = {
            b: /<[A-Za-z0-9\\._:-]+/,
            e: /\/[A-Za-z0-9\\._:-]+>|\/>/
        },
        c = "[A-Za-z$_][0-9A-Za-z$_]*",
        n = {
            keyword: "in of if for while finally var new function do return void else break catch instanceof with throw case default try this switch continue typeof delete let yield const export super debugger as async await static import from as",
            literal: "true false null undefined NaN Infinity",
            built_in: "eval isFinite isNaN parseFloat parseInt decodeURI decodeURIComponent encodeURI encodeURIComponent escape unescape Object Function Boolean Error EvalError InternalError RangeError ReferenceError StopIteration SyntaxError TypeError URIError Number Math Date String RegExp Array Float32Array Float64Array Int16Array Int32Array Int8Array Uint16Array Uint32Array Uint8Array Uint8ClampedArray ArrayBuffer DataView JSON Intl arguments require module console window document Symbol Set Map WeakSet WeakMap Proxy Reflect Promise"
        },
        s = {
            cN: "number",
            v: [{
                b: "\\b(0[bB][01]+)n?"
            }, {
                b: "\\b(0[oO][0-7]+)n?"
            }, {
                b: e.CNR + "n?"
            }],
            relevance: 0
        },
        o = {
            cN: "subst",
            b: "\\$\\{",
            e: "\\}",
            k: n,
            c: []
        },
        i = {
            b: "html`",
            e: "",
            starts: {
                e: "`",
                rE: !1,
                c: [e.BE, o],
                sL: "xml"
            }
        },
        b = {
            b: "css`",
            e: "",
            starts: {
                e: "`",
                rE: !1,
                c: [e.BE, o],
                sL: "css"
            }
        },
        l = {
            cN: "string",
            b: "`",
            e: "`",
            c: [e.BE, o]
        };
    o.c = [e.ASM, e.QSM, i, b, l, s, e.RM];
    var u = o.c.concat([e.CBCM, e.CLCM]);
    return {
        aliases: ["js", "jsx", "mjs", "cjs"],
        k: n,
        c: [{
            cN: "meta",
            relevance: 10,
            b: /^\s*['"]use (strict|asm)['"]/
        }, {
            cN: "meta",
            b: /^#!/,
            e: /$/
        }, e.ASM, e.QSM, i, b, l, e.CLCM, e.C("/\\*\\*", "\\*/", {
            relevance: 0,
            c: [{
                cN: "doctag",
                b: "@[A-Za-z]+",
                c: [{
                    cN: "type",
                    b: "\\{",
                    e: "\\}",
                    relevance: 0
                }, {
                    cN: "variable",
                    b: c + "(?=\\s*(-)|$)",
                    endsParent: !0,
                    relevance: 0
                }, {
                    b: /(?=[^\n])\s/,
                    relevance: 0
                }]
            }]
        }), e.CBCM, s, {
            b: /[{,\n]\s*/,
            relevance: 0,
            c: [{
                b: c + "\\s*:",
                rB: !0,
                relevance: 0,
                c: [{
                    cN: "attr",
                    b: c,
                    relevance: 0
                }]
            }]
        }, {
            b: "(" + e.RSR + "|\\b(case|return|throw)\\b)\\s*",
            k: "return throw case",
            c: [e.CLCM, e.CBCM, e.RM, {
                cN: "function",
                b: "(\\(.*?\\)|" + c + ")\\s*=>",
                rB: !0,
                e: "\\s*=>",
                c: [{
                    cN: "params",
                    v: [{
                        b: c
                    }, {
                        b: /\(\s*\)/
                    }, {
                        b: /\(/,
                        e: /\)/,
                        eB: !0,
                        eE: !0,
                        k: n,
                        c: u
                    }]
                }]
            }, {
                cN: "",
                b: /\s/,
                e: /\s*/,
                skip: !0
            }, {
                v: [{
                    b: r,
                    e: a
                }, {
                    b: t.b,
                    e: t.e
                }],
                sL: "xml",
                c: [{
                    b: t.b,
                    e: t.e,
                    skip: !0,
                    c: ["self"]
                }]
            }],
            relevance: 0
        }, {
            cN: "function",
            bK: "function",
            e: /\{/,
            eE: !0,
            c: [e.inherit(e.TM, {
                b: c
            }), {
                cN: "params",
                b: /\(/,
                e: /\)/,
                eB: !0,
                eE: !0,
                c: u
            }],
            i: /\[|%/
        }, {
            b: /\$[(.]/
        }, e.METHOD_GUARD, {
            cN: "class",
            bK: "class",
            e: /[{;=]/,
            eE: !0,
            i: /[:"\[\]]/,
            c: [{
                bK: "extends"
            }, e.UTM]
        }, {
            bK: "constructor get set",
            e: /\{/,
            eE: !0
        }],
        i: /#(?!!)/
    }
});
hljs.registerLanguage("x86asm", function (s) {
    return {
        cI: !0,
        l: "[.%]?" + s.IR,
        k: {
            keyword: "lock rep repe repz repne repnz xaquire xrelease bnd nobnd aaa aad aam aas adc add and arpl bb0_reset bb1_reset bound bsf bsr bswap bt btc btr bts call cbw cdq cdqe clc cld cli clts cmc cmp cmpsb cmpsd cmpsq cmpsw cmpxchg cmpxchg486 cmpxchg8b cmpxchg16b cpuid cpu_read cpu_write cqo cwd cwde daa das dec div dmint emms enter equ f2xm1 fabs fadd faddp fbld fbstp fchs fclex fcmovb fcmovbe fcmove fcmovnb fcmovnbe fcmovne fcmovnu fcmovu fcom fcomi fcomip fcomp fcompp fcos fdecstp fdisi fdiv fdivp fdivr fdivrp femms feni ffree ffreep fiadd ficom ficomp fidiv fidivr fild fimul fincstp finit fist fistp fisttp fisub fisubr fld fld1 fldcw fldenv fldl2e fldl2t fldlg2 fldln2 fldpi fldz fmul fmulp fnclex fndisi fneni fninit fnop fnsave fnstcw fnstenv fnstsw fpatan fprem fprem1 fptan frndint frstor fsave fscale fsetpm fsin fsincos fsqrt fst fstcw fstenv fstp fstsw fsub fsubp fsubr fsubrp ftst fucom fucomi fucomip fucomp fucompp fxam fxch fxtract fyl2x fyl2xp1 hlt ibts icebp idiv imul in inc incbin insb insd insw int int01 int1 int03 int3 into invd invpcid invlpg invlpga iret iretd iretq iretw jcxz jecxz jrcxz jmp jmpe lahf lar lds lea leave les lfence lfs lgdt lgs lidt lldt lmsw loadall loadall286 lodsb lodsd lodsq lodsw loop loope loopne loopnz loopz lsl lss ltr mfence monitor mov movd movq movsb movsd movsq movsw movsx movsxd movzx mul mwait neg nop not or out outsb outsd outsw packssdw packsswb packuswb paddb paddd paddsb paddsiw paddsw paddusb paddusw paddw pand pandn pause paveb pavgusb pcmpeqb pcmpeqd pcmpeqw pcmpgtb pcmpgtd pcmpgtw pdistib pf2id pfacc pfadd pfcmpeq pfcmpge pfcmpgt pfmax pfmin pfmul pfrcp pfrcpit1 pfrcpit2 pfrsqit1 pfrsqrt pfsub pfsubr pi2fd pmachriw pmaddwd pmagw pmulhriw pmulhrwa pmulhrwc pmulhw pmullw pmvgezb pmvlzb pmvnzb pmvzb pop popa popad popaw popf popfd popfq popfw por prefetch prefetchw pslld psllq psllw psrad psraw psrld psrlq psrlw psubb psubd psubsb psubsiw psubsw psubusb psubusw psubw punpckhbw punpckhdq punpckhwd punpcklbw punpckldq punpcklwd push pusha pushad pushaw pushf pushfd pushfq pushfw pxor rcl rcr rdshr rdmsr rdpmc rdtsc rdtscp ret retf retn rol ror rdm rsdc rsldt rsm rsts sahf sal salc sar sbb scasb scasd scasq scasw sfence sgdt shl shld shr shrd sidt sldt skinit smi smint smintold smsw stc std sti stosb stosd stosq stosw str sub svdc svldt svts swapgs syscall sysenter sysexit sysret test ud0 ud1 ud2b ud2 ud2a umov verr verw fwait wbinvd wrshr wrmsr xadd xbts xchg xlatb xlat xor cmove cmovz cmovne cmovnz cmova cmovnbe cmovae cmovnb cmovb cmovnae cmovbe cmovna cmovg cmovnle cmovge cmovnl cmovl cmovnge cmovle cmovng cmovc cmovnc cmovo cmovno cmovs cmovns cmovp cmovpe cmovnp cmovpo je jz jne jnz ja jnbe jae jnb jb jnae jbe jna jg jnle jge jnl jl jnge jle jng jc jnc jo jno js jns jpo jnp jpe jp sete setz setne setnz seta setnbe setae setnb setnc setb setnae setcset setbe setna setg setnle setge setnl setl setnge setle setng sets setns seto setno setpe setp setpo setnp addps addss andnps andps cmpeqps cmpeqss cmpleps cmpless cmpltps cmpltss cmpneqps cmpneqss cmpnleps cmpnless cmpnltps cmpnltss cmpordps cmpordss cmpunordps cmpunordss cmpps cmpss comiss cvtpi2ps cvtps2pi cvtsi2ss cvtss2si cvttps2pi cvttss2si divps divss ldmxcsr maxps maxss minps minss movaps movhps movlhps movlps movhlps movmskps movntps movss movups mulps mulss orps rcpps rcpss rsqrtps rsqrtss shufps sqrtps sqrtss stmxcsr subps subss ucomiss unpckhps unpcklps xorps fxrstor fxrstor64 fxsave fxsave64 xgetbv xsetbv xsave xsave64 xsaveopt xsaveopt64 xrstor xrstor64 prefetchnta prefetcht0 prefetcht1 prefetcht2 maskmovq movntq pavgb pavgw pextrw pinsrw pmaxsw pmaxub pminsw pminub pmovmskb pmulhuw psadbw pshufw pf2iw pfnacc pfpnacc pi2fw pswapd maskmovdqu clflush movntdq movnti movntpd movdqa movdqu movdq2q movq2dq paddq pmuludq pshufd pshufhw pshuflw pslldq psrldq psubq punpckhqdq punpcklqdq addpd addsd andnpd andpd cmpeqpd cmpeqsd cmplepd cmplesd cmpltpd cmpltsd cmpneqpd cmpneqsd cmpnlepd cmpnlesd cmpnltpd cmpnltsd cmpordpd cmpordsd cmpunordpd cmpunordsd cmppd comisd cvtdq2pd cvtdq2ps cvtpd2dq cvtpd2pi cvtpd2ps cvtpi2pd cvtps2dq cvtps2pd cvtsd2si cvtsd2ss cvtsi2sd cvtss2sd cvttpd2pi cvttpd2dq cvttps2dq cvttsd2si divpd divsd maxpd maxsd minpd minsd movapd movhpd movlpd movmskpd movupd mulpd mulsd orpd shufpd sqrtpd sqrtsd subpd subsd ucomisd unpckhpd unpcklpd xorpd addsubpd addsubps haddpd haddps hsubpd hsubps lddqu movddup movshdup movsldup clgi stgi vmcall vmclear vmfunc vmlaunch vmload vmmcall vmptrld vmptrst vmread vmresume vmrun vmsave vmwrite vmxoff vmxon invept invvpid pabsb pabsw pabsd palignr phaddw phaddd phaddsw phsubw phsubd phsubsw pmaddubsw pmulhrsw pshufb psignb psignw psignd extrq insertq movntsd movntss lzcnt blendpd blendps blendvpd blendvps dppd dpps extractps insertps movntdqa mpsadbw packusdw pblendvb pblendw pcmpeqq pextrb pextrd pextrq phminposuw pinsrb pinsrd pinsrq pmaxsb pmaxsd pmaxud pmaxuw pminsb pminsd pminud pminuw pmovsxbw pmovsxbd pmovsxbq pmovsxwd pmovsxwq pmovsxdq pmovzxbw pmovzxbd pmovzxbq pmovzxwd pmovzxwq pmovzxdq pmuldq pmulld ptest roundpd roundps roundsd roundss crc32 pcmpestri pcmpestrm pcmpistri pcmpistrm pcmpgtq popcnt getsec pfrcpv pfrsqrtv movbe aesenc aesenclast aesdec aesdeclast aesimc aeskeygenassist vaesenc vaesenclast vaesdec vaesdeclast vaesimc vaeskeygenassist vaddpd vaddps vaddsd vaddss vaddsubpd vaddsubps vandpd vandps vandnpd vandnps vblendpd vblendps vblendvpd vblendvps vbroadcastss vbroadcastsd vbroadcastf128 vcmpeq_ospd vcmpeqpd vcmplt_ospd vcmpltpd vcmple_ospd vcmplepd vcmpunord_qpd vcmpunordpd vcmpneq_uqpd vcmpneqpd vcmpnlt_uspd vcmpnltpd vcmpnle_uspd vcmpnlepd vcmpord_qpd vcmpordpd vcmpeq_uqpd vcmpnge_uspd vcmpngepd vcmpngt_uspd vcmpngtpd vcmpfalse_oqpd vcmpfalsepd vcmpneq_oqpd vcmpge_ospd vcmpgepd vcmpgt_ospd vcmpgtpd vcmptrue_uqpd vcmptruepd vcmplt_oqpd vcmple_oqpd vcmpunord_spd vcmpneq_uspd vcmpnlt_uqpd vcmpnle_uqpd vcmpord_spd vcmpeq_uspd vcmpnge_uqpd vcmpngt_uqpd vcmpfalse_ospd vcmpneq_ospd vcmpge_oqpd vcmpgt_oqpd vcmptrue_uspd vcmppd vcmpeq_osps vcmpeqps vcmplt_osps vcmpltps vcmple_osps vcmpleps vcmpunord_qps vcmpunordps vcmpneq_uqps vcmpneqps vcmpnlt_usps vcmpnltps vcmpnle_usps vcmpnleps vcmpord_qps vcmpordps vcmpeq_uqps vcmpnge_usps vcmpngeps vcmpngt_usps vcmpngtps vcmpfalse_oqps vcmpfalseps vcmpneq_oqps vcmpge_osps vcmpgeps vcmpgt_osps vcmpgtps vcmptrue_uqps vcmptrueps vcmplt_oqps vcmple_oqps vcmpunord_sps vcmpneq_usps vcmpnlt_uqps vcmpnle_uqps vcmpord_sps vcmpeq_usps vcmpnge_uqps vcmpngt_uqps vcmpfalse_osps vcmpneq_osps vcmpge_oqps vcmpgt_oqps vcmptrue_usps vcmpps vcmpeq_ossd vcmpeqsd vcmplt_ossd vcmpltsd vcmple_ossd vcmplesd vcmpunord_qsd vcmpunordsd vcmpneq_uqsd vcmpneqsd vcmpnlt_ussd vcmpnltsd vcmpnle_ussd vcmpnlesd vcmpord_qsd vcmpordsd vcmpeq_uqsd vcmpnge_ussd vcmpngesd vcmpngt_ussd vcmpngtsd vcmpfalse_oqsd vcmpfalsesd vcmpneq_oqsd vcmpge_ossd vcmpgesd vcmpgt_ossd vcmpgtsd vcmptrue_uqsd vcmptruesd vcmplt_oqsd vcmple_oqsd vcmpunord_ssd vcmpneq_ussd vcmpnlt_uqsd vcmpnle_uqsd vcmpord_ssd vcmpeq_ussd vcmpnge_uqsd vcmpngt_uqsd vcmpfalse_ossd vcmpneq_ossd vcmpge_oqsd vcmpgt_oqsd vcmptrue_ussd vcmpsd vcmpeq_osss vcmpeqss vcmplt_osss vcmpltss vcmple_osss vcmpless vcmpunord_qss vcmpunordss vcmpneq_uqss vcmpneqss vcmpnlt_usss vcmpnltss vcmpnle_usss vcmpnless vcmpord_qss vcmpordss vcmpeq_uqss vcmpnge_usss vcmpngess vcmpngt_usss vcmpngtss vcmpfalse_oqss vcmpfalsess vcmpneq_oqss vcmpge_osss vcmpgess vcmpgt_osss vcmpgtss vcmptrue_uqss vcmptruess vcmplt_oqss vcmple_oqss vcmpunord_sss vcmpneq_usss vcmpnlt_uqss vcmpnle_uqss vcmpord_sss vcmpeq_usss vcmpnge_uqss vcmpngt_uqss vcmpfalse_osss vcmpneq_osss vcmpge_oqss vcmpgt_oqss vcmptrue_usss vcmpss vcomisd vcomiss vcvtdq2pd vcvtdq2ps vcvtpd2dq vcvtpd2ps vcvtps2dq vcvtps2pd vcvtsd2si vcvtsd2ss vcvtsi2sd vcvtsi2ss vcvtss2sd vcvtss2si vcvttpd2dq vcvttps2dq vcvttsd2si vcvttss2si vdivpd vdivps vdivsd vdivss vdppd vdpps vextractf128 vextractps vhaddpd vhaddps vhsubpd vhsubps vinsertf128 vinsertps vlddqu vldqqu vldmxcsr vmaskmovdqu vmaskmovps vmaskmovpd vmaxpd vmaxps vmaxsd vmaxss vminpd vminps vminsd vminss vmovapd vmovaps vmovd vmovq vmovddup vmovdqa vmovqqa vmovdqu vmovqqu vmovhlps vmovhpd vmovhps vmovlhps vmovlpd vmovlps vmovmskpd vmovmskps vmovntdq vmovntqq vmovntdqa vmovntpd vmovntps vmovsd vmovshdup vmovsldup vmovss vmovupd vmovups vmpsadbw vmulpd vmulps vmulsd vmulss vorpd vorps vpabsb vpabsw vpabsd vpacksswb vpackssdw vpackuswb vpackusdw vpaddb vpaddw vpaddd vpaddq vpaddsb vpaddsw vpaddusb vpaddusw vpalignr vpand vpandn vpavgb vpavgw vpblendvb vpblendw vpcmpestri vpcmpestrm vpcmpistri vpcmpistrm vpcmpeqb vpcmpeqw vpcmpeqd vpcmpeqq vpcmpgtb vpcmpgtw vpcmpgtd vpcmpgtq vpermilpd vpermilps vperm2f128 vpextrb vpextrw vpextrd vpextrq vphaddw vphaddd vphaddsw vphminposuw vphsubw vphsubd vphsubsw vpinsrb vpinsrw vpinsrd vpinsrq vpmaddwd vpmaddubsw vpmaxsb vpmaxsw vpmaxsd vpmaxub vpmaxuw vpmaxud vpminsb vpminsw vpminsd vpminub vpminuw vpminud vpmovmskb vpmovsxbw vpmovsxbd vpmovsxbq vpmovsxwd vpmovsxwq vpmovsxdq vpmovzxbw vpmovzxbd vpmovzxbq vpmovzxwd vpmovzxwq vpmovzxdq vpmulhuw vpmulhrsw vpmulhw vpmullw vpmulld vpmuludq vpmuldq vpor vpsadbw vpshufb vpshufd vpshufhw vpshuflw vpsignb vpsignw vpsignd vpslldq vpsrldq vpsllw vpslld vpsllq vpsraw vpsrad vpsrlw vpsrld vpsrlq vptest vpsubb vpsubw vpsubd vpsubq vpsubsb vpsubsw vpsubusb vpsubusw vpunpckhbw vpunpckhwd vpunpckhdq vpunpckhqdq vpunpcklbw vpunpcklwd vpunpckldq vpunpcklqdq vpxor vrcpps vrcpss vrsqrtps vrsqrtss vroundpd vroundps vroundsd vroundss vshufpd vshufps vsqrtpd vsqrtps vsqrtsd vsqrtss vstmxcsr vsubpd vsubps vsubsd vsubss vtestps vtestpd vucomisd vucomiss vunpckhpd vunpckhps vunpcklpd vunpcklps vxorpd vxorps vzeroall vzeroupper pclmullqlqdq pclmulhqlqdq pclmullqhqdq pclmulhqhqdq pclmulqdq vpclmullqlqdq vpclmulhqlqdq vpclmullqhqdq vpclmulhqhqdq vpclmulqdq vfmadd132ps vfmadd132pd vfmadd312ps vfmadd312pd vfmadd213ps vfmadd213pd vfmadd123ps vfmadd123pd vfmadd231ps vfmadd231pd vfmadd321ps vfmadd321pd vfmaddsub132ps vfmaddsub132pd vfmaddsub312ps vfmaddsub312pd vfmaddsub213ps vfmaddsub213pd vfmaddsub123ps vfmaddsub123pd vfmaddsub231ps vfmaddsub231pd vfmaddsub321ps vfmaddsub321pd vfmsub132ps vfmsub132pd vfmsub312ps vfmsub312pd vfmsub213ps vfmsub213pd vfmsub123ps vfmsub123pd vfmsub231ps vfmsub231pd vfmsub321ps vfmsub321pd vfmsubadd132ps vfmsubadd132pd vfmsubadd312ps vfmsubadd312pd vfmsubadd213ps vfmsubadd213pd vfmsubadd123ps vfmsubadd123pd vfmsubadd231ps vfmsubadd231pd vfmsubadd321ps vfmsubadd321pd vfnmadd132ps vfnmadd132pd vfnmadd312ps vfnmadd312pd vfnmadd213ps vfnmadd213pd vfnmadd123ps vfnmadd123pd vfnmadd231ps vfnmadd231pd vfnmadd321ps vfnmadd321pd vfnmsub132ps vfnmsub132pd vfnmsub312ps vfnmsub312pd vfnmsub213ps vfnmsub213pd vfnmsub123ps vfnmsub123pd vfnmsub231ps vfnmsub231pd vfnmsub321ps vfnmsub321pd vfmadd132ss vfmadd132sd vfmadd312ss vfmadd312sd vfmadd213ss vfmadd213sd vfmadd123ss vfmadd123sd vfmadd231ss vfmadd231sd vfmadd321ss vfmadd321sd vfmsub132ss vfmsub132sd vfmsub312ss vfmsub312sd vfmsub213ss vfmsub213sd vfmsub123ss vfmsub123sd vfmsub231ss vfmsub231sd vfmsub321ss vfmsub321sd vfnmadd132ss vfnmadd132sd vfnmadd312ss vfnmadd312sd vfnmadd213ss vfnmadd213sd vfnmadd123ss vfnmadd123sd vfnmadd231ss vfnmadd231sd vfnmadd321ss vfnmadd321sd vfnmsub132ss vfnmsub132sd vfnmsub312ss vfnmsub312sd vfnmsub213ss vfnmsub213sd vfnmsub123ss vfnmsub123sd vfnmsub231ss vfnmsub231sd vfnmsub321ss vfnmsub321sd rdfsbase rdgsbase rdrand wrfsbase wrgsbase vcvtph2ps vcvtps2ph adcx adox rdseed clac stac xstore xcryptecb xcryptcbc xcryptctr xcryptcfb xcryptofb montmul xsha1 xsha256 llwpcb slwpcb lwpval lwpins vfmaddpd vfmaddps vfmaddsd vfmaddss vfmaddsubpd vfmaddsubps vfmsubaddpd vfmsubaddps vfmsubpd vfmsubps vfmsubsd vfmsubss vfnmaddpd vfnmaddps vfnmaddsd vfnmaddss vfnmsubpd vfnmsubps vfnmsubsd vfnmsubss vfrczpd vfrczps vfrczsd vfrczss vpcmov vpcomb vpcomd vpcomq vpcomub vpcomud vpcomuq vpcomuw vpcomw vphaddbd vphaddbq vphaddbw vphadddq vphaddubd vphaddubq vphaddubw vphaddudq vphadduwd vphadduwq vphaddwd vphaddwq vphsubbw vphsubdq vphsubwd vpmacsdd vpmacsdqh vpmacsdql vpmacssdd vpmacssdqh vpmacssdql vpmacsswd vpmacssww vpmacswd vpmacsww vpmadcsswd vpmadcswd vpperm vprotb vprotd vprotq vprotw vpshab vpshad vpshaq vpshaw vpshlb vpshld vpshlq vpshlw vbroadcasti128 vpblendd vpbroadcastb vpbroadcastw vpbroadcastd vpbroadcastq vpermd vpermpd vpermps vpermq vperm2i128 vextracti128 vinserti128 vpmaskmovd vpmaskmovq vpsllvd vpsllvq vpsravd vpsrlvd vpsrlvq vgatherdpd vgatherqpd vgatherdps vgatherqps vpgatherdd vpgatherqd vpgatherdq vpgatherqq xabort xbegin xend xtest andn bextr blci blcic blsi blsic blcfill blsfill blcmsk blsmsk blsr blcs bzhi mulx pdep pext rorx sarx shlx shrx tzcnt tzmsk t1mskc valignd valignq vblendmpd vblendmps vbroadcastf32x4 vbroadcastf64x4 vbroadcasti32x4 vbroadcasti64x4 vcompresspd vcompressps vcvtpd2udq vcvtps2udq vcvtsd2usi vcvtss2usi vcvttpd2udq vcvttps2udq vcvttsd2usi vcvttss2usi vcvtudq2pd vcvtudq2ps vcvtusi2sd vcvtusi2ss vexpandpd vexpandps vextractf32x4 vextractf64x4 vextracti32x4 vextracti64x4 vfixupimmpd vfixupimmps vfixupimmsd vfixupimmss vgetexppd vgetexpps vgetexpsd vgetexpss vgetmantpd vgetmantps vgetmantsd vgetmantss vinsertf32x4 vinsertf64x4 vinserti32x4 vinserti64x4 vmovdqa32 vmovdqa64 vmovdqu32 vmovdqu64 vpabsq vpandd vpandnd vpandnq vpandq vpblendmd vpblendmq vpcmpltd vpcmpled vpcmpneqd vpcmpnltd vpcmpnled vpcmpd vpcmpltq vpcmpleq vpcmpneqq vpcmpnltq vpcmpnleq vpcmpq vpcmpequd vpcmpltud vpcmpleud vpcmpnequd vpcmpnltud vpcmpnleud vpcmpud vpcmpequq vpcmpltuq vpcmpleuq vpcmpnequq vpcmpnltuq vpcmpnleuq vpcmpuq vpcompressd vpcompressq vpermi2d vpermi2pd vpermi2ps vpermi2q vpermt2d vpermt2pd vpermt2ps vpermt2q vpexpandd vpexpandq vpmaxsq vpmaxuq vpminsq vpminuq vpmovdb vpmovdw vpmovqb vpmovqd vpmovqw vpmovsdb vpmovsdw vpmovsqb vpmovsqd vpmovsqw vpmovusdb vpmovusdw vpmovusqb vpmovusqd vpmovusqw vpord vporq vprold vprolq vprolvd vprolvq vprord vprorq vprorvd vprorvq vpscatterdd vpscatterdq vpscatterqd vpscatterqq vpsraq vpsravq vpternlogd vpternlogq vptestmd vptestmq vptestnmd vptestnmq vpxord vpxorq vrcp14pd vrcp14ps vrcp14sd vrcp14ss vrndscalepd vrndscaleps vrndscalesd vrndscaless vrsqrt14pd vrsqrt14ps vrsqrt14sd vrsqrt14ss vscalefpd vscalefps vscalefsd vscalefss vscatterdpd vscatterdps vscatterqpd vscatterqps vshuff32x4 vshuff64x2 vshufi32x4 vshufi64x2 kandnw kandw kmovw knotw kortestw korw kshiftlw kshiftrw kunpckbw kxnorw kxorw vpbroadcastmb2q vpbroadcastmw2d vpconflictd vpconflictq vplzcntd vplzcntq vexp2pd vexp2ps vrcp28pd vrcp28ps vrcp28sd vrcp28ss vrsqrt28pd vrsqrt28ps vrsqrt28sd vrsqrt28ss vgatherpf0dpd vgatherpf0dps vgatherpf0qpd vgatherpf0qps vgatherpf1dpd vgatherpf1dps vgatherpf1qpd vgatherpf1qps vscatterpf0dpd vscatterpf0dps vscatterpf0qpd vscatterpf0qps vscatterpf1dpd vscatterpf1dps vscatterpf1qpd vscatterpf1qps prefetchwt1 bndmk bndcl bndcu bndcn bndmov bndldx bndstx sha1rnds4 sha1nexte sha1msg1 sha1msg2 sha256rnds2 sha256msg1 sha256msg2 hint_nop0 hint_nop1 hint_nop2 hint_nop3 hint_nop4 hint_nop5 hint_nop6 hint_nop7 hint_nop8 hint_nop9 hint_nop10 hint_nop11 hint_nop12 hint_nop13 hint_nop14 hint_nop15 hint_nop16 hint_nop17 hint_nop18 hint_nop19 hint_nop20 hint_nop21 hint_nop22 hint_nop23 hint_nop24 hint_nop25 hint_nop26 hint_nop27 hint_nop28 hint_nop29 hint_nop30 hint_nop31 hint_nop32 hint_nop33 hint_nop34 hint_nop35 hint_nop36 hint_nop37 hint_nop38 hint_nop39 hint_nop40 hint_nop41 hint_nop42 hint_nop43 hint_nop44 hint_nop45 hint_nop46 hint_nop47 hint_nop48 hint_nop49 hint_nop50 hint_nop51 hint_nop52 hint_nop53 hint_nop54 hint_nop55 hint_nop56 hint_nop57 hint_nop58 hint_nop59 hint_nop60 hint_nop61 hint_nop62 hint_nop63",
            built_in: "ip eip rip al ah bl bh cl ch dl dh sil dil bpl spl r8b r9b r10b r11b r12b r13b r14b r15b ax bx cx dx si di bp sp r8w r9w r10w r11w r12w r13w r14w r15w eax ebx ecx edx esi edi ebp esp eip r8d r9d r10d r11d r12d r13d r14d r15d rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 cs ds es fs gs ss st st0 st1 st2 st3 st4 st5 st6 st7 mm0 mm1 mm2 mm3 mm4 mm5 mm6 mm7 xmm0  xmm1  xmm2  xmm3  xmm4  xmm5  xmm6  xmm7  xmm8  xmm9 xmm10  xmm11 xmm12 xmm13 xmm14 xmm15 xmm16 xmm17 xmm18 xmm19 xmm20 xmm21 xmm22 xmm23 xmm24 xmm25 xmm26 xmm27 xmm28 xmm29 xmm30 xmm31 ymm0  ymm1  ymm2  ymm3  ymm4  ymm5  ymm6  ymm7  ymm8  ymm9 ymm10  ymm11 ymm12 ymm13 ymm14 ymm15 ymm16 ymm17 ymm18 ymm19 ymm20 ymm21 ymm22 ymm23 ymm24 ymm25 ymm26 ymm27 ymm28 ymm29 ymm30 ymm31 zmm0  zmm1  zmm2  zmm3  zmm4  zmm5  zmm6  zmm7  zmm8  zmm9 zmm10  zmm11 zmm12 zmm13 zmm14 zmm15 zmm16 zmm17 zmm18 zmm19 zmm20 zmm21 zmm22 zmm23 zmm24 zmm25 zmm26 zmm27 zmm28 zmm29 zmm30 zmm31 k0 k1 k2 k3 k4 k5 k6 k7 bnd0 bnd1 bnd2 bnd3 cr0 cr1 cr2 cr3 cr4 cr8 dr0 dr1 dr2 dr3 dr8 tr3 tr4 tr5 tr6 tr7 r0 r1 r2 r3 r4 r5 r6 r7 r0b r1b r2b r3b r4b r5b r6b r7b r0w r1w r2w r3w r4w r5w r6w r7w r0d r1d r2d r3d r4d r5d r6d r7d r0h r1h r2h r3h r0l r1l r2l r3l r4l r5l r6l r7l r8l r9l r10l r11l r12l r13l r14l r15l db dw dd dq dt ddq do dy dz resb resw resd resq rest resdq reso resy resz incbin equ times byte word dword qword nosplit rel abs seg wrt strict near far a32 ptr",
            meta: "%define %xdefine %+ %undef %defstr %deftok %assign %strcat %strlen %substr %rotate %elif %else %endif %if %ifmacro %ifctx %ifidn %ifidni %ifid %ifnum %ifstr %iftoken %ifempty %ifenv %error %warning %fatal %rep %endrep %include %push %pop %repl %pathsearch %depend %use %arg %stacksize %local %line %comment %endcomment .nolist __FILE__ __LINE__ __SECT__  __BITS__ __OUTPUT_FORMAT__ __DATE__ __TIME__ __DATE_NUM__ __TIME_NUM__ __UTC_DATE__ __UTC_TIME__ __UTC_DATE_NUM__ __UTC_TIME_NUM__  __PASS__ struc endstruc istruc at iend align alignb sectalign daz nodaz up down zero default option assume public bits use16 use32 use64 default section segment absolute extern global common cpu float __utf16__ __utf16le__ __utf16be__ __utf32__ __utf32le__ __utf32be__ __float8__ __float16__ __float32__ __float64__ __float80m__ __float80e__ __float128l__ __float128h__ __Infinity__ __QNaN__ __SNaN__ Inf NaN QNaN SNaN float8 float16 float32 float64 float80m float80e float128l float128h __FLOAT_DAZ__ __FLOAT_ROUND__ __FLOAT__"
        },
        c: [s.C(";", "$", {
            relevance: 0
        }), {
            cN: "number",
            v: [{
                b: "\\b(?:([0-9][0-9_]*)?\\.[0-9_]*(?:[eE][+-]?[0-9_]+)?|(0[Xx])?[0-9][0-9_]*\\.?[0-9_]*(?:[pP](?:[+-]?[0-9_]+)?)?)\\b",
                relevance: 0
            }, {
                b: "\\$[0-9][0-9A-Fa-f]*",
                relevance: 0
            }, {
                b: "\\b(?:[0-9A-Fa-f][0-9A-Fa-f_]*[Hh]|[0-9][0-9_]*[DdTt]?|[0-7][0-7_]*[QqOo]|[0-1][0-1_]*[BbYy])\\b"
            }, {
                b: "\\b(?:0[Xx][0-9A-Fa-f_]+|0[DdTt][0-9_]+|0[QqOo][0-7_]+|0[BbYy][0-1_]+)\\b"
            }]
        }, s.QSM, {
            cN: "string",
            v: [{
                b: "'",
                e: "[^\\\\]'"
            }, {
                b: "`",
                e: "[^\\\\]`"
            }],
            relevance: 0
        }, {
            cN: "symbol",
            v: [{
                b: "^\\s*[A-Za-z._?][A-Za-z0-9_$#@~.?]*(:|\\s+label)"
            }, {
                b: "^\\s*%%[A-Za-z0-9_$#@~.?]*:"
            }],
            relevance: 0
        }, {
            cN: "subst",
            b: "%[0-9]+",
            relevance: 0
        }, {
            cN: "subst",
            b: "%!S+",
            relevance: 0
        }, {
            cN: "meta",
            b: /^\s*\.[\w_-]+/
        }]
    }
});
hljs.registerLanguage("cpp", function (e) {
    function t(e) {
        return "(?:" + e + ")?"
    }
    var r = "decltype\\(auto\\)",
        a = "[a-zA-Z_]\\w*::",
        i = "(" + r + "|" + t(a) + "[a-zA-Z_]\\w*" + t("<.*?>") + ")",
        c = {
            cN: "keyword",
            b: "\\b[a-z\\d_]*_t\\b"
        },
        s = {
            cN: "string",
            v: [{
                b: '(u8?|U|L)?"',
                e: '"',
                i: "\\n",
                c: [e.BE]
            }, {
                b: "(u8?|U|L)?'(\\\\(x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4,8}|[0-7]{3}|\\S)|.)",
                e: "'",
                i: "."
            }, {
                b: /(?:u8?|U|L)?R"([^()\\ ]{0,16})\((?:.|\n)*?\)\1"/
            }]
        },
        n = {
            cN: "number",
            v: [{
                b: "\\b(0b[01']+)"
            }, {
                b: "(-?)\\b([\\d']+(\\.[\\d']*)?|\\.[\\d']+)(u|U|l|L|ul|UL|f|F|b|B)"
            }, {
                b: "(-?)(\\b0[xX][a-fA-F0-9']+|(\\b[\\d']+(\\.[\\d']*)?|\\.[\\d']+)([eE][-+]?[\\d']+)?)"
            }],
            relevance: 0
        },
        o = {
            cN: "meta",
            b: /#\s*[a-z]+\b/,
            e: /$/,
            k: {
                "meta-keyword": "if else elif endif define undef warning error line pragma _Pragma ifdef ifndef include"
            },
            c: [{
                b: /\\\n/,
                relevance: 0
            }, e.inherit(s, {
                cN: "meta-string"
            }), {
                cN: "meta-string",
                b: /<.*?>/,
                e: /$/,
                i: "\\n"
            }, e.CLCM, e.CBCM]
        },
        l = {
            cN: "title",
            b: t(a) + e.IR,
            relevance: 0
        },
        u = t(a) + e.IR + "\\s*\\(",
        p = {
            keyword: "int float while private char char8_t char16_t char32_t catch import module export virtual operator sizeof dynamic_cast|10 typedef const_cast|10 const for static_cast|10 union namespace unsigned long volatile static protected bool template mutable if public friend do goto auto void enum else break extern using asm case typeid wchar_tshort reinterpret_cast|10 default double register explicit signed typename try this switch continue inline delete alignas alignof constexpr consteval constinit decltype concept co_await co_return co_yield requires noexcept static_assert thread_local restrict final override atomic_bool atomic_char atomic_schar atomic_uchar atomic_short atomic_ushort atomic_int atomic_uint atomic_long atomic_ulong atomic_llong atomic_ullong new throw return and and_eq bitand bitor compl not not_eq or or_eq xor xor_eq",
            built_in: "std string wstring cin cout cerr clog stdin stdout stderr stringstream istringstream ostringstream auto_ptr deque list queue stack vector map set bitset multiset multimap unordered_set unordered_map unordered_multiset unordered_multimap array shared_ptr abort terminate abs acos asin atan2 atan calloc ceil cosh cos exit exp fabs floor fmod fprintf fputs free frexp fscanf future isalnum isalpha iscntrl isdigit isgraph islower isprint ispunct isspace isupper isxdigit tolower toupper labs ldexp log10 log malloc realloc memchr memcmp memcpy memset modf pow printf putchar puts scanf sinh sin snprintf sprintf sqrt sscanf strcat strchr strcmp strcpy strcspn strlen strncat strncmp strncpy strpbrk strrchr strspn strstr tanh tan vfprintf vprintf vsprintf endl initializer_list unique_ptr _Bool complex _Complex imaginary _Imaginary",
            literal: "true false nullptr NULL"
        },
        m = [c, e.CLCM, e.CBCM, n, s],
        d = {
            v: [{
                b: /=/,
                e: /;/
            }, {
                b: /\(/,
                e: /\)/
            }, {
                bK: "new throw return else",
                e: /;/
            }],
            k: p,
            c: m.concat([{
                b: /\(/,
                e: /\)/,
                k: p,
                c: m.concat(["self"]),
                relevance: 0
            }]),
            relevance: 0
        },
        b = {
            cN: "function",
            b: "(" + i + "[\\*&\\s]+)+" + u,
            rB: !0,
            e: /[{;=]/,
            eE: !0,
            k: p,
            i: /[^\w\s\*&:<>]/,
            c: [{
                b: r,
                k: p,
                relevance: 0
            }, {
                b: u,
                rB: !0,
                c: [l],
                relevance: 0
            }, {
                cN: "params",
                b: /\(/,
                e: /\)/,
                k: p,
                relevance: 0,
                c: [e.CLCM, e.CBCM, s, n, c, {
                    b: /\(/,
                    e: /\)/,
                    k: p,
                    relevance: 0,
                    c: ["self", e.CLCM, e.CBCM, s, n, c]
                }]
            }, c, e.CLCM, e.CBCM, o]
        };
    return {
        aliases: ["c", "cc", "h", "c++", "h++", "hpp", "hh", "hxx", "cxx"],
        k: p,
        i: "</",
        c: [].concat(d, b, m, [o, {
            b: "\\b(deque|list|queue|stack|vector|map|set|bitset|multiset|multimap|unordered_map|unordered_set|unordered_multiset|unordered_multimap|array)\\s*<",
            e: ">",
            k: p,
            c: ["self", c]
        }, {
            b: e.IR + "::",
            k: p
        }, {
            cN: "class",
            bK: "class struct",
            e: /[{;:]/,
            c: [{
                b: /</,
                e: />/,
                c: ["self"]
            }, e.TM]
        }]),
        exports: {
            preprocessor: o,
            strings: s,
            k: p
        }
    }
});
hljs.registerLanguage("arduino", function (e) {
    var t = "boolean byte word String",
        r = "setup loopKeyboardController MouseController SoftwareSerial EthernetServer EthernetClient LiquidCrystal RobotControl GSMVoiceCall EthernetUDP EsploraTFT HttpClient RobotMotor WiFiClient GSMScanner FileSystem Scheduler GSMServer YunClient YunServer IPAddress GSMClient GSMModem Keyboard Ethernet Console GSMBand Esplora Stepper Process WiFiUDP GSM_SMS Mailbox USBHost Firmata PImage Client Server GSMPIN FileIO Bridge Serial EEPROM Stream Mouse Audio Servo File Task GPRS WiFi Wire TFT GSM SPI SD runShellCommandAsynchronously analogWriteResolution retrieveCallingNumber printFirmwareVersion analogReadResolution sendDigitalPortPair noListenOnLocalhost readJoystickButton setFirmwareVersion readJoystickSwitch scrollDisplayRight getVoiceCallStatus scrollDisplayLeft writeMicroseconds delayMicroseconds beginTransmission getSignalStrength runAsynchronously getAsynchronously listenOnLocalhost getCurrentCarrier readAccelerometer messageAvailable sendDigitalPorts lineFollowConfig countryNameWrite runShellCommand readStringUntil rewindDirectory readTemperature setClockDivider readLightSensor endTransmission analogReference detachInterrupt countryNameRead attachInterrupt encryptionType readBytesUntil robotNameWrite readMicrophone robotNameRead cityNameWrite userNameWrite readJoystickY readJoystickX mouseReleased openNextFile scanNetworks noInterrupts digitalWrite beginSpeaker mousePressed isActionDone mouseDragged displayLogos noAutoscroll addParameter remoteNumber getModifiers keyboardRead userNameRead waitContinue processInput parseCommand printVersion readNetworks writeMessage blinkVersion cityNameRead readMessage setDataMode parsePacket isListening setBitOrder beginPacket isDirectory motorsWrite drawCompass digitalRead clearScreen serialEvent rightToLeft setTextSize leftToRight requestFrom keyReleased compassRead analogWrite interrupts WiFiServer disconnect playMelody parseFloat autoscroll getPINUsed setPINUsed setTimeout sendAnalog readSlider analogRead beginWrite createChar motorsStop keyPressed tempoWrite readButton subnetMask debugPrint macAddress writeGreen randomSeed attachGPRS readString sendString remotePort releaseAll mouseMoved background getXChange getYChange answerCall getResult voiceCall endPacket constrain getSocket writeJSON getButton available connected findUntil readBytes exitValue readGreen writeBlue startLoop IPAddress isPressed sendSysex pauseMode gatewayIP setCursor getOemKey tuneWrite noDisplay loadImage switchPIN onRequest onReceive changePIN playFile noBuffer parseInt overflow checkPIN knobRead beginTFT bitClear updateIR bitWrite position writeRGB highByte writeRed setSpeed readBlue noStroke remoteIP transfer shutdown hangCall beginSMS endWrite attached maintain noCursor checkReg checkPUK shiftOut isValid shiftIn pulseIn connect println localIP pinMode getIMEI display noBlink process getBand running beginSD drawBMP lowByte setBand release bitRead prepare pointTo readRed setMode noFill remove listen stroke detach attach noTone exists buffer height bitSet circle config cursor random IRread setDNS endSMS getKey micros millis begin print write ready flush width isPIN blink clear press mkdir rmdir close point yield image BSSID click delay read text move peek beep rect line open seek fill size turn stop home find step tone sqrt RSSI SSID end bit tan cos sin pow map abs max min get run put",
        i = "DIGITAL_MESSAGE FIRMATA_STRING ANALOG_MESSAGE REPORT_DIGITAL REPORT_ANALOG INPUT_PULLUP SET_PIN_MODE INTERNAL2V56 SYSTEM_RESET LED_BUILTIN INTERNAL1V1 SYSEX_START INTERNAL EXTERNAL DEFAULT OUTPUT INPUT HIGH LOW",
        o = e.requireLanguage("cpp").rawDefinition(),
        a = o.k;
    return a.keyword += " " + t, a.literal += " " + i, a.built_in += " " + r, o
});
hljs.registerLanguage("nginx", function (e) {
    var r = {
            cN: "variable",
            v: [{
                b: /\$\d+/
            }, {
                b: /\$\{/,
                e: /}/
            }, {
                b: "[\\$\\@]" + e.UIR
            }]
        },
        b = {
            eW: !0,
            l: "[a-z/_]+",
            k: {
                literal: "on off yes no true false none blocked debug info notice warn error crit select break last permanent redirect kqueue rtsig epoll poll /dev/poll"
            },
            relevance: 0,
            i: "=>",
            c: [e.HCM, {
                cN: "string",
                c: [e.BE, r],
                v: [{
                    b: /"/,
                    e: /"/
                }, {
                    b: /'/,
                    e: /'/
                }]
            }, {
                b: "([a-z]+):/",
                e: "\\s",
                eW: !0,
                eE: !0,
                c: [r]
            }, {
                cN: "regexp",
                c: [e.BE, r],
                v: [{
                    b: "\\s\\^",
                    e: "\\s|{|;",
                    rE: !0
                }, {
                    b: "~\\*?\\s+",
                    e: "\\s|{|;",
                    rE: !0
                }, {
                    b: "\\*(\\.[a-z\\-]+)+"
                }, {
                    b: "([a-z\\-]+\\.)+\\*"
                }]
            }, {
                cN: "number",
                b: "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(:\\d{1,5})?\\b"
            }, {
                cN: "number",
                b: "\\b\\d+[kKmMgGdshdwy]*\\b",
                relevance: 0
            }, r]
        };
    return {
        aliases: ["nginxconf"],
        c: [e.HCM, {
            b: e.UIR + "\\s+{",
            rB: !0,
            e: "{",
            c: [{
                cN: "section",
                b: e.UIR
            }],
            relevance: 0
        }, {
            b: e.UIR + "\\s",
            e: ";|{",
            rB: !0,
            c: [{
                cN: "attribute",
                b: e.UIR,
                starts: b
            }],
            relevance: 0
        }],
        i: "[^\\s\\}]"
    }
});
hljs.registerLanguage("xml", function (e) {
    var c = {
            cN: "symbol",
            b: "&[a-z]+;|&#[0-9]+;|&#x[a-f0-9]+;"
        },
        s = {
            b: "\\s",
            c: [{
                cN: "meta-keyword",
                b: "#?[a-z_][a-z1-9_-]+",
                i: "\\n"
            }]
        },
        a = e.inherit(s, {
            b: "\\(",
            e: "\\)"
        }),
        t = e.inherit(e.ASM, {
            cN: "meta-string"
        }),
        l = e.inherit(e.QSM, {
            cN: "meta-string"
        }),
        r = {
            eW: !0,
            i: /</,
            relevance: 0,
            c: [{
                cN: "attr",
                b: "[A-Za-z0-9\\._:-]+",
                relevance: 0
            }, {
                b: /=\s*/,
                relevance: 0,
                c: [{
                    cN: "string",
                    endsParent: !0,
                    v: [{
                        b: /"/,
                        e: /"/,
                        c: [c]
                    }, {
                        b: /'/,
                        e: /'/,
                        c: [c]
                    }, {
                        b: /[^\s"'=<>`]+/
                    }]
                }]
            }]
        };
    return {
        aliases: ["html", "xhtml", "rss", "atom", "xjb", "xsd", "xsl", "plist", "wsf", "svg"],
        cI: !0,
        c: [{
            cN: "meta",
            b: "<![a-z]",
            e: ">",
            relevance: 10,
            c: [s, l, t, a, {
                b: "\\[",
                e: "\\]",
                c: [{
                    cN: "meta",
                    b: "<![a-z]",
                    e: ">",
                    c: [s, a, l, t]
                }]
            }]
        }, e.C("<!--", "-->", {
            relevance: 10
        }), {
            b: "<\\!\\[CDATA\\[",
            e: "\\]\\]>",
            relevance: 10
        }, c, {
            cN: "meta",
            b: /<\?xml/,
            e: /\?>/,
            relevance: 10
        }, {
            b: /<\?(php)?/,
            e: /\?>/,
            sL: "php",
            c: [{
                b: "/\\*",
                e: "\\*/",
                skip: !0
            }, {
                b: 'b"',
                e: '"',
                skip: !0
            }, {
                b: "b'",
                e: "'",
                skip: !0
            }, e.inherit(e.ASM, {
                i: null,
                cN: null,
                c: null,
                skip: !0
            }), e.inherit(e.QSM, {
                i: null,
                cN: null,
                c: null,
                skip: !0
            })]
        }, {
            cN: "tag",
            b: "<style(?=\\s|>)",
            e: ">",
            k: {
                name: "style"
            },
            c: [r],
            starts: {
                e: "</style>",
                rE: !0,
                sL: ["css", "xml"]
            }
        }, {
            cN: "tag",
            b: "<script(?=\\s|>)",
            e: ">",
            k: {
                name: "script"
            },
            c: [r],
            starts: {
                e: "<\/script>",
                rE: !0,
                sL: ["actionscript", "javascript", "handlebars", "xml"]
            }
        }, {
            cN: "tag",
            b: "</?",
            e: "/?>",
            c: [{
                cN: "name",
                b: /[^\/><\s]+/,
                relevance: 0
            }, r]
        }]
    }
});
hljs.registerLanguage("markdown", function (e) {
    return {
        aliases: ["md", "mkdown", "mkd"],
        c: [{
            cN: "section",
            v: [{
                b: "^#{1,6}",
                e: "$"
            }, {
                b: "^.+?\\n[=-]{2,}$"
            }]
        }, {
            b: "<",
            e: ">",
            sL: "xml",
            relevance: 0
        }, {
            cN: "bullet",
            b: "^\\s*([*+-]|(\\d+\\.))\\s+"
        }, {
            cN: "strong",
            b: "[*_]{2}.+?[*_]{2}"
        }, {
            cN: "emphasis",
            v: [{
                b: "\\*.+?\\*"
            }, {
                b: "_.+?_",
                relevance: 0
            }]
        }, {
            cN: "quote",
            b: "^>\\s+",
            e: "$"
        }, {
            cN: "code",
            v: [{
                b: "^```\\w*\\s*$",
                e: "^```[ ]*$"
            }, {
                b: "`.+?`"
            }, {
                b: "^( {4}|\\t)",
                e: "$",
                relevance: 0
            }]
        }, {
            b: "^[-\\*]{3,}",
            e: "$"
        }, {
            b: "\\[.+?\\][\\(\\[].*?[\\)\\]]",
            rB: !0,
            c: [{
                cN: "string",
                b: "\\[",
                e: "\\]",
                eB: !0,
                rE: !0,
                relevance: 0
            }, {
                cN: "link",
                b: "\\]\\(",
                e: "\\)",
                eB: !0,
                eE: !0
            }, {
                cN: "symbol",
                b: "\\]\\[",
                e: "\\]",
                eB: !0,
                eE: !0
            }],
            relevance: 10
        }, {
            b: /^\[[^\n]+\]:/,
            rB: !0,
            c: [{
                cN: "symbol",
                b: /\[/,
                e: /\]/,
                eB: !0,
                eE: !0
            }, {
                cN: "link",
                b: /:\s*/,
                e: /$/,
                eB: !0
            }]
        }]
    }
});
hljs.registerLanguage("ini", function (e) {
    var b = {
            cN: "number",
            relevance: 0,
            v: [{
                b: /([\+\-]+)?[\d]+_[\d_]+/
            }, {
                b: e.NR
            }]
        },
        a = e.C();
    a.v = [{
        b: /;/,
        e: /$/
    }, {
        b: /#/,
        e: /$/
    }];
    var c = {
            cN: "variable",
            v: [{
                b: /\$[\w\d"][\w\d_]*/
            }, {
                b: /\$\{(.*?)}/
            }]
        },
        r = {
            cN: "literal",
            b: /\bon|off|true|false|yes|no\b/
        },
        n = {
            cN: "string",
            c: [e.BE],
            v: [{
                b: "'''",
                e: "'''",
                relevance: 10
            }, {
                b: '"""',
                e: '"""',
                relevance: 10
            }, {
                b: '"',
                e: '"'
            }, {
                b: "'",
                e: "'"
            }]
        };
    return {
        aliases: ["toml"],
        cI: !0,
        i: /\S/,
        c: [a, {
            cN: "section",
            b: /\[+/,
            e: /\]+/
        }, {
            b: /^[a-z0-9\[\]_\.-]+(?=\s*=\s*)/,
            cN: "attr",
            starts: {
                e: /$/,
                c: [a, {
                    b: /\[/,
                    e: /\]/,
                    c: [a, r, c, n, b, "self"],
                    relevance: 0
                }, r, c, n, b]
            }
        }]
    }
});
hljs.registerLanguage("diff", function (e) {
    return {
        aliases: ["patch"],
        c: [{
            cN: "meta",
            relevance: 10,
            v: [{
                b: /^@@ +\-\d+,\d+ +\+\d+,\d+ +@@$/
            }, {
                b: /^\*\*\* +\d+,\d+ +\*\*\*\*$/
            }, {
                b: /^\-\-\- +\d+,\d+ +\-\-\-\-$/
            }]
        }, {
            cN: "comment",
            v: [{
                b: /Index: /,
                e: /$/
            }, {
                b: /={3,}/,
                e: /$/
            }, {
                b: /^\-{3}/,
                e: /$/
            }, {
                b: /^\*{3} /,
                e: /$/
            }, {
                b: /^\+{3}/,
                e: /$/
            }, {
                b: /^\*{15}$/
            }]
        }, {
            cN: "addition",
            b: "^\\+",
            e: "$"
        }, {
            cN: "deletion",
            b: "^\\-",
            e: "$"
        }, {
            cN: "addition",
            b: "^\\!",
            e: "$"
        }]
    }
});
hljs.registerLanguage("http", function (e) {
    var t = "HTTP/[0-9\\.]+";
    return {
        aliases: ["https"],
        i: "\\S",
        c: [{
            b: "^" + t,
            e: "$",
            c: [{
                cN: "number",
                b: "\\b\\d{3}\\b"
            }]
        }, {
            b: "^[A-Z]+ (.*?) " + t + "$",
            rB: !0,
            e: "$",
            c: [{
                cN: "string",
                b: " ",
                e: " ",
                eB: !0,
                eE: !0
            }, {
                b: t
            }, {
                cN: "keyword",
                b: "[A-Z]+"
            }]
        }, {
            cN: "attribute",
            b: "^\\w",
            e: ": ",
            eE: !0,
            i: "\\n|\\s|=",
            starts: {
                e: "$",
                relevance: 0
            }
        }, {
            b: "\\n\\n",
            starts: {
                sL: [],
                eW: !0
            }
        }]
    }
});
hljs.registerLanguage("sql", function (e) {
    var t = e.C("--", "$");
    return {
        cI: !0,
        i: /[<>{}*]/,
        c: [{
            bK: "begin end start commit rollback savepoint lock alter create drop rename call delete do handler insert load replace select truncate update set show pragma grant merge describe use explain help declare prepare execute deallocate release unlock purge reset change stop analyze cache flush optimize repair kill install uninstall checksum restore check backup revoke comment values with",
            e: /;/,
            eW: !0,
            l: /[\w\.]+/,
            k: {
                keyword: "as abort abs absolute acc acce accep accept access accessed accessible account acos action activate add addtime admin administer advanced advise aes_decrypt aes_encrypt after agent aggregate ali alia alias all allocate allow alter always analyze ancillary and anti any anydata anydataset anyschema anytype apply archive archived archivelog are as asc ascii asin assembly assertion associate asynchronous at atan atn2 attr attri attrib attribu attribut attribute attributes audit authenticated authentication authid authors auto autoallocate autodblink autoextend automatic availability avg backup badfile basicfile before begin beginning benchmark between bfile bfile_base big bigfile bin binary_double binary_float binlog bit_and bit_count bit_length bit_or bit_xor bitmap blob_base block blocksize body both bound bucket buffer_cache buffer_pool build bulk by byte byteordermark bytes cache caching call calling cancel capacity cascade cascaded case cast catalog category ceil ceiling chain change changed char_base char_length character_length characters characterset charindex charset charsetform charsetid check checksum checksum_agg child choose chr chunk class cleanup clear client clob clob_base clone close cluster_id cluster_probability cluster_set clustering coalesce coercibility col collate collation collect colu colum column column_value columns columns_updated comment commit compact compatibility compiled complete composite_limit compound compress compute concat concat_ws concurrent confirm conn connec connect connect_by_iscycle connect_by_isleaf connect_by_root connect_time connection consider consistent constant constraint constraints constructor container content contents context contributors controlfile conv convert convert_tz corr corr_k corr_s corresponding corruption cos cost count count_big counted covar_pop covar_samp cpu_per_call cpu_per_session crc32 create creation critical cross cube cume_dist curdate current current_date current_time current_timestamp current_user cursor curtime customdatum cycle data database databases datafile datafiles datalength date_add date_cache date_format date_sub dateadd datediff datefromparts datename datepart datetime2fromparts day day_to_second dayname dayofmonth dayofweek dayofyear days db_role_change dbtimezone ddl deallocate declare decode decompose decrement decrypt deduplicate def defa defau defaul default defaults deferred defi defin define degrees delayed delegate delete delete_all delimited demand dense_rank depth dequeue des_decrypt des_encrypt des_key_file desc descr descri describ describe descriptor deterministic diagnostics difference dimension direct_load directory disable disable_all disallow disassociate discardfile disconnect diskgroup distinct distinctrow distribute distributed div do document domain dotnet double downgrade drop dumpfile duplicate duration each edition editionable editions element ellipsis else elsif elt empty enable enable_all enclosed encode encoding encrypt end end-exec endian enforced engine engines enqueue enterprise entityescaping eomonth error errors escaped evalname evaluate event eventdata events except exception exceptions exchange exclude excluding execu execut execute exempt exists exit exp expire explain explode export export_set extended extent external external_1 external_2 externally extract failed failed_login_attempts failover failure far fast feature_set feature_value fetch field fields file file_name_convert filesystem_like_logging final finish first first_value fixed flash_cache flashback floor flush following follows for forall force foreign form forma format found found_rows freelist freelists freepools fresh from from_base64 from_days ftp full function general generated get get_format get_lock getdate getutcdate global global_name globally go goto grant grants greatest group group_concat group_id grouping grouping_id groups gtid_subtract guarantee guard handler hash hashkeys having hea head headi headin heading heap help hex hierarchy high high_priority hosts hour hours http id ident_current ident_incr ident_seed identified identity idle_time if ifnull ignore iif ilike ilm immediate import in include including increment index indexes indexing indextype indicator indices inet6_aton inet6_ntoa inet_aton inet_ntoa infile initial initialized initially initrans inmemory inner innodb input insert install instance instantiable instr interface interleaved intersect into invalidate invisible is is_free_lock is_ipv4 is_ipv4_compat is_not is_not_null is_used_lock isdate isnull isolation iterate java join json json_exists keep keep_duplicates key keys kill language large last last_day last_insert_id last_value lateral lax lcase lead leading least leaves left len lenght length less level levels library like like2 like4 likec limit lines link list listagg little ln load load_file lob lobs local localtime localtimestamp locate locator lock locked log log10 log2 logfile logfiles logging logical logical_reads_per_call logoff logon logs long loop low low_priority lower lpad lrtrim ltrim main make_set makedate maketime managed management manual map mapping mask master master_pos_wait match matched materialized max maxextents maximize maxinstances maxlen maxlogfiles maxloghistory maxlogmembers maxsize maxtrans md5 measures median medium member memcompress memory merge microsecond mid migration min minextents minimum mining minus minute minutes minvalue missing mod mode model modification modify module monitoring month months mount move movement multiset mutex name name_const names nan national native natural nav nchar nclob nested never new newline next nextval no no_write_to_binlog noarchivelog noaudit nobadfile nocheck nocompress nocopy nocycle nodelay nodiscardfile noentityescaping noguarantee nokeep nologfile nomapping nomaxvalue nominimize nominvalue nomonitoring none noneditionable nonschema noorder nopr nopro noprom nopromp noprompt norely noresetlogs noreverse normal norowdependencies noschemacheck noswitch not nothing notice notnull notrim novalidate now nowait nth_value nullif nulls num numb numbe nvarchar nvarchar2 object ocicoll ocidate ocidatetime ociduration ociinterval ociloblocator ocinumber ociref ocirefcursor ocirowid ocistring ocitype oct octet_length of off offline offset oid oidindex old on online only opaque open operations operator optimal optimize option optionally or oracle oracle_date oradata ord ordaudio orddicom orddoc order ordimage ordinality ordvideo organization orlany orlvary out outer outfile outline output over overflow overriding package pad parallel parallel_enable parameters parent parse partial partition partitions pascal passing password password_grace_time password_lock_time password_reuse_max password_reuse_time password_verify_function patch path patindex pctincrease pctthreshold pctused pctversion percent percent_rank percentile_cont percentile_disc performance period period_add period_diff permanent physical pi pipe pipelined pivot pluggable plugin policy position post_transaction pow power pragma prebuilt precedes preceding precision prediction prediction_cost prediction_details prediction_probability prediction_set prepare present preserve prior priority private private_sga privileges procedural procedure procedure_analyze processlist profiles project prompt protection public publishingservername purge quarter query quick quiesce quota quotename radians raise rand range rank raw read reads readsize rebuild record records recover recovery recursive recycle redo reduced ref reference referenced references referencing refresh regexp_like register regr_avgx regr_avgy regr_count regr_intercept regr_r2 regr_slope regr_sxx regr_sxy reject rekey relational relative relaylog release release_lock relies_on relocate rely rem remainder rename repair repeat replace replicate replication required reset resetlogs resize resource respect restore restricted result result_cache resumable resume retention return returning returns reuse reverse revoke right rlike role roles rollback rolling rollup round row row_count rowdependencies rowid rownum rows rtrim rules safe salt sample save savepoint sb1 sb2 sb4 scan schema schemacheck scn scope scroll sdo_georaster sdo_topo_geometry search sec_to_time second seconds section securefile security seed segment select self semi sequence sequential serializable server servererror session session_user sessions_per_user set sets settings sha sha1 sha2 share shared shared_pool short show shrink shutdown si_averagecolor si_colorhistogram si_featurelist si_positionalcolor si_stillimage si_texture siblings sid sign sin size size_t sizes skip slave sleep smalldatetimefromparts smallfile snapshot some soname sort soundex source space sparse spfile split sql sql_big_result sql_buffer_result sql_cache sql_calc_found_rows sql_small_result sql_variant_property sqlcode sqldata sqlerror sqlname sqlstate sqrt square standalone standby start starting startup statement static statistics stats_binomial_test stats_crosstab stats_ks_test stats_mode stats_mw_test stats_one_way_anova stats_t_test_ stats_t_test_indep stats_t_test_one stats_t_test_paired stats_wsr_test status std stddev stddev_pop stddev_samp stdev stop storage store stored str str_to_date straight_join strcmp strict string struct stuff style subdate subpartition subpartitions substitutable substr substring subtime subtring_index subtype success sum suspend switch switchoffset switchover sync synchronous synonym sys sys_xmlagg sysasm sysaux sysdate sysdatetimeoffset sysdba sysoper system system_user sysutcdatetime table tables tablespace tablesample tan tdo template temporary terminated tertiary_weights test than then thread through tier ties time time_format time_zone timediff timefromparts timeout timestamp timestampadd timestampdiff timezone_abbr timezone_minute timezone_region to to_base64 to_date to_days to_seconds todatetimeoffset trace tracking transaction transactional translate translation treat trigger trigger_nestlevel triggers trim truncate try_cast try_convert try_parse type ub1 ub2 ub4 ucase unarchived unbounded uncompress under undo unhex unicode uniform uninstall union unique unix_timestamp unknown unlimited unlock unnest unpivot unrecoverable unsafe unsigned until untrusted unusable unused update updated upgrade upped upper upsert url urowid usable usage use use_stored_outlines user user_data user_resources users using utc_date utc_timestamp uuid uuid_short validate validate_password_strength validation valist value values var var_samp varcharc vari varia variab variabl variable variables variance varp varraw varrawc varray verify version versions view virtual visible void wait wallet warning warnings week weekday weekofyear wellformed when whene whenev wheneve whenever where while whitespace window with within without work wrapped xdb xml xmlagg xmlattributes xmlcast xmlcolattval xmlelement xmlexists xmlforest xmlindex xmlnamespaces xmlpi xmlquery xmlroot xmlschema xmlserialize xmltable xmltype xor year year_to_month years yearweek",
                literal: "true false null unknown",
                built_in: "array bigint binary bit blob bool boolean char character date dec decimal float int int8 integer interval number numeric real record serial serial8 smallint text time timestamp tinyint varchar varchar2 varying void"
            },
            c: [{
                cN: "string",
                b: "'",
                e: "'",
                c: [{
                    b: "''"
                }]
            }, {
                cN: "string",
                b: '"',
                e: '"',
                c: [{
                    b: '""'
                }]
            }, {
                cN: "string",
                b: "`",
                e: "`"
            }, e.CNM, e.CBCM, t, e.HCM]
        }, e.CBCM, t, e.HCM]
    }
});
hljs.registerLanguage("bash", function (e) {
    var t = {
            cN: "variable",
            v: [{
                b: /\$[\w\d#@][\w\d_]*/
            }, {
                b: /\$\{(.*?)}/
            }]
        },
        a = {
            cN: "string",
            b: /"/,
            e: /"/,
            c: [e.BE, t, {
                cN: "variable",
                b: /\$\(/,
                e: /\)/,
                c: [e.BE]
            }]
        };
    return {
        aliases: ["sh", "zsh"],
        l: /\b-?[a-z\._]+\b/,
        k: {
            keyword: "if then else elif fi for while in do done case esac function",
            literal: "true false",
            built_in: "break cd continue eval exec exit export getopts hash pwd readonly return shift test times trap umask unset alias bind builtin caller command declare echo enable help let local logout mapfile printf read readarray source type typeset ulimit unalias set shopt autoload bg bindkey bye cap chdir clone comparguments compcall compctl compdescribe compfiles compgroups compquote comptags comptry compvalues dirs disable disown echotc echoti emulate fc fg float functions getcap getln history integer jobs kill limit log noglob popd print pushd pushln rehash sched setcap setopt stat suspend ttyctl unfunction unhash unlimit unsetopt vared wait whence where which zcompile zformat zftp zle zmodload zparseopts zprof zpty zregexparse zsocket zstyle ztcp",
            _: "-ne -eq -lt -gt -f -d -e -s -l -a"
        },
        c: [{
            cN: "meta",
            b: /^#![^\n]+sh\s*$/,
            relevance: 10
        }, {
            cN: "function",
            b: /\w[\w\d_]*\s*\(\s*\)\s*\{/,
            rB: !0,
            c: [e.inherit(e.TM, {
                b: /\w[\w\d_]*/
            })],
            relevance: 0
        }, e.HCM, a, {
            cN: "",
            b: /\\"/
        }, {
            cN: "string",
            b: /'/,
            e: /'/
        }, t]
    }
});
hljs.registerLanguage("avrasm", function (r) {
    return {
        cI: !0,
        l: "\\.?" + r.IR,
        k: {
            keyword: "adc add adiw and andi asr bclr bld brbc brbs brcc brcs break breq brge brhc brhs brid brie brlo brlt brmi brne brpl brsh brtc brts brvc brvs bset bst call cbi cbr clc clh cli cln clr cls clt clv clz com cp cpc cpi cpse dec eicall eijmp elpm eor fmul fmuls fmulsu icall ijmp in inc jmp ld ldd ldi lds lpm lsl lsr mov movw mul muls mulsu neg nop or ori out pop push rcall ret reti rjmp rol ror sbc sbr sbrc sbrs sec seh sbi sbci sbic sbis sbiw sei sen ser ses set sev sez sleep spm st std sts sub subi swap tst wdr",
            built_in: "r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16 r17 r18 r19 r20 r21 r22 r23 r24 r25 r26 r27 r28 r29 r30 r31 x|0 xh xl y|0 yh yl z|0 zh zl ucsr1c udr1 ucsr1a ucsr1b ubrr1l ubrr1h ucsr0c ubrr0h tccr3c tccr3a tccr3b tcnt3h tcnt3l ocr3ah ocr3al ocr3bh ocr3bl ocr3ch ocr3cl icr3h icr3l etimsk etifr tccr1c ocr1ch ocr1cl twcr twdr twar twsr twbr osccal xmcra xmcrb eicra spmcsr spmcr portg ddrg ping portf ddrf sreg sph spl xdiv rampz eicrb eimsk gimsk gicr eifr gifr timsk tifr mcucr mcucsr tccr0 tcnt0 ocr0 assr tccr1a tccr1b tcnt1h tcnt1l ocr1ah ocr1al ocr1bh ocr1bl icr1h icr1l tccr2 tcnt2 ocr2 ocdr wdtcr sfior eearh eearl eedr eecr porta ddra pina portb ddrb pinb portc ddrc pinc portd ddrd pind spdr spsr spcr udr0 ucsr0a ucsr0b ubrr0l acsr admux adcsr adch adcl porte ddre pine pinf",
            meta: ".byte .cseg .db .def .device .dseg .dw .endmacro .equ .eseg .exit .include .list .listmac .macro .nolist .org .set"
        },
        c: [r.CBCM, r.C(";", "$", {
            relevance: 0
        }), r.CNM, r.BNM, {
            cN: "number",
            b: "\\b(\\$[a-zA-Z0-9]+|0o[0-7]+)"
        }, r.QSM, {
            cN: "string",
            b: "'",
            e: "[^\\\\]'",
            i: "[^\\\\][^']"
        }, {
            cN: "symbol",
            b: "^[A-Za-z0-9_.$]+:"
        }, {
            cN: "meta",
            b: "#",
            e: "$"
        }, {
            cN: "subst",
            b: "@[0-9]+"
        }]
    }
});
hljs.registerLanguage("mipsasm", function (e) {
    return {
        cI: !0,
        aliases: ["mips"],
        l: "\\.?" + e.IR,
        k: {
            meta: ".2byte .4byte .align .ascii .asciz .balign .byte .code .data .else .end .endif .endm .endr .equ .err .exitm .extern .global .hword .if .ifdef .ifndef .include .irp .long .macro .rept .req .section .set .skip .space .text .word .ltorg ",
            built_in: "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $30 $31 zero at v0 v1 a0 a1 a2 a3 a4 a5 a6 a7 t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 s0 s1 s2 s3 s4 s5 s6 s7 s8 k0 k1 gp sp fp ra $f0 $f1 $f2 $f2 $f4 $f5 $f6 $f7 $f8 $f9 $f10 $f11 $f12 $f13 $f14 $f15 $f16 $f17 $f18 $f19 $f20 $f21 $f22 $f23 $f24 $f25 $f26 $f27 $f28 $f29 $f30 $f31 Context Random EntryLo0 EntryLo1 Context PageMask Wired EntryHi HWREna BadVAddr Count Compare SR IntCtl SRSCtl SRSMap Cause EPC PRId EBase Config Config1 Config2 Config3 LLAddr Debug DEPC DESAVE CacheErr ECC ErrorEPC TagLo DataLo TagHi DataHi WatchLo WatchHi PerfCtl PerfCnt "
        },
        c: [{
            cN: "keyword",
            b: "\\b(addi?u?|andi?|b(al)?|beql?|bgez(al)?l?|bgtzl?|blezl?|bltz(al)?l?|bnel?|cl[oz]|divu?|ext|ins|j(al)?|jalr(.hb)?|jr(.hb)?|lbu?|lhu?|ll|lui|lw[lr]?|maddu?|mfhi|mflo|movn|movz|move|msubu?|mthi|mtlo|mul|multu?|nop|nor|ori?|rotrv?|sb|sc|se[bh]|sh|sllv?|slti?u?|srav?|srlv?|subu?|sw[lr]?|xori?|wsbh|abs.[sd]|add.[sd]|alnv.ps|bc1[ft]l?|c.(s?f|un|u?eq|[ou]lt|[ou]le|ngle?|seq|l[et]|ng[et]).[sd]|(ceil|floor|round|trunc).[lw].[sd]|cfc1|cvt.d.[lsw]|cvt.l.[dsw]|cvt.ps.s|cvt.s.[dlw]|cvt.s.p[lu]|cvt.w.[dls]|div.[ds]|ldx?c1|luxc1|lwx?c1|madd.[sd]|mfc1|mov[fntz]?.[ds]|msub.[sd]|mth?c1|mul.[ds]|neg.[ds]|nmadd.[ds]|nmsub.[ds]|p[lu][lu].ps|recip.fmt|r?sqrt.[ds]|sdx?c1|sub.[ds]|suxc1|swx?c1|break|cache|d?eret|[de]i|ehb|mfc0|mtc0|pause|prefx?|rdhwr|rdpgpr|sdbbp|ssnop|synci?|syscall|teqi?|tgei?u?|tlb(p|r|w[ir])|tlti?u?|tnei?|wait|wrpgpr)",
            e: "\\s"
        }, e.C("[;#](?!s*$)", "$"), e.CBCM, e.QSM, {
            cN: "string",
            b: "'",
            e: "[^\\\\]'",
            relevance: 0
        }, {
            cN: "title",
            b: "\\|",
            e: "\\|",
            i: "\\n",
            relevance: 0
        }, {
            cN: "number",
            v: [{
                b: "0x[0-9a-f]+"
            }, {
                b: "\\b-?\\d+"
            }],
            relevance: 0
        }, {
            cN: "symbol",
            v: [{
                b: "^\\s*[a-z_\\.\\$][a-z0-9_\\.\\$]+:"
            }, {
                b: "^\\s*[0-9]+:"
            }, {
                b: "[0-9]+[bf]"
            }],
            relevance: 0
        }],
        i: "/"
    }
});
hljs.registerLanguage("css", function (e) {
    var c = {
        b: /(?:[A-Z\_\.\-]+|--[a-zA-Z0-9_-]+)\s*:/,
        rB: !0,
        e: ";",
        eW: !0,
        c: [{
            cN: "attribute",
            b: /\S/,
            e: ":",
            eE: !0,
            starts: {
                eW: !0,
                eE: !0,
                c: [{
                    b: /[\w-]+\(/,
                    rB: !0,
                    c: [{
                        cN: "built_in",
                        b: /[\w-]+/
                    }, {
                        b: /\(/,
                        e: /\)/,
                        c: [e.ASM, e.QSM, e.CSSNM]
                    }]
                }, e.CSSNM, e.QSM, e.ASM, e.CBCM, {
                    cN: "number",
                    b: "#[0-9A-Fa-f]+"
                }, {
                    cN: "meta",
                    b: "!important"
                }]
            }
        }]
    };
    return {
        cI: !0,
        i: /[=\/|'\$]/,
        c: [e.CBCM, {
            cN: "selector-id",
            b: /#[A-Za-z0-9_-]+/
        }, {
            cN: "selector-class",
            b: /\.[A-Za-z0-9_-]+/
        }, {
            cN: "selector-attr",
            b: /\[/,
            e: /\]/,
            i: "$",
            c: [e.ASM, e.QSM]
        }, {
            cN: "selector-pseudo",
            b: /:(:)?[a-zA-Z0-9\_\-\+\(\)"'.]+/
        }, {
            b: "@(page|font-face)",
            l: "@[a-z-]+",
            k: "@page @font-face"
        }, {
            b: "@",
            e: "[{;]",
            i: /:/,
            rB: !0,
            c: [{
                cN: "keyword",
                b: /@\-?\w[\w]*(\-\w+)*/
            }, {
                b: /\s/,
                eW: !0,
                eE: !0,
                relevance: 0,
                k: "and or not only",
                c: [{
                    b: /[a-z-]+:/,
                    cN: "attribute"
                }, e.ASM, e.QSM, e.CSSNM]
            }]
        }, {
            cN: "selector-tag",
            b: "[a-zA-Z-][a-zA-Z0-9_-]*",
            relevance: 0
        }, {
            b: "{",
            e: "}",
            i: /\S/,
            c: [e.CBCM, c]
        }]
    }
});
