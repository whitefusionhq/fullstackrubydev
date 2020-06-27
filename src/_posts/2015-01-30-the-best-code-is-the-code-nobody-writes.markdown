---
title: The Best Code is the Code Nobody Writes
subtitle: Don't waste time and effort building stuff that's easy to break and hard to remove. Go the extra mile and get it done right.
date: '2015-01-30 16:45:28'
categories:
- The Art of Code
layout: post
author: jared
---

_Update 2: Wow! I didn't expect this to make the rounds on Twitter. Thanks everyone for the links!_

<blockquote class="twitter-tweet" lang="en"><p>I agree with <a href="https://twitter.com/jaredcwhite">@jaredcwhite</a>: The Best Code is the Code Nobody Writes <a href="http://t.co/6h9QRZA18D">http://t.co/6h9QRZA18D</a></p>&mdash; pete higgins (@pete_higgins) <a href="https://twitter.com/pete_higgins/status/566151167961354240">February 13, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" lang="en"><p>&quot;The best code, next to the code nobody writes, is the code written carefully and deliberately, with humility.&quot;&#10;&#10;<a href="http://t.co/cMBX3aR9J0">http://t.co/cMBX3aR9J0</a></p>&mdash; The Decider (@kerrizor) <a href="https://twitter.com/kerrizor/status/565536250606927875">February 11, 2015</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

_Update: [a lively conversation on the Ruby Subreddit](https://www.reddit.com/r/ruby/comments/2ujuak/the_best_code_is_the_code_nobody_writes/) ensues!_

----

_Note: the following advice is applicable to any programmer but particularly relevant to the freelancer/contractor and Ruby on Rails programmers._

There are many metrics that people use for determining what is good code vs. bad code. Things like:

* Readability
* Maintainability
* Test Coverage
* Adequate Commenting (but not Over-Commenting)
* Use of Applicable Design Patterns
* DRY (Don't Repeat Yourself)
* etc.

There are many more I'm sure you could think of to add to the list. Here's another metric I think is very important to consider for judging code quality:

* Doesn't Exist

Think about it. Code that doesn't exist is the most readable code, because _nobody has to read it_. Code that doesn't exist is the most maintainable code, because _nobody has to maintain it_. Code that doesn't exist is the most easily tested, because _nobody has to write and maintain test suites to validate that code_. And so forth.

You may think I'm being flippant, but **heed my words**, young padawan: I have worked on many a software project in my day that was full of spaghetti code, deadends (aka code that wasn't in active use but still in the codebase), untested code, and even semi-duplicated code because multiple people implemented similar functionality more than once. And, I regret to say, many of those mistakes were ones I made as well.

### If you build it, you are stuck with it.

One of the major challenges I've run into is dealing with clients who are unfamiliar with programming best practices and the concept of technical debt. In their minds, building a new software feature is just like painting a picture or constructing a chair. You work on some stuff, and then it's done, and then you look at it and see if you like it.

But as we all know, software doesn't work like that. Nearly every single line of code you write ends up with a lifecycle and an impact that goes far beyond the one feature you're working on.

* "Oh, I'll just add this new method to my User model."
* "Oh, I'll create a new controller to handle this use case."
* "Oh, I need a new service object to process all these steps."
* "Hmm, we're going to need XYZ gem for that piece of the puzzle."

And then, after adding new methods to User and creating new controllers and placing yet another service object in a growing folder of modules and including those three new gems in your Gemfile (not to mention adding new database tables and columns on existing tables), the client decides to delay the feature and work on another feature. Is this a temporary delay or a permanent one? Who knows!

Now you have a ton of code strewn all over your codebase, gems you don't need, and a bloated database. What do you do? Spend hours to carefully remove all of the changes you made? Sorry, clients don't really like spending money for you to do things that don't result in another fancy demo at the next executive meeting. So you do what a lot of programmers (myself included) typically do: leave it. Sure, you might comment out a route or remove a button in a view, but that's it. The "feature" remains, lurking beneath the surface like a hideous creature, just waiting to leap out and bite a chunk out of you or another programmer when you later come along refactoring code and cleaning up cruft.

### Just Say No.

If you're lucky enough to work in a company with a culture of software engineering excellence, these issues may be relatively rare because everyone is aware of them and the business side understands and respects the concerns of the software team. But if you are a contractor working with a variety of clients—some of whom may know next to nothing about the discipline of programming—you simply don't have that luxury. This means you are going to have to be very careful to set expectations up front.

Clients need to be aware that your job as a programmer isn't simply to build what they say they want. Your job is to create a healthy codebase and grow it slowly and deliberately, always being mindful that at some point in the future, you might, God forbid, be hit by a bus (or fired, or leave for greener pastures...) and someone else is going to have to figure out what in tarnation is going on with your code. Your job, in many cases, is to tell the client **no**.

* Don't start building feature Z when features X and Y are still half-baked.
* Don't build features B and C until you remove the code for feature A because it's no longer in use.
* Don't redo feature E with a new design until the underlying code is refactored so that it'll be much easier to update and tweak later on.

### If you do need to write code (shock! horror!), keep it as self-contained as possible.

There's a concept in software security to keep the "surface area" of a possible attack vector as minimal as possible. The less accessible a portion of code is to the "outside world", the less likely it can be used for a malicious act.

We need to be vigilant to reduce the surface area of new features. When you're figuring out how to go about writing code to support new development, think in terms of small, modular components that are easily changed or removed in the future if the feature is no longer required or if the requirements change drastically.

* Don't add that new method to the User model. Use [Concerns](https://signalvnoise.com/posts/3372-put-chubby-models-on-a-diet-with-concerns) (aka Mixins), or separate POROs (Plain-Old-Ruby-Objects), to implement the new functionality.
* In fact, don't put a ton of new code in the "top-level" places of architecture (aka don't add a giant new action to a controller, don't add a ton of new markup to a view). Use objects, modules, and partials to keep new features relatively self-contained. You might even make it a habit to namespace your objects. For example, on a recent project, I created a folder in `app/models` called `social_network` and all my objects are namespaced like so: `SocialNetwork::Timeline`, `SocialNetwork::Activity`. I then used a concern to keep the parts of the User model that interact with the `SocialNetwork` object graph sequestered in its own file.
* Be very careful when considering adding new gems to a project. The more gems you have, the harder it will be to do upgrades in the future because of dependency issues and other factors (some gems stop being maintained, others have weird bugs nobody bothers to fix, etc.). To riff off this post title, **the best gem is the one you don't install!**
* Finally, consider writing a simple wrapper around huge pieces of new technology. For example, if you decide to use a third-party web service or a library to manage images, or search, or something major, you might want to avoid interfacing directly with that in your app code. What if you decide to switch to another search engine? What if your third-party web service shuts down? Now you're stuck having to rewrite bits of code all over your entire codebase. But if you use a wrapper, all you need to do is rewrite the wrapper and your overall app code can remain relatively intact. Wrappers are also more easily tested, because you can simulate the data transfer between the wrapper and the service/library.

### Nobody can blame you for code that doesn't work if the code doesn't exist.

I'll close on a somewhat cynical note, but it's absolutely true. Code that doesn't exist is bug-free and never causes any problems. Now it's true that bugs in existing code can be due to "missing" code (aka the code to validate that input value is missing). But missing code and non-existing code are slightly different. Missing code in those instances is usually just existing code that was badly written. Avoid writing `object.value + 1` or `object.title.upcase`  when you can write `object.value.to_i + 1` or `object.title.try(:upcase)` (unless of course you've already vetted your variables in some way).

_Non-existing code is the code you've chosen not to write._ Far too many programmers lack the foresight or the courage to chose not to write code. Or maybe their ego is tied up in the clever solutions they can come up with or the lines of code they commit to GitHub every day. Resist these temptations! And always remember this:

**The best code, next to the code nobody writes, is the code written carefully and deliberately, with humility.** The client could be wrong. You could be wrong. The project could end up completely different in the near future. So don't waste time and effort building stuff that's easy to break and hard to remove. Go the extra mile and get it done right.

----

_Additional reading: [The Best Code is No Code At All](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/) and [Code is Our Enemy](http://www.skrenta.com/2007/05/code_is_our_enemy.html)_

