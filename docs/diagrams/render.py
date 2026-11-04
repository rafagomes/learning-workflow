#!/usr/bin/env python3
"""Renders the README diagrams as light and dark SVGs. Edit here, then run: python3 docs/diagrams/render.py"""
import os
from pathlib import Path
from xml.sax.saxutils import escape

OUT = Path(os.environ.get("DIAGRAMS_OUT") or Path(__file__).parent)
SANS = "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif"
MONO = "ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace"

# GitHub Primer colours, so the diagrams sit naturally on github.com in either theme.
THEMES = {
    "light": dict(text="#1f2328", muted="#59636e", line="#818b98", border="#d1d9e0", card="#ffffff",
                  purple="#8250df", green="#1a7f37", blue="#0969da", orange="#bc4c00", fill_alpha="0f"),
    "dark": dict(text="#f0f6fc", muted="#9198a1", line="#656c76", border="#3d444d", card="#151b23",
                 purple="#ab7df8", green="#3fb950", blue="#4493f8", orange="#f0883e", fill_alpha="1f"),
}


MARKER_COLORS = ("line", "purple", "green", "blue", "orange")


class Svg:
    def __init__(self, w, h, t):
        self.w, self.h, self.t, self.parts = w, h, t, []

    def add(self, s):
        self.parts.append(s)

    def text(self, x, y, s, size=13, weight=400, color="text", anchor="start", mono=False):
        fam = MONO if mono else SANS
        self.add(f'<text x="{x}" y="{y}" font-family="{fam}" font-size="{size}" font-weight="{weight}" '
                 f'fill="{self.t[color]}" text-anchor="{anchor}" xml:space="preserve">{escape(s)}</text>')

    def box(self, x, y, w, h, accent, rx=12, dashed=False, plain=False, stroke=1.5):
        # Opaque underlay first, so arrows passing behind never show through the translucent tint.
        c = self.t[accent]
        fill = self.t["card"] if plain else c + self.t["fill_alpha"]
        dash = ' stroke-dasharray="6 4"' if dashed else ""
        self.add(f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" rx="{rx}" fill="{self.t["card"]}"/>')
        self.add(f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" rx="{rx}" fill="{fill}" stroke="{c}" stroke-width="{stroke}"{dash}/>')

    def card(self, x, y, w, h, accent, title=None, sub=None, lines=()):
        self.box(x, y, w, h, accent)
        ty = y + 26
        if title:
            self.text(x + 16, ty, title, 14, 600)
            ty += 19
        if sub:
            self.text(x + 16, ty, sub, 12, 400, accent)
            ty += 22
        for line in lines:
            self.text(x + 16, ty, line, 12.5, 400, "muted")
            ty += 19

    def pill(self, cx, cy, s, accent, size=12.5):
        w = round(len(s) * size * 0.55 + 26, 1)
        self.box(cx - w / 2, cy - 14, w, 28, accent, rx=14, stroke=1.2)
        self.text(cx, cy + 4.5, s, size, 500, accent, "middle")

    def arrow(self, d, color="line", dashed=False):
        assert color in MARKER_COLORS, f"no arrowhead marker for {color!r}"
        dash = ' stroke-dasharray="5 4"' if dashed else ""
        self.add(f'<path d="{d}" fill="none" stroke="{self.t[color]}" stroke-width="1.6"{dash} marker-end="url(#m-{color})"/>')

    def render(self, title, desc):
        markers = "".join(
            f'<marker id="m-{k}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
            f'<path d="M0,0 L10,5 L0,10 z" fill="{self.t[k]}"/></marker>'
            for k in MARKER_COLORS)
        return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}" viewBox="0 0 {self.w} {self.h}" '
                f'role="img" aria-labelledby="t d"><title id="t">{escape(title)}</title><desc id="d">{escape(desc)}</desc>'
                f'<defs>{markers}</defs>{"".join(self.parts)}</svg>\n')


def repo_model(t):
    s = Svg(880, 330, t)
    s.card(20, 30, 210, 191, "purple", "learning-workflow", "this plugin · public",
           ["skills/", "  init · plan · build · off", "  curriculum · teach", "  practice · quiz · reflect", "  init/templates/", "hooks/ · docs/"])
    s.card(330, 30, 240, 210, "green", "Your learning repo", "one per subject · private",
           ["LEARNING.md · PROGRESS.md", "curriculum/ · plans/", "lessons/", "  lesson · lab · exercises", "builds/ · reflections/", "flashcards/  scratch/"])
    s.card(670, 30, 190, 84, "orange", "Project A", "work", ["your employer's repo"])
    s.card(670, 134, 190, 84, "blue", "Project B", "personal", ["your side project"])
    s.arrow("M230,96 L326,96", "purple")
    s.text(278, 86, "/learn:init", 12, 500, "muted", "middle", True)
    s.arrow("M230,150 L326,150", "purple")
    s.text(278, 140, "reads · writes", 12, 500, "muted", "middle")
    s.arrow("M570,70 L666,64", dashed=True)
    s.arrow("M570,200 L666,188", dashed=True)
    s.text(618, 104, "study: reads,", 12, 500, "muted", "middle")
    s.text(618, 121, "cites path@sha", 12, 500, "muted", "middle")
    s.text(618, 141, "build mode:", 12, 500, "blue", "middle")
    s.text(618, 158, "codes with you", 12, 500, "blue", "middle")
    s.text(765, 240, "Projects never point", 12, 400, "muted", "middle")
    s.text(765, 257, "back at the learning repo", 12, 400, "muted", "middle")
    s.pill(440, 294, "registry + learn-mode state: ~/.config/learning-workflow/ (outside every repo)", "line", size=12)
    return s.render("How the repos relate",
                    "The plugin creates and works in a private learning repo per subject. Study skills read linked work and personal projects; in build mode Claude codes in the project with you. Projects never reference the learning repo.")


def build_mode(t):
    s = Svg(880, 405, t)
    s.card(20, 30, 190, 96, "orange", "Dev plan", "in your project", ["spec · roadmap · issue · goal"])
    s.card(250, 30, 190, 96, "blue", "/learn:plan", "learning plan, by step", ["concepts known / new", "level · done-check"])
    s.card(480, 30, 190, 96, "blue", "/learn:build S1", "learn mode on", ["due flashcards first"])
    s.arrow("M210,78 L246,78")
    s.arrow("M440,78 L476,78")
    # the prompt loop
    x, y, w, h = 300, 168, 560, 170
    s.box(x, y, w, h, "blue", rx=16, dashed=True)
    s.text(x + 18, y + 28, "Every prompt, until the step is done", 14, 600)
    items = [("Code at your level", "claude · adaptive · you"),
             ("▸ Concept note", "only when a decision needs it"),
             ("Predict, then run", "before tests and evals"),
             ("Deep dive", "while background tasks run")]
    for i, (a, b) in enumerate(items):
        ix = x + 18 + (i % 2) * 272
        iy = y + 46 + (i // 2) * 56
        s.box(ix, iy, 254, 46, "border", rx=10, plain=True, stroke=1)
        s.text(ix + 14, iy + 20, a, 13, 600)
        s.text(ix + 14, iy + 37, b, 12, 400, "muted")
    s.pill(x + w - 128, y, "hook re-injects state", "purple", size=11.5)
    s.arrow("M575,126 L575,164")
    # done → wrap-up
    s.card(20, 168, 240, 80, "green", "Step done", "you say so, or the PR opens", [])
    s.arrow("M300,208 L264,208")
    s.card(20, 270, 240, 120, "green", "Done-check → wrap-up", "3–5 questions on your code",
           ["build log · flashcards · PROGRESS", "learn mode off", "then /learn:build <next step>"])
    s.arrow("M140,248 L140,266")
    s.text(860, 362, "Deep concepts are noted for /learn:teach later.", 12, 400, "muted", "end")
    s.text(860, 381, "/learn:off pauses early and saves what you covered.", 12, 400, "muted", "end")
    return s.render("Build mode",
                    "A dev plan becomes a learning plan; /learn:build turns learn mode on for a step; every prompt codes at your level with concept notes, predictions and deep dives; when the step is done a done-check and wrap-up run and learn mode turns off.")


def study_loop(t):
    s = Svg(880, 400, t)
    nodes = [("/learn:curriculum", "topics by dependency", "green"), ("/learn:teach", "one concept at a time", "green"),
             ("/learn:practice", "make failing tests pass", "green")]
    xs = [20, 230, 440]
    for (a, b, c), x in zip(nodes, xs):
        s.card(x, 60, 180, 80, c, a, None, [b])
    for x in xs[:-1]:
        s.arrow(f"M{x + 180},100 L{x + 206},100")
    # gate
    gx, gy = 650, 60
    s.card(gx, gy, 210, 80, "orange", "/learn:quiz", None, ["≥ 80% and every critical right"])
    s.arrow("M620,100 L646,100")
    s.arrow(f"M{gx + 60},{gy} C{gx + 40},6 330,6 320,56", "orange")
    s.text(515, 44, "not yet: revisit the gap", 12, 500, "muted", "middle")
    # build + reflect
    s.card(650, 200, 210, 80, "orange", "Build it", "in your project", ["its own workflow, untouched"])
    s.arrow(f"M{gx + 105},140 L{gx + 105},196")
    s.text(gx + 95, 174, "ready, whole phase", 12, 500, "muted", "end")
    s.card(330, 200, 250, 80, "green", "/learn:reflect", None, ["prediction vs result · new gaps"])
    s.arrow("M650,240 L584,240")
    s.arrow("M330,240 L110,240 L110,144")
    s.text(220, 232, "gaps become topics", 12, 500, "muted", "middle")
    # flashcards
    s.card(240, 318, 400, 64, "purple", "Flashcards", None, ["Leitner boxes · reviewed after 1 · 2 · 4 · 8 · 16 days"])
    s.arrow("M860,112 L872,112 L872,350 L644,350", "purple", True)
    s.arrow("M455,280 L455,314", "purple", True)
    s.text(463, 302, "lessons learned", 12, 500, "muted")
    s.text(864, 340, "quiz misses", 12, 500, "muted", "end")
    return s.render("The study loop",
                    "Curriculum, teach and practice lead to a quiz gate; failing sends you back to the gap, passing a whole phase means you build it in your project, then reflect; misses and reflections feed a spaced-repetition flashcard deck.")


def statuses(t):
    s = Svg(880, 368, t)
    w, y = 110, 150
    xs = dict(todo=20, learning=165, practised=310, ready=455, built=600, reflected=745)
    colors = dict(todo="line", learning="green", practised="green", ready="blue", built="purple", reflected="purple")
    def node(name, x, yy, c):
        s.box(x, yy, w, 40, c, rx=20, plain=(c == "line"))
        s.text(x + w / 2, yy + 25, name, 13.5, 600, "text", "middle", True)
    for n, x in xs.items():
        node(n, x, y, colors[n])
    node("claimed", 20, 40, "orange")
    order = list(xs)
    for a, b, lab in zip(order, order[1:], ["teach", "practice", "quiz", "ship", "reflect"]):
        s.arrow(f"M{xs[a] + w},{y + 20} L{xs[b] - 4},{y + 20}")
        s.text((xs[a] + w + xs[b]) / 2, y + 58, lab, 11.5, 500, "muted", "middle")
    s.arrow(f"M75,80 L75,146", "orange", True)
    s.text(83, 118, "quiz failed", 11.5, 500, "muted")
    s.arrow(f"M130,60 L510,60 L510,146", "orange")
    s.text(320, 52, "quiz passed", 11.5, 500, "muted", "middle")
    s.arrow(f"M475,146 C440,96 270,96 235,146", "orange", True)
    s.arrow(f"M330,146 C315,124 270,124 255,146", "orange", True)
    s.text(355, 92, "missed check", 11.5, 500, "muted", "middle")
    for x in (60, 205, 350):
        s.add(f'<path d="M{x},190 L{x},250" fill="none" stroke="{t["blue"]}" stroke-width="1.6"/>')
    s.arrow(f"M60,250 L655,250 L655,194", "blue")
    s.text(360, 270, "build mode: done-check right → built", 12, 500, "blue", "middle")
    s.text(20, 312, "Missed check: a failed quiz re-check, or a missed build-mode done-check. Statuses move back only on evidence.", 12, 400, "muted")
    s.text(20, 331, "Build mode also: a concept shown, or missed, goes todo → learning; claimed → built (right) or learning (missed).", 12, 400, "muted")
    s.text(20, 350, "A failed first quiz changes nothing, and built or reflected keep their status.", 12, 400, "muted")
    return s.render("Topic and concept statuses",
                    "Main path todo, learning, practised, ready, built, reflected. Self-assessed claimed goes to ready on a passed quiz or back to todo on a failed one. A missed check sends practised or ready back to learning. In build mode a right done-check moves todo, learning or practised straight to built.")


for name, fn in (("repo-model", repo_model), ("build-mode", build_mode), ("study-loop", study_loop), ("statuses", statuses)):
    for theme, t in THEMES.items():
        (OUT / f"{name}-{theme}.svg").write_text(fn(t), encoding="utf-8", newline="\n")
