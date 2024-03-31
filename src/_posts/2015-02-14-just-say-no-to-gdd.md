---
layout: post
title: "Just Say No to GDD: Guilt-Driven Development"
subtitle: Ruby on Rails. Finally a language and a methodology of writing apps that felt simple, clean, fast, and maintainable. But then a few years went by. New updates to Rails. New gems. New client-side Javascript frameworks. New server deployment best practices. New things to learn Every. Darn. Minute. Suddenly, writing Rails apps didn't feel so much fun anymore. It felt difficult. And I felt guilty.
categories:
- The Art of Code
author: jared
---

When I finally decided to ditch PHP back in 2006 and learn Ruby on Rails, one of the main reasons was that PHP just wasn't fun anymore. I'd previously built my own custom web framework using the latest hotness of PHP 5 soon after it was first released. But then Zend announced their official web framework, and I figured my little project didn't stand a chance. (Interestingly, Zend Framework didn't end up being that huge of a deal and a lot of PHP programmers are using other frameworks. But I digress.)

I didn't like how Zend was doing things when I looked over the initial docs, so I decided just to jump ship and try RoR. My own framework was already somewhat influenced by Rails, so I figured the learning curve wouldn't be too high once I got the hang of writing Ruby code.

Boy oh boy, did I fall in love with both Ruby & Rails. I'd never had so much fun programming in my life. Finally a language and a methodology of writing websites and webapps that felt simple, clean, fast, and maintainable.

But then a few years went by. New updates to Rails. New tools. New gems. New philosophies. New testing frameworks. New client-side Javascript frameworks. New server deployment best practices. New things to learn Every. Darn. Minute.

Suddenly, writing Rails apps didn't feel so much fun anymore. It felt difficult. And I felt guilty. Guilty I'm not writing enough tests (and not using the right testing gem). Guilty I'm not setting up my servers right. (Darn it all, why even set up servers? Use Heroku, right? That's what all the cool kids use.) Guilty I'm relying on server-backed HTML views. Shouldn't I learn HAML anyway? Skip that, just use JSON on the frontend and Handlebars on the front end. Actually, why even use Rails for a simple JSON API? Just use Node.js and be done with it. Bye-bye Ruby.

What?!?! This is madness! I left the world of PHP and learned Ruby (and Rails) for specific and valid reasons, reasons that simply hadn't stopped being relevant for producing web software. Certainly competiting technologies might have an edge in one area or another. But my criteria for evaluating languages and frameworks hadn't changed.

Is it fun to read, fun to write? Is it concise and easy to understand? Does it embrace the way the web works or does it try to do something weird or non-standard? Does the community and the tooling/best practices/packages/etc. seem to be top-notch?

In all of those areas, I remain quite pleased with Ruby on Rails, and in one particular area (client-side interactivity or "rich UI" instances), I have found an amazing tool in Opal, a Ruby-to-JS transpiler with which I have developed (what, again?) my own custom front-end framework. Actually, it's barely a framework...more a straightforward way to organzine code and objects in an MVC pattern suitable for client-side development. YMMV. If you want to stick with popular JS client frameworks, knock your socks off.

_**Editor's Note**: Since I wrote this article, ES6+ took off along with Webpack, Stimulus, and LitElement, so I no longer use Opal. But hat's off to you if you do!_
{:.mx-6}

My point is this: after a period of falling prey to that terrible practice known as GDD: Guilt-Driven-Development, I finally snapped out of it and realized that the only person forcing me to look at tools and technologies I simply don't want or need was myself. As long as there's a job open somewhere for a Rails developer, I'm good to go. And I don't need to learn every single darn gem on the planet. All I need to learn is what I need to learn to do a good job building exactly what I need to build and no more.

So, I'm thankful I was able to leave GDD behind and embrace a better practice, which I call HDD: Happiness-Driven-Development. When I'm happy, I write better code. I care more about why I'm writing it and what's it's supposed to be. And, in the long run, I believe all developers should strive to follow the HDD philosophy. After all, that's why we have Ruby in the first place!

> "I hope to see Ruby help every programmer in the world to be productive, and to enjoy programming, and to be happy. That is the primary purpose of Ruby language."

Thanks Matz. I almost forgot.