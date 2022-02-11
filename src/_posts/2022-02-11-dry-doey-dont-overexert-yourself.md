---
title: What's Better Than DRY? DOEY! (Don't Over-Exert Yourself)
subtitle: When I'm in my "flow state" as a programmer, what I'm constantly doing is finding ways to eliminate redundancies, learning to recognize that entire subsystems as a whole can be made entirely redundant if I simply took the time to search for higher-level abstractions.
categories:
- The Art of Code
author: jared
template_engine: none
rainbow_hero: true
image: /images/posts/beach-scene.jpg
image_hero: /images/posts/beach-scene.jpg
image_credit:
  url: https://unsplash.com/photos/HGubiUXJoa4
  label: Benjamin Massello on Unsplash
---

It never ceases to amaze me how much work programmers create for themselves. Time and again I hop onto DuckDuckGo to search for a particular answer to a problem, or a tool to help me accomplish a task, only to find article after article and readme after readme riddled with overly-complicated, brute force, verbose solutions to what are ostensibly simple problems.

**Question:** how do I convert JSON to YAML?

**Verbose Answer:** you install these packages and then you download this script and then you modify these three variables and then you pray to the open source gods and then you sign up for this service and then you connect to that API and then you…

**Real Answer:** you don't need to do anything…_JSON is valid YAML_. 😅

### I'm Actually Quite Lazy

So here's the deal: I hate work. 😜 I'd much rather go outside and take a walk. So whenever I'm trying to solve a big, thorny programming problem, what I'm *not* going to do is try a linear A, then B, then C, then D, then E approach to getting it to work. Because I know from experience that thinking in that manner actually creates far *more* work down the road. And I'm lazy, remember? So I want to get less work done in the long run. **Way less work.**

[According to Wikticionary](https://en.wiktionary.org/wiki/brute_force), "brute force" is a method of computation wherein the computer is let to try all permutations of a problem until one is found that provides a solution, in contrast to the implementation of a more intelligent algorithm. We can also apply that concept to our own "human computation" as we're programming: just taking wild stabs in the dark to guess a solution to a problem, and upon the first working demonstration, well **there you go!** **Problem solved.**

That's really not the ideal way to go about things at all.

### Eliminating Redundancies

When I'm in my "flow state" as a programmer, what I'm constantly doing is finding ways to eliminate redundancies. This goes far beyond DRY (Don't Repeat Yourself), which is a generally useful concept but typically only thought of as applying to small code blocks. "Hey, these few lines here are basically the same as these few lines over there. Let's extract them out to a single function! Cool, cool."

I find that application of DRY to be far less compelling than one where you can recognize that entire subsystems of your application as a whole can be made entirely redundant if you simply took the time to search for _higher-level abstractions_.

Sometimes these higher-level abstractions are missed on codebases because multiple people are working in silos. Programmer A works on a feature over here. Programmer B works on a feature over there. At first glance neither feature seems related. But to a well-trained eye looking at the sales pitch for both features, it becomes apparent that most of the code could be conceptually shared between the two features. They're really not two features at all. They're **one feature**, _expressed in slightly different ways depending on the context_.

And that's what I mean by eliminating redundancies in code. What if your application with 50 features could actually be built with only 25 features, each slightly more malleable at run-time to provide _the illusion_ of 50 features? What if you could whittle that down even further? What if you could extract some of the features' lower layers to a shared library? What if you could use someone else's battle-hardened library instead?

Measuring your application codebase's health by LoC is never wise. But I believe looking at _the number of new lines of code added_ in each PR is very important. If PR after PR comes up for code review and nearly everything is "new code"—unless this is literally a brand-new application, something has gone terribly wrong. The majority of your PRs should be attempting to refactor, to streamline, to eliminate redundancies. Programmer works on Feature B, realizes it's not that different from Feature A, so her PR for Feature B actually redoes Feature A so they both share as much in common underneath a higher-level abstraction.

Remember, [the best code is the code nobody writes](https://www.fullstackruby.dev/the-art-of-code/2015/01/30/the-best-code-is-the-code-nobody-writes/). "No code" is bug-free, infinitely fast, and incredibly easy to maintain. "No code" doesn't need to be tested or understood _because it doesn't exist_. The next best thing to "no code" is "worthy code". The more verified impact each single line of code can have within your overall application architecture, the better.

### But I Don't Know What Other Code Has Already Been Written!

One possible objection to this way of thinking might be that on sufficiently-large codebases, multiple programmers won't have any idea what other people have already written or how those subsystems work exactly. So someone can be forgiven for pushing up a PR that's basically just new code they've written to get something done.

**I don't subscribe to that philosophy.**

Either **(a)** that programmer needs to spend more time _simply reading code_ and _learning_ how all of the different components and subsystems and configurations and layers of the application function and why they're there, or **(b)** the code review process needs to incorporate an "architectural review" step to ensure PRs have taken possible refactoring into account, rather than just offering yet additional "append-only" code blocks.

### That Sounds Like a Lot of Work! I Thought You Were Lazy?!

A cursory examination of the concepts above might lead you to believe all this reading and refactoring and high-level architectural review of codebase concepts is a ton of extra work. Much easier to simply sit down at your code editor with a blank file, write some stuff, write some tests, verify the damn thing works, and call it a day.

**Wrong!**

That approach only works when you have a simple, greenfield application. As your codebase grows larger and more sophisticated, writing code in that manner eventually leads to "[the big ball of mud](https://en.wikipedia.org/wiki/Big_ball_of_mud)" architecture, also known as "spaghetti code". Unfortunately, I can't begin to count how many tutorials I've seen (DEV is sadly riddled with them) which present code which is obviously spaghetti in nature, yet provide a sort of "copy-and-paste these 20 files into your project and you're done!" appeal to newbies.

Listen, _I understand that appeal_. You don't want to have to spend five hours crafting the perfect software architecture for your specific problem domain. You just want to download the "Gatsby-React-Tailwind-Firebase-Stripe-Netlify" starter kit, stuff a wad of JSON here and JSX there, copy-n-paste some random components off of StackOverflow, and boom you have a website.

Unfortunately the quality of that website's code will be hot garbage. 😬 Might not matter to you now. But down the road, **it's going to bite you in the ass**.

### Embrace DOEY

By taking the time to carefully, deliberately, intentionally write high-quality code from the start, understanding your problem domain while avoiding redundancies, expressing features in higher-level abstractions, utilizing battle-tested and well-crafted libraries/frameworks based on "first principles", staying away from "new hotness" tools which make for cool tutorials but are a disaster to maintain over the long term—you begin to reap the benefits of **DOEY**. Soon, while other people are spending hours, days, even weeks **wrestling with brittle codebases** which are hard to intuitively understand and nearly impossible to refactor, you are **enjoying your outside walk in the sun** because _you already shipped three new features yesterday._

**All of that upfront work paid off. Now you get to be lazy. Stop to smell the roses. Life is good.**