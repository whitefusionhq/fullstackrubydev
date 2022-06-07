---
title: What Would It Take for Roda to Win?
subtitle: Roda's stated goals are simplicity, reliability, extensibility, and performance. Those are the very reasons why I have become such a Roda stan. It's so malleable, you can take it in any number of directions in terms of architecture—particularly on the view side which is where my primary interest lies.
categories:
- Fullstack Development
author: jared
image: /images/posts/light-trails.jpg
image_hero: /images/posts/light-trails.jpg
image_credit:
  url: https://unsplash.com/photos/mrIaqKh9050
  label: Johannes Groll on Unsplash
---

I have a confession to make. I have fallen in love with [Roda](https://roda.jeremyevans.net). What is Roda, you may ask? Well I'm glad you asked, because I'm here to tell you all about it. 🤓

Roda is a web toolkit—which is basically another way of saying it's a web framework. But the reason the author of Roda, Jeremy Evans, likes to call it a toolkit is because it's really the thing you use to  _construct the thing you need_ to build a web application. You start with a toolkit, and end up with a framework: the precise framework your application truly requires.

Roda's stated goals are **simplicity**, **reliability**, **extensibility**, and **performance**. And those are the very reasons why I have become a Roda stan.

Let me elaborate.

### The Barrier to Entry is Very Low

In other words, a simple app that you build with Roda is indeed _very_ simple.

In fact, the simplest Roda application can [fit into a single file](http://roda.jeremyevans.net/rdoc/files/README_rdoc.html#label-Usage). That's how easy it is to get started with Roda. And I love that because so much of my mindset these days, so much of my ethos as a web developer, is trying to find or build tools which are fascinatingly simplistic at first glance. _How close can we get to a small file with a little bit of code in it?_ Maybe that's all you need to do. 😄

I think some of my take on this is born from seeing such momentum in other ecosystems. Over in the world of JavaScript, you'll quicly discover a shiny new concept called **serverless functions** which has taken quite a hold in the minds of web developers. If all you need to do is something very straightforward—an API with a couple of routes perhaps—you can write a couple of functions and deploy those files somewhere relevant like Netlify and boom, it just works. You don't really have to think about it. You don't have to think about stacks and architectures and all these different considerations upfront.

What _I don't like_ about serverless functions though is it's really unclear to me how you move up from there. Sure, the barrier to entry is indeed very low, but how do you grow your architecture into to a much more complicated, fullstack framework approach? And then how portable is that across different platforms and across different kinds of setups? As many of us Rubyists have seen, JavaScript projects tend to mushroom in tooling configuration and build complexity at an alarming rate.

What I like about Roda is that the mental model you need to get started with fits into that "early stage" ease of use. The routing blocks within Roda's "routing tree" are so immediately accessible, they look a bit like individual serverless functions—only without the serverless, or the functions. 😜 In the end, you're still just writing Ruby object-oriented code within a traditional Rack-based stack…calling out to plain Ruby objects or other parts of your frameworks like a database ORM or template renderers.

### Roda Doesn't Just Stop After Simple

Before continuing to describe Roda, it should be noted that there's another popular, "simple" Ruby web framework called [Sinatra](https://github.com/sinatra/sinatra) with a long and prestigious history. In fact, the [Express.js](https://expressjs.com) framework for Node was based on concepts from Sinatra. But the main knock against Sinatra is it's not great at scaling up from a simple app to something more ambitious. Conceptual and performance problems begin to ensue. You'll typically see Rubyists reaching for a more full-featured framework like Rails, or maybe Hanami. There's sort of an expectation that Rails and Sinatra don't occupy the same "space" within the tools available.

Whereas Roda is intended to take you all the way from greenfield starter projects to at least mid-sized, fully-featured web applications. Jeremy Evans has stated as such in the interviews and presentations he's given. You don't have to jump ship all of a sudden as your app grows and say, "oh no, I can't use Roda anymore. My application is too complicated. I need to go reach for something else!" And if you do end up needing to switch frameworks as the project grows, that would likely be considered something to fix in Roda's feature set and not at all expected.

### A Plugin Architecture So Straightfoward, You'll _Want_ to Write Your Own

Another aspect of Roda I really love is the plugin architecture. It's very straightforward. You can start writing your own plugins right away, _and you probably will_. Unlike with Rails where I feel like writing a plugin or a gem, well it's all a bit messy and complicated. I've worked on Rails engines—I've looked into how other people have written them, I've played around with all this stuff over the years—and sure, I can get it to work in the end but I never feel particularly satisfied with the effort.

Roda's plugin architecture—while encompassing fewer aspects of your overall stack—to me seems **very obvious and intuitive**. You can extend the Roda app class itself, extend request objects, extend response objects…every surface area of Roda's API is extremely customizable. You can even write plugins which themselves depend on other plugins and extend _them_ for additional functionality.

The benefit here is, the more simple it is to get started writing a plugin, _the more likely you're actually going to do it_. I have a sense that more people who use Roda will end up writing their own Roda plugins, as compared to people using Rails writing their own Rails plugins. I don't have any hard proof of that, it's just my take on the matter having used Rails heavily for well over a decade.

## Y U No Like Rails?

Speaking of Rails…why even look farther afield at a toolkit like Roda? Why not just stick with Rails and the "Rails way"? Why not just continue to be a Rails developer ? I know Rails up, down, and sideways by now. Why not just keep playing in that sandbox?

Right off the bat, I want to make it clear I _love_ many aspects of Rails even now. ActiveRecord is fantastic. (Yes I know…[Sequel](http://sequel.jeremyevans.net) is a thing. But AR fits my brain like a glove. I'm just so used to it.). ActiveSupport—despite the grumblings of well-meaning Ruby OOP purists out there—I believe is a major selling point of Rails and Ruby in general. And even with everything I said above regarding plugins, it is indeed impressive that there seems to be a Rails plugin gem out there for just about _anything and everything_ you'd ever need to build a sophisticated web application.

But at this point in time, the "VC" of MVC in Rails ([you can listen to my recent podcast episode about MVC for background context](https://www.fullstackruby.dev/podcast/4/)) feels weak to me. It really feels aging to be quite honest. There has not been any real innovation or change around that part of Rails since the beginning of the framework. The routes file, controllers, actions, ERB views, helpers, partials—all nearly untouched in two decades! (Hotwire/Turbo is the first _real_ update to any of this in some time, and honestly while it's pretty cool at first glance, it also feels a little bolted on and limitations abound. Hence the need to reach for, say, [CableReady](https://cableready.stimulusreflex.com/v/v5/). But I digress…)

The vanilla stack of Rails—the "Rails way"—when it comes to the basic request/response cycle and rendering views, well I just have a lot of complaints with it at this point. For simple actions, there's _way too much ceremony_ for seemingly little gain. There's what I call **an unquestioning adherence to the HTTP-inspired REST concept**.  As much as I do like REST overall, and as much as I would defend REST against competitors such as GraphQL, I also feel like I've seen a lot of what I would call "REST-induced Design Damage" (to take a page out of DHH's playbook regarding [Test-induced Design Damage](https://dhh.dk/2014/test-induced-design-damage.html)).

I've seen **REST-induced Design Damage** in projects time and again, where everything you do throughout the entire app somehow has to fit into this concept of:

* Go into the routes file and create a new resource endpoint
* Go create a new controller for that endpoint
* Now you have to create the actions of the controller, like the index action and the show action and the new and the edit and the whatever
* Now you have to create the views of the actions of the controller of the endpoint 😰
* Now you have to create the partials of the forms and the models for the views of the actions of the…OMG 😱

I feel like all those bits of architecture are increasingly a total mismatch _with what I'm actually trying to do_. I've talked before about the rise of "component-based view architectures", and more and more I'm finding that I want to orient a lot of my application architecture around what I might label "groupings of component-trees + state" — rather than HTTP resources with controllers and subsequent page templates associated with those controllers and those controller actions. There's so much ceremony to get to the point where all I really want is to have this tree of components for some specific part of my application, and within that tree of components there are various well-defined components which might have their own individual lifecycles on both the server and the client.

You can think of this as [islands architecture](https://jasonformat.com/islands-architecture/) if you want, or perhaps "nested layouts". Some JavaScript frameworks lately have promoted nested layouts as a fundamental building block of the view layer: you have a main layout for your application or a big section of your application, and then it breaks out into sub-layouts, and those sub-layouts have their own sub-layouts. All these different layouts and sub-layouts have their own lifecycles essentially, and as a user, you're performing interactions within these sub-layouts and those interactions need to update state on the backend and then reflect that state back on the frontend and so forth. 

However you want to slice it, I really feel like component-based view architecture has rejiggered how we think of the architecture of a web application, and HTTP resources via REST and the controllers and the views associated with them that you see in the vanilla Rails stack is sort of at odds with those ideas. Even while Turbo Frames and Streams start to break apart the traditional concepts of Rails views, **they don't go nearly far enough**. As I've stated, they feel sort of tacked-on to Rails, _rather than Rails being fully-rearchitected_ to support Turbo concepts from the bottom to the top of the stack.

Something that's emblematic of Rails' "views malaise", and honestly it continues to trouble me to this day, is the whole ViewComponent fiasco. When GitHub came up with their [ViewComponent](https://viewcomponent.org) library, it seemed right at first like it would be folded directly into Rails. In fact it was originally called `ActionView::Component`. Wow! Rails would gain the idea of creating new isolated, previewable, testable components for views! **Progress!**

And then, _thud_. From what I can gather, GitHub backed out of the merger at the behest of Basecamp/DHH. View components did _not_ become part of vanilla Rails. And in my opinion, the impulse to refuse something like components entering the Rails lexicon is **very troubling**. Instead of seeing innovation, we saw entrenchment. In the web industry today where frontend UI design is quite literally _all about components_, Rails has become a dinosaur by comparison.

(One thing Rails _did_ do right is it added the ability for any third-party component system to exist by augmenting the `render` method within views. So by calling `render any_ruby_object_here` in a view, the `render_in` method of the Ruby object gets called automatically with the view context as the first argument and an optional block to capture. This is such a powerful concept, we adopted the `render_in` convention for Bridgetown's view layer. At this point, **I think it should be considered a standard convention across the Ruby ecosystem**.)

All right, so that's my take on Rails, but…**what does any of this have to do with Roda?**

Well, it's true that Roda _also doesn't offer_ any of this componentized view architecture stuff I'm talking about. But the thing about Roda is it's **extremely extensible**. Out of the box, it doesn't even have a view layer! You have to load the `render` plugin explicitly, by choice. Which means…there's literally nothing stopping you from _building your own view layer_ for Roda to your exact specifications.

**And that's exactly what we did for Bridgetown's Roda integration.** Bridgetown's own [view layer](https://edge.bridgetownrb.com/docs/template-engines), including [components](https://edge.bridgetownrb.com/docs/components)—even [Lit-based web components](https://edge.bridgetownrb.com/docs/components/lit)!—becomes Roda's view layer. More on that in just a moment.

### The Need for Roda Distributions

To recap, I really love Roda due to its stated goals: **simplicity**, **reliability**, **extensibility**, and **performance**. I've been using Roda (along with Bridgetown) to date for a variety of simple apps, and there's also a more complicated app in the works that's not publicly available at the moment—a port of a "newsfeed reader" app I originally wrote in Rails. I brought a lot of the concepts from the original Rails app over to a new Roda application which is part of a Bridgetown installation overall, and so far it's a pretty sweet setup. Hoping to open source it later this year…

So while I personally haven't yet written a "large" application in Roda, I can see the path forward. I've done enough experimenting at this point to know what I would do, how all the pieces would fit together.

**But therein lies the rub.**

You can get started using Roda, and simple things are indeed simple, _but which Roda will you end up with in the end?_ Eventually you'll need what I call a "distribution of Roda". You'll need your application's "fullstack framework" set up in a particular manner. Merely using "pure Roda" by itself, without any configured plugins or extra configuration, is not enough to actually create a fully-featured web application with a lot of complexity. In fact the documentation makes that point abundantly clear. It's by design: instead of starting with a huge framework with a plethora of various sub-frameworks configured and set up waiting for you to maybe use one day (aka Rails), you can start out with a _much simpler architecture_ and then slowly build things up bit by bit over time.

Nevertheless, you'll probably want to look at some kind of "distribution" or starter kit or example stack or whatever to get a sense of what's possible and avoid reinventing the wheel. Jeremy Evans promotes [an example stack of a Roda application](https://github.com/jeremyevans/roda-sequel-stack) which features multiple route files and a database configuration via Sequel and live reloading when files change and various view templates set up and all that. But…it's an _opinionated_ take on a canonical Roda stack, and **I don't necessarily agree with those opinions**. I have my own distribution of Roda if you will, and **that's essentially what Bridgetown is turning into**.

Roda is so malleable, you can take it in any number of directions in terms of architecture—particularly on the view side which is where my primary interest lies. You _can_ push it in the direction of a Rails-style architecture, sure. **Or you can push it in an entirely different direction.**

### Bridgetown's Spin on Roda

What I'm trying to do as I work on [the integration of Roda into Bridgetown](https://edge.bridgetownrb.com/docs/routes) is that when you create a Bridgetown site, you're also creating a Roda application. It's the culmination of what I've been calling the **DREAMstack** (Delightful Ruby Expressing APIs & Markup), where you can start with a very simple website containing just a few static pages with Markdown content or whatever, and _then_ you can start to mix in more advanced component trees—"islands"—using a combination of Ruby components and web components, and _then on top of that_ write corresponding backend code with this "not-serverless-functions-but-they-look-kinda-like-serverless functions" paradigm that Roda affords.

This way you have a **clear path** for starting simple and then scaling up to more sophisticated, interactive, large applications. It's an entire spectrum of tooling at your fingertips. We can even pull in "bits" of Rails as needed where it makes total sense. (As I previously mentioned, ActiveRecord remains to this day my ORM of choice!)

While the [dynamic file-based routing system](https://edge.bridgetownrb.com/docs/routes#file-based-dynamic-routes) we've provided in Bridgetown is a pretty great way to get started with server-based routes after working with static resources, something I've recently started to experiment with—which is perhaps a bit bonkers but it's all in the interest of collapsing layers and reducing conceptual complexity—is instead of defining a new Roda route/file and then in that route saying "oh, now I want to render out this particular component" …what if a component _itself_ could have a Roda route associated with it?  Within that route you could update state, talk to a database, whatever you need to do, and then just immediately re-render the component via that route and update the frontend instantly. (In case you're starting to think I'm nuts here, [there's prior art for this very concept](https://github.com/joshleblanc/view_component_reflex).)

Listen, I'm not saying you would _always_ want to do this. I'm not saying it would fit every feature. I'm not saying it's inherently a good idea compared to all other approaches you might attempt within your architecture. But the point is to strive to innovate and to _think of views in terms of islands_, and within those islands you have various component trees, and some of those components could be Ruby-based and others JavaScript/web component-based and still others a hybrid of the two, and **they all potentially have their own backend/frontend interactive rendering lifecycles**.

**There's so much you can do now as part of a truly componentized view architecture.** And I don't want to just bolt this on top of a traditional Ruby framework. **I want to have a framework which feels like it was invented in the age of components.** My hope is that Bridgetown will endeavor to push the envelope in this area over the next several months and even years.

### So What Would It Take for Roda to Win?

OK, I fully admit the title of this article is tongue-in-cheek. I don't think Roda has to or should "win"—but neither do I think any other framework should win! That said, I do want to see the Roda community grow and thrive. I want to see more examples out in the wild, more plugins, more "distributions". **Let a hundred flowers bloom.**

As Ruby web developers, we need—nay, deserve—a more vibrant set of choices. As much as Rails domination within the Ruby web community has produced a ton of good things and plenty of good side effects. I also think it has sometimes limited thinking, limited innovation—particularly on the frontend side of things. And the problem with that is it's going to cause certain types of developers to give up on Ruby or not even give it a close look. Someone who's super into frontend development, who's super into some of the ways that JavaScript frameworks work today, if you just hand them a traditional Rails architecture and say "hey, here's Rails, use Rails, learn Ruby, it's cool"—they're going to take one look at it and go _blegh_. Not trying to be overly dramatic here, but I really think Rails can be its own worst enemy sometimes. As a Rubyist, **I'd love to see a much broader range of thinking**. 

What does "modern" web architecture look like right now, today? What _could_ it look like? What might work differently? What might be best left untouched? (If it ain't broke, don't fix it!) In other words, start from lofty end goals and blue-sky thinking, and then _work backwards_ to create the sorts of frameworks that we need now and into the future.

**That's essentially what I'm trying to do with the Bridgetown + Roda distribution.**

But I'll be honest. For certain kinds of applications. I'm sure it's going to be ludicrous. It would be _absurd_ to use Bridgetown + Roda for that particular app. That's fine. I have no problem with that. Use "vanilla" Roda. Use Rails. Heck, use Hanami! Go for it. That's totally fine.

I do fervently believe however there are other classes of applications, particularly websites which have public-facing, content-heavy aspects to them, where I feel like using Rails or some other traditional framework or even vanilla Roda would be totally ill suited to that. I think there's a **substantial niche** where the Bridgetown + Roda distribution with its very specific feature set might prove to be _an ideal solution_ for those particular projects. Educational sites with paywalls. E-commerce solutions. News/social/publishing apps. Listing-style sites with lots of forms. Live dashboards acting upon disparate datasets. Marketing sites with a tight coupling to advanced headless CMSes. I could go on!

(However, if you're looking to build a straight-up SaaS app or platform for a well-defined industry…**Rails**. Always…and maybe forever. For what Rails is best at, **it remains the undefeated champion**.)

Whichever framework you end up using, at the end of the day **I hope it's built on top of Ruby**. That's always the primary consideration for me. Over time, it's not that I want to see Roda "supplant" Rails and or even take a larger slice of the same-sized pie. **I want to see Roda (and Bridgetown too) help grow the pie entirely.** I want to see Ruby-based technologies reach into farther corners of the overall web industry. I believe it's possible. Do you? {%= ruby_gem %}