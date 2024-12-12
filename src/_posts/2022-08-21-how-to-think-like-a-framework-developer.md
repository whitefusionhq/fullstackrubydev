---
title: How to Think Like a Framework Developer
subtitle: When implementing a specific feature for a specific application, you're mainly concerned with the What. Yet when building a framework, you're mainly concerned with the Why and the How.
categories:
- The Art of Code
author: jared
image: "/images/posts/blocks-everywhere.jpg"
image_hero: "/images/posts/blocks-everywhere.jpg"
image_credit:
  url: https://unsplash.com/photos/kn-UmDZQDjM
  label: Xavi Cabrera on Unsplash
---

I've always really enjoyed working on frameworks. Not even libraries per se, but _frameworks_.

I worked on a PHP/JS frontend framework called [Xajax](https://web.archive.org/web/20080424113056/http://xajaxproject.org:80/) back in the early 2000s, and then briefly out of that spawned a Rails-like framework called [Willowgarden](https://web.archive.org/web/20061229193905/http://www.willowgarden.org/) for the then-new PHP 5.

Once I officially switched to **Ruby on Rails**, I never looked back. But one thing that was a bit of a bummer after a while was missing that feeling you get when you're building a framework.

Having now worked a couple years on [Bridgetown](https://www.bridgetownrb.com), I'm so thankful that I get to work on frameworks as part of my job. But more than that, I've discovered over the years that you can learn to think like a framework developer even when you're _not_ directly programming a framework.

### The Why

The first question a framework developer always asks when evaluating a new idea, a feature request, an improvement, a refactoring, is **why**. I don't mean a reflexive why, like "why should we bother looking into this, gosh!" I mean a long-term, _justifying_ why which is chiefly concerned with the long-term health of the project.

When you're just banging out feature after feature for a specific application, it's easy to get lost in the daily grind. Another ticket on the board. Another comment on an issue. Another meeting. Another sprint. There's often little time to reflect on the rationale of the feature you're working on, how it might relate to other features already in flight, who is responsible for ensuring the feature's stability over time, the downsides of adding the feature (there are always downsides to every new feature), how to document gotchas or architectural dragons lurking due to how the feature gets implemented, etc., etc. And do you even have the time or authority to investigate features you can deprecate or _remove_? (**lol** 😂)

When you're working on a framework, you **must** ask yourself these questions. Architectural integrity, documentation, maintainability, health of the project as a whole—those aren't secondary concerns compared to feature implementation. _Those ARE the concerns!_ Feature implementation is subservient to the big picture, and sometimes it's perfectly fine—desirable even–to say no.

I believe most applications would be better served if they were run more like a framework. It might seem at first like the velocity slows _way_ down, and the pace of feature rollout slows to a trickle. But over time, I've become convinced the quality and the stability of the software _and_ the team building it is greatly increased.

(I also believe most applications would be better served if they were run like an open source project even if they aren't open source, but that's a conversation for another day…)

### The How

The other main question a framework developer must ask when evaluating an addition or change is **how**. Now that might seem silly on the face of it. How?!?! By opening your code editor and writing some code! That's how! (**Duh.** 😝)

What I mean though is how are you going to implement that new feature or make that change _in the "best" way possible_ given a wide variety of potential solutions all involving pros and cons which could have long-lasting ramifications for the project as a whole.

When I'm in full-blown "framework" mode, I'll spend a great deal of time toying with the design of a single API. I'll try out different method names, different class names. I'll split apart this object from that object. I'll combine some objects together. I'll experiment with mixins. I'll consider metaprogramming. I'll try using the API as a "consumer" and see how it feels. I'll pseudocode a new approach in the consuming app, then backport that into the framework. It might take me hours, days—even weeks—just to end up with what might be in the end simply a few lines of code.

**Because it has to feel RIGHT.**

It's hard to change a framework once a bunch of people already depend on it. You hate to have a horde of angry developers coming after you with pitchforks and torches just because you renamed a method or removed a class. So it's really, _really_, **REALLY** important you get things right _before_ you commit them. It requires a lot of care and finesse. Sometimes you end up having to scrap an entire PR and start over from scratch.

How many app projects have you been on where the team regularly comes together, evaluates a speculative approach, wonders "hmm, not sure if this feels right", then decides to completely scrap it and start over? _Yeah, me neither._ Maybe when you're evaluating a brand-new library or framework or build tool. But day-to-day features? It's rare indeed.

But again, my assertion is that most applications would be better served if they were run more like a framework—more tasks that are speculative, concerned primarily with architectural integrity, fully malleable, ready to be tossed out if it feels smelly or overly complex. Because you're not just building "a pile of features" or "a bag of UI". You're building a **holistic blueprint** for comprehensible interactivity and data processing. You need to be able to zoom out to the 20,000 foot level at a moment's notice and intuitively "grok" how all the component parts fit together and why they're there and how they operate without too much friction or overlap. And if you can't do that, I can almost guarantee you your users won't be able to do that either.

----

<aside markdown="1">
As an appropriate aside, this is why I enjoy programming **Ruby** above all else. The Ruby language makes it pleasurable for me to gain an intuitive sense of a fullstack system and how everything operates. I enjoy reading Ruby almost as much as I enjoy writing it! I wouldn't say that about many other languages. Most programming languages look fiddly and ugly to me, as if it's just line after line of brute-force trying to get the computer to do its tedious little computer-y things. I don't want that. 😅 I want high-level patterns and paradigms and DSLs and declarative syntax and all the rest. Put more responsibility on the computer to figure out the little details under the hood. /rant
</aside>

----

### The Who

Depending on the project you're working on, your experience level, and the dynamics of your team, it may actually be rather challenging to _rise_ to the level of "framework" developer within the context of your job. You may experience some pushback. You may be thought of as pedantic, even grumpy. I had to apologize just the other day for repeatedly stressing the same points over and over about an architectural concern I had to other folks in the meeting. It was frustrating to feel like I could see something obvious that we'd all need to come to a clear consensus on before moving forward, yet seemingly nobody else was visualizing that concern.

All I can tell you is: it's worth it to put in that extra effort. Eventually people _will_ notice. And then instead of simply throwing features over the wall to you and expecting you to blandly implement them, they'll start asking you **questions**. And you'll be able to ask them **questions** back. And now you have a **dialog** going about how to improve the long-term quality of your software and your team.

**It's a beautiful thing.** {%= ruby_gem %}