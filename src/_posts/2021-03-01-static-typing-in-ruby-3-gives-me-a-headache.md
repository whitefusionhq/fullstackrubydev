---
title: "Static Typing in Ruby 3 Gives Me a Headache (But I Could Grow to Like It)"
subtitle: It kinda sorta works—with several asterisks. Hence the reason it took me so long to even write an article about Ruby 3 typing. I think I'm onboard with where this is all headed, but we have a ways to get there.
categories:
- Ruby 3 Fundamentals
author: jared
image: "/images/posts/puzzle-pieces.jpg"
image_hero: "/images/posts/puzzle-pieces.jpg"
image_credit:
  url: https://unsplash.com/photos/3y1zF4hIPCg
  label: Hans-Peter Gauster on Unsplash
published: true
---

I've had a doozy of a time writing this article. See here's the thing: I've been a Ruby programmer for a _long_ time (and a PHP programmer before that). My other main language exposure just before becoming a Rubyist was Objective-C. That did require putting type names before variable or method signatures, but also Objective-C featured a surprising amount of duck typing and dynamism as well (for better or worst…Swift tried to lock things down quite a bit more).

But then there's JavaScript / TypeScript.

My relationship with JavaScript is…complicated, at best. I actually write quite a lot of JavaScript these days. Even more to the point, a lot of the JavaScript I write is in the form of TypeScript. I don't hate JavaScript. The modern ESM environment is quite nice in certain ways. Certainly an improvement over jQuery spaghetti code and callback hell.

But TypeScript is simply a bridge too far for me. I use it because a project I'm on requires it, but I don't enjoy it. At times I hate it so much I want to throw my computer across the room. However, I can't deny its appeal in one respect: those Intellisense popups and autocompletes in VSCode are very nice, as well as the occasional boneheaded mistake it warns me about.

What does any of this have to do with Ruby? I'm getting there. Bear with me just a wee bit longer, I implore you!

### Using TypeScript Without Writing TypeScript

One interesting trend I've started to see as of late (at least on Twitter) is taking what's cool about TypeScript type checking, Intellisense, and all the rest…but applying it in such as way that _you're not actually writing TypeScript, you're writing JavaScript_. What you do is use **JSDoc** code comments to add type hints to your file (but not as your actual code). Then use a special mode of TypeScript type checking which will parse the JSDoc comments and interpret them _as if you'd written all your type hints inline as actual code_. [Here's a fascinating article all about it.](https://gils-blog.tayar.org/posts/jsdoc-typings-all-the-benefits-none-of-the-drawbacks/)

If this is starting to sound just a wee bit familiar to you, O Rubyist, it should—because **that's exactly what it's like using YARD + Solargraph** with Ruby.

### Improving the Ruby Editing Experience

Right now, I'm in the middle of an extensive overhaul of the [Bridgetown](https://www.bridgetownrb.com) project to add [YARD documentation comments](https://yardoc.org) to all classes and methods. With the [Solargraph gem](https://solargraph.org) + VSCode plugin installed, I get extensive type descriptions and code completion with a minimal amount of effort. If I were to type:

```ruby
resource.collection.site.config
```

It knows that:

* `resource` is a `Bridgetown::Resource::Base`
* `collection` is a `Bridgetown::Collection`
* `site` is a `Bridgetown::Site`
* `config` is a `Bridgetown::Configuration`

And if I were to pass some arguments into a method, it would know what those arguments should be. And if I were to assign the return value of that method to a new variable, it would know what type (class) that variable is.

**Livin' the dream, right?** But the one missing component of all this is strict type checking. Now the Solargraph gem actually comes with a type checking feature. But I've never used it, because I feel like if I were to go to the trouble of adding type checking to my Ruby workflow, I'd want something which sits a little closer to the language itself and is a recognized standard.

That's where Ruby 3 + Sord comes in.

### Ruby 3 + Sord = The Best of Both Worlds?

[Sord](https://github.com/AaronC81/sord) was originally developed to generate _Sorbet_ type signature files from YARD comments. Sorbet is a type checking system developed by Stripe, and it does not use anything specific to Ruby 3 but is instead a custom DSL for defining types. However, Sord has recently been upgraded to support generation of **RBS** files (**R**u**b**y **S**ignature). This means that instead of having to write all your Ruby 3 type signature files by hand (which are standalone—Ruby 3 doesn't support inline typing in Ruby code itself), you can write YARD comments—just like with Solargraph—and autogenerate the signature files.

Once you have those in place, you use a tool called [Steep](https://github.com/soutaro/steep), which is the official type checker "blessed" by the Ruby core team. Steep evaluates your code against your signature files and provides a printout of all the errors and warnings (similar to any other type checker, TypeScript and beyond).

**So here's my grand unifying theory of Ruby 3 type checking:**

* You write YARD comments in your code.
* You install Solargraph for the slick editor features.
* You install Sord to generate `.rbs` files.
* You install Steep to type check your Ruby code.

Nice theory, and _extremely similar_ in overall concept to all the folks writing JavaScript yet using JSDoc to add "TypeScript" functionality in their code editors and test suites.

**Unfortunately the reality is…not quite there yet.** It kinda sorta works—with several asterisks. Hence the reason it took me so long to even write an article about Ruby 3 typing…and I'm not even sharing examples of _how_ to do it but instead my thought process around _why_ you'd want to do it and what the benefits are relative to all the hassles and headaches.

In my opinion, a type checking system for Ruby is useless unless it's _gradual_. I want everything "unchecked" by default, and "opt-in" specific classes or even methods as we go along. While YARD + Solargraph alone gives you this experience, adding Sord + Steep into the mix does not. There doesn't currently seem to be a way to say _only generate type signatures for this file or that and only check this part of the class or that_. At least I wasn't able to find it.

In addition, all this setup is confusing as hell to beginners. There's no way I can take someone's fresh MacBook Air and install _Ruby + VSCode + Solargraph + Sord + Steep (perhaps also Rubocop for linting)_ and get everything working perfectly with a minimum of headache and fuss. I myself have seen Solargraph and/or Rubocop support in VSCode break several times for unclear reasons, and it's been a PITA to fix.

So here's my crazy and wacky proposal: **This should all be one tool.** 🤯 I want to sit down at a computer, install Ruby + AwesomeRubyTypingTool, and _it all just works_. That's the real dream here. I mean, TypeScript is TypeScript. It's not a bunch of random JS libraries you have to manually cobble together into some kind of coherent system. TypeScript—for all its gotchas and flaws—is a known quantity. You might even say _it just works_—at least in VSCode. (No surprise there: both VSCode and TypeScript are Microsoft-sponsored projects.)

I have no idea what it would take for the Ruby core team and the other folks out there building these various tools to get together and hash this all out. But I really hope this story gets a hell of a lot better over the coming months. Because if not…I might just kiss Ruby 3 typing goodbye.

_But not Solargraph._ You'd have to pry that out of my cold dead hands. 😆 {%= ruby_gem %}