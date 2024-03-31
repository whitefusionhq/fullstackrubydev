---
title: Why the Release of Ruby 3 Will Be Monumental
subtitle: Ruby 3 is an exciting update with lots of new features—yet I think it’s the psychology of turning over from major version 2 to 3 that is most vital to the future health of the Ruby community.
categories:
- The Art of Code
author: jared
image: /images/posts/light-trails.jpg
image_hero: /images/posts/light-trails.jpg
image_credit:
  url: https://unsplash.com/photos/mrIaqKh9050
  label: Johannes Groll on Unsplash
---

We’ve been living in the shadow of Ruby 2 for seven years now. Seven! [Ruby 2 was released in 2013](https://www.ruby-lang.org/en/news/2013/02/24/ruby-2-0-0-p0-is-released/) (which incidentally is the same year as the initial public release of React 0.3.0!).

In that span of time, Ruby performance has improved _significantly_ and many, many enhancements to the language have benefited a great many people and projects. We’ve seen companies using Ruby and in many cases Rails become bedrocks of developer and consumer internet infrastructure. GitHub. Shopify. Stripe. Square. AirBnB.

But there has also been some consternation along the way. Is Ruby really a top-tier programming language able to compete with the likes of Javascript, Python, PHP, Go, and beyond? Or was it just a DHH-fueled hype-cycle doomed to inevitable relative obscurity as other technologies and frameworks ascended in its wake? (I don’t actually believe anyone seriously thinks this any more, but you still see the stray head-scratcher whiz by on Hacker News.)

Now we are mere weeks away from a major new Ruby release: version 3. While Ruby 3 is an exciting update with lots of features that make it interesting both now and in the future with various point updates promising even more goodies, I think it's the **psychology** of turning over from major version 2 to 3 that is most vital to the future health of the community.

Ruby 3 isn’t just a new version. **It’s a new era.**

What does this era represent? Let’s list a few talking points I hope we’ll start to push _hard_ and _often_ as Rubyists:

### Ruby 3 is Fast

No, I don’t mean Ruby 3 suddenly got a whole lot faster than Ruby 2.7. I mean that Ruby 3 is _fast compared to Ruby 2_. It’s unfortunate that much of the “Ruby is slow” meme has been a laggard perspective stemming from people’s experiences _years ago_ with the language, or an old version of Rails, or Jekyll, or…the fact is it just wasn’t the zippy experience we’re pleased to enjoy today.

Do we still want even better performance? Of course! But at this point, Ruby is plenty fast as compared to many other “scripting” languages. Most of the time it’s on par with Python. It’s even on par with Javascript. (What? Don’t believe me? [Check out how similar Jekyll and Eleventy perform as static site generators.](https://css-tricks.com/comparing-static-site-generator-build-times/)) And as Nate Berskopec often reminds us, your Rails app can perform quite well with just a bit of fine-tuning, and often the typical bottlenecks lie elsewhere in the stack (database, web server, etc.)

### Ruby 3 is Easy

These days, you don’t need to wrestle with gem dependency hell or pray to the gods to get Ruby or a Ruby extension to compile. That was “old Ruby”. New Ruby is using a fancy-pants version manager like `rbenv` combined with Bundler 2.

**It just works.**

Truly, Ruby is the first thing I install on any new Mac or Linux machine I operate and getting things set up is a piece of cake. Installing Rails. Installing Bridgetown. Installing…whatever. It. Just. Works.

We also have things like Docker and WSL to make things _much_ easier to accomplish on Windows machines if you get stuck wrestling with Win-native Ruby. Heck, you can upload your entire dev environment into the cloud now and use VSCode with remote extensions.

Are there ways Bundler and the ecosystem around Ruby versions/dependencies could be improved? No doubt. But it’s in no way any more complicated or fiddly than the world of npm/yarn, and you don’t see the angry hordes trying to burn down the barn doors over there (except maybe the Deno folks 😉).

### Ruby 3 is Sleek

Ruby isn’t the best choice for all problem domains. It just isn’t. But when it comes to “standard” web development, it often _is_ the best choice. It really is! Spend a few days writing NestJS + TypeORM Typescript code and then come back to Rails. It’s like a breath of fresh, sweet air. And that’s not just when you’re writing controllers or models…it goes all the way up and down the stack.

Ruby just makes everything _better_. Less code. Less boilerplate. Less ceremony. More streamlined. More properly object-oriented. More polished and pleasurable to read and write. Certainly one could posit there are other web frameworks/languages which have much going for them as well. Laravel is popular with PHP devs, and for good reason. Django is popular with Pythonistas. But can anyone say with a straight face that, all things being equal, PHP is a “superior” programming language to Ruby? Can anyone say that Python—taken as a whole—is more suited to building a website than Ruby is?

I think not. While Ruby wasn’t originally invented as a way to supercharge web development, it found its niche in the rise of such amazing projects as Rails, Rack, Jekyll, plus great APIs by Stripe and many others. It rode much of the early wave of Web 2.0 hits, and that heritage continues to benefit us today.

### Ruby 3 is Here to Stay

Ruby 3 isn’t just another notch on the belt of recent Ruby releases. It’s **Ruby 3.0**. That means we can look forward to 3.1, 3.2, 3.3, and beyond. This is the beginning of a whole new era. New innovations. New patterns. Exciting ideas fusing concepts from other technologies with The Ruby Way. Fresh blood coming into the ecosystem. (Anecdotally, I’m seeing newbies plus returning old-timers jumping into Ruby-based forums and chat rooms _all the time_, and the pace of interesting new Ruby gems bursting onto the scene finally seems to be increasing after a few years of ho-hum incremental progress.)

The takeaway is this: Ruby 3 represents a moment when we should stand proud as Rubyists and unabashedly proclaim to the bootcamps and engineering departments of the world that we’re open and ready to do business large and small. Sure you could pick something other than Ruby with which to build the next great internet success story. But you’ll definitely be in good company if you do pick Ruby. After all, it’s more likely than not your code will be living in a repository overseen by Ruby (GitHub), you’ll be communicating with your fellow colleagues via Ruby (Basecamp & HEY), you’ll be asking for support via Ruby (Discourse forums), you’ll be researching the latest developer news and techniques via Ruby (Dev.to), and you’ll be spinning up your dev machine while wearing that l33t geek t-shirt you got from an indie vendor via Ruby (Shopify)—that is, after you paid for it via Ruby (Stripe). And when you’re exhausted from all that coding and need to unwind at a private cottage by the beach, Ruby will help you out there too (AirBnB).

_Excelsior!_