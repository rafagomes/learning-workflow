# The learning workflow

## The problem

Learning while you work usually looks like this: you hit something unfamiliar, ask for an explanation, nod along, and move on. A week later it's gone, and you can't tell what you actually understand from what you only recognise. The opposite extreme, a course, teaches things in an order that has nothing to do with what you need next.

This workflow sits between the two. It teaches **what your next piece of work needs, in the order you'll need it**, and it checks that you can *do* each thing, not just that you've read about it.

## Why a separate learning repo

Learning material is personal, exploratory and full of half-right attempts. Project repos are shared, reviewed and must stay clean. Keeping them apart:

- lets you study freely without polluting a team's history or exposing your gaps in a work repo;
- lets one subject draw on several projects at once: a pattern met at work can be practised on a side project;
- keeps the lessons with you when you leave a job or archive a project.

| Repo | Holds | Visibility |
|---|---|---|
| `learning-workflow` (plugin) | The method: skills, templates, docs | Public |
| Learning repo, one per subject | Your curriculum, lessons, exercises, deck, reflections | Private by default |
| Projects | Real code and data, unchanged | As they were |

The learning repo reads projects; nothing reads the learning repo. Anything you learn that should reach a project is rewritten there through that project's own workflow (spec, branch, PR, review).

## Two ways to learn

| | Build mode | Study loop |
|---|---|---|
| When | You have real work to do now | Before the work, or for a deep concept |
| Where | In the project session | In the learning repo |
| Driven by | A learning plan linked to the dev plan (`/learn:plan`) | A curriculum (`/learn:curriculum`) |
| Teaching | Short concept notes only when a decision needs them; deep dives during background waits | Full lessons with labs |
| Checking | Predictions before runs; done-check when the step is done | Exercises with tests; quizzes |
| Shared | One learning repo, flashcard deck, `PROGRESS.md` | ← same |

Verdict: start with build mode for most work; reach for the study loop when build mode flags a `deep` concept or you're new to the subject.

### Build mode

```mermaid
flowchart TD
    A["Dev plan in the project<br/>(spec, roadmap, issue, goal)"] --> B["/learn:plan<br/>per step: concepts (known/new),<br/>level, done-check"]
    B --> C["/learn:build step<br/>due flashcards, mode on"]
    C --> D["Keep prompting: code at your level<br/>▸ concept notes only when needed<br/>predict before runs · idle-time deep dives"]
    D --> E{"Step done?<br/>(you say so / PR opens)"}
    E -- no --> D
    E -- yes --> F["Done-check: 3–5 questions<br/>on what you built"]
    F --> G["Wrap-up: builds/ log, flashcards,<br/>plan + PROGRESS updated, mode off"]
    G --> C
    D -. "deep concept" .-> T["/learn:teach later"]
```

**Hands-on levels.** `claude` (Claude codes and explains the decisions that matter), `adaptive` (Claude writes the plumbing and leaves you the core with a marked gap), or `you` (you code, Claude coaches). There's a default per subject, and any step or prompt can override it.

**Why it works.** Concepts arrive exactly when a decision depends on them (just in time). Predictions before runs exercise the generation effect. The done-check is retrieval practice on your own code. Misses feed the same spaced-repetition deck.

## The study loop

```mermaid
flowchart TD
    A["Source: plan, spec, design doc, or just a goal"] --> B["curriculum"]
    B --> C["teach"] --> D["practice"] --> E{"quiz: ready?"}
    E -- no --> C
    E -- "yes, whole phase" --> F["build it, in the project"]
    F --> G["reflect"] --> B
    E -.-> H["review flashcards, most days"]
    G -.-> H
```

1. **Curriculum.** The source is split into topics ordered by dependency, each tied to the phase that needs it, each with 2–3 observable "ready when" abilities. A short self-assessment skips what you already know (it gets a quiz instead of a lesson).
2. **Teach.** One concept at a time, with a question after each step. Before every lab run you predict the result. The lesson file is written as you go, so it records the explanation that actually worked for you.
3. **Practice.** Exercises with stubs and failing tests. The tests are checked against a hidden reference solution first, so a green run means you're right. Hints come one rung at a time; the solution only if you ask.
4. **Quiz.** Adaptive, one question at a time, mixing explain, predict-the-output, spot-the-bug and choose-and-justify. Ready means ≥ 80% **and** every critical question right.
5. **Build.** In the real project, with its normal process. The plugin stays out of it.
6. **Reflect.** What you predicted, what happened, why they differed, what to do differently. New gaps become new topics.
7. **Review.** Misses and key ideas become flashcards, reviewed on a Leitner schedule.

## The principles, and the evidence behind them

| Principle | How the skills apply it | Why |
|---|---|---|
| **Learn just in time** | Topics come from the plan you're about to execute; in build mode, a concept appears when a decision needs it | Motivation and transfer are highest when the use is immediate |
| **Predict, then run** | Every lab and many quiz items ask for a prediction first | Generating an answer before seeing it (the *generation effect*) and confronting a wrong prediction both improve retention |
| **Retrieval over rereading** | Quizzes, flashcards, "check" questions | *Retrieval practice* (the testing effect) beats rereading for long-term retention |
| **Spaced repetition** | Leitner boxes at 1, 2, 4, 8, 16 days | Spacing reviews out beats massing them (the *spacing effect*) |
| **One concept at a time** | Socratic pacing, a check after each step | Limits cognitive load; misconceptions are caught early |
| **Mastery gates** | "Ready when" + quiz threshold before building | Moving on with gaps compounds them |
| **Reflection** | Prediction-vs-result after every build | Turns experience into transferable lessons |
| **Numbers come from code** | Labs print what the lesson quotes | You never memorise a figure the tutor made up |

Further reading: Brown, Roediger & McDaniel, *Make It Stick* (2014); Dunlosky et al., "Improving Students' Learning With Effective Learning Techniques", *Psychological Science in the Public Interest* (2013).

## Statuses

Topics (study loop) and concepts (build mode) share one status set. Plan **steps** have their own: `todo` → `in progress` → `done`. Statuses move back only on evidence: a failed quiz or a missed done-check question sends a topic or concept back to `learning` (a failed `claimed` quiz back to `todo`), with a flashcard. In build mode, a concept answered correctly in the done-check becomes `built`; one shown but not checked becomes at least `learning`; `built` and `reflected` concepts keep their status.

```mermaid
stateDiagram-v2
    [*] --> todo
    [*] --> claimed: self-assessed
    claimed --> ready: quiz passed
    claimed --> todo: quiz failed
    todo --> learning: teach
    learning --> practised: practice (all tests pass)
    practised --> ready: quiz passed
    ready --> built: shipped in a project
    built --> reflected: reflect
    todo --> built: build mode, done-check right
    todo --> learning: build mode, shown or missed
    learning --> built: build mode, done-check right
    claimed --> built: build mode, done-check right
    practised --> built: build mode, done-check right
    claimed --> learning: build mode, done-check missed
    practised --> learning: build mode, done-check missed
    ready --> learning: quiz failed later or done-check missed
```

## Reproducibility

- Labs are self-contained programs in the repo's toolchain, with pinned dependencies and seeded data.
- Project citations carry a commit sha, so a lesson still points at the code it described after the project moves on.
- Every skill ends with a conventional commit, so the history is your learning log.
- `PROGRESS.md` is the one-page answer to "where am I?".
