---
date: Mon, 07 Oct 2024 10:17:14 -0700
title: Top 10 Most Excellent Gems to Use in Any Ruby Web Application
subtitle: It can be a challenge when you’re not using Rails to find gems which integrate well. Here are some solid options you can use in any Ruby web application.
categories:
- Fullstack Development
---

The ecosystem of **Ruby gems** is rich with libraries to enable all sorts of useful functionality you’ll need as you write your web applications. However, at times it can be a challenge when you’re working within a broader Ruby context (aka not using Rails) to find gems which integrate well into all sorts of Ruby applications.

Occasionally you’ll come across a gem which doesn’t clearly label itself as Rails-only. In other cases, the manner in which you can use the gem outside of Rails isn’t clearly documented or there are odd limitations.

But thankfully, **there are plenty of gems which are quite solid to use no matter what architecture you choose**, and a few you might come across may even themselves be dependencies used _by_ Rails because they’re reliable and battle-tested.

In this article, I’ll share with you some of my **favorite gems** you can use in your Ruby web apps. I have personal experience with all of them, and a few I’ve used extensively in the gems and frameworks I work on. (**Note**: order is mostly random.)

## AmazingPrint

It’s certainly true that the Ruby console, IRB, has seen a lot of improvements over the past few years (gotta love that syntax highlighting!). But there’s always more that can be done to make it easier to visualize complex objects and datasets, and that’s where the [AmazingPrint gem](https://github.com/amazing-print/amazing_print) comes in.

It’s easy to install and integrate into your IRB sessions, and once loaded you can gain a more comprehensive idea of what’s actually inside arrays, hashes, and other types of objects as you inspect variables and method output.

AmazingPrint is loaded into the [Bridgetown framework](https://www.bridgetownrb.com)’s console automatically, and I can definitely recommend giving it a try in your projects.

## Mail

Anyone who’s written a Rails application and used Action Mailer to send email, congratulations! You’ve used the [Mail gem](https://github.com/mikel/mail). Mail is indeed what powers Action Mailer under the hood—and good news is, it actually provides a very nice API all on its own.

As the readme demonstrates, you can send simple emails with a simple DSL:

```ruby
mail = Mail.new do
  from     'me@test.lindsaar.net'
  to       'you@test.lindsaar.net'
  subject  'Here is the image you wanted'
  body     File.read('body.txt')
  add_file :filename => 'somefile.png', :content => File.read('/somefile.png')
end

mail.deliver!
```

Setting up a configuration to transport using SMTP is straightforward, and it’s also possible to send both text and HTML-formatted email parts in just a few lines of code.

Apparently Mail can also _read_ email via POP3 or IMAP protocols, but I’ve never tried that personally. I can certainly vouch for sending email though, having done so in **several Bridgetown + Roda projects**. _Thanks Mail!_

## Dotenv

Y’know, you might want store that sensitive SMTP username & password in environments variables your application can read in…the perfect segue to our next gem, [Dotenv](https://github.com/bkeepers/dotenv).

Dotenv does exactly what it sounds like. It reads in `.env` files and provides those values as environment variables. While you typically wouldn’t need this functionality in production, in development or local testing environments having a `.env` file in your project root makes a lot of sense. For example:

```shell
# in .env file
MAIL_SMTP_USERNAME=emailgobrrr
MAIL_SMTP_PASSWORD=asdfzxcv987
```

Then after loading Dotenv, you’ll have access to `ENV["MAIL_SMTP_USERNAME"]` and so on.

At one point in the past, I’d used a gem called Figaro which could read in YAML files and populate env vars accordingly, but development on that gem stalled. Meanwhile, Dotenv is simple and proven. And I’ve integrated this gem into the [Bridgetown framework](https://www.bridgetownrb.com) so repos can make use of it right out of the box.

## Zeitwerk

Many Ruby frameworks—and Rails of course is among them—offer **automatic code loading** (and reloading!). It’s an expectation that once you’ve added your Ruby files in the appropriate folder structures with a naming convention that matches filenames to class names, it all Just Works™. No need to manually require various files in designated places and keep track of the changes needed if a file gets moved, renamed, or deleted.

[Zeitwerk](https://github.com/fxn/zeitwerk) (pronounced zight-verk) was originally developed for Rails to replace the “classic” Rails autoloader, but as a standalone library it can be used by any number of frameworks and gems (and increasingly is!). I [wrote about Zeitwerk](https://www.fullstackruby.dev/syntax-and-metaprogramming/2020/11/25/if-ruby-had-imports/) before on **Fullstack Ruby** as well as the broader philosophy of why Ruby doesn’t have “imports” like so many other language ecosystems.

And at the risk of sounding like a broken record, the [Bridgetown framework](https://www.bridgetownrb.com) uses Zeitwerk both internally and as a code loader for application developers. It’s a **fantastic library** and a genuine workhorse for this very important Ruby functionality.

## Ice Cube

The [ice_cube gem](https://github.com/ice-cube-ruby/ice_cube) is for those cases—and you’d be surprised how often this can come up in application development—when you need to generate a series of dates. Every day. Every Tuesday and Friday at 1pm. The next several weekends. Just recently for example, I wanted to pull some data out of the database and display values on a month-based chart…which means I needed to generate a monthly series starting from _now_ working backwards by _n_ months. Perfect job for ice_cube!

There **are** a few additional features you gain if you’ve loaded in Active Support’s time extensions, but that’s optional. And the very Rubyesque API of ice_cube is quite enjoyable to work with. If you need to do anything at all with calendaring logic, this is the gem for you!

## Nokolexbor

In the grand tradition of software projects coming up with funny-sounding names simply because they’re bits of other names smooshed together, the [Nokolexbor gem](https://github.com/serpapi/nokolexbor) is named such because it’s a portmanteau of Nokogiri (the popular XML/HTML Ruby parser) and Lexbor (an HTML engine written in C). Nokolexbor, like its underlying engine, has a goal to be very, very fast, as well as offer a high degree of HTML5 conformance.

We’ve found good use for Nokolexbor in [Bridgetown](https://www.bridgetownrb.com) to transform output HTML in various ways after the initial markup generation (a common example is to add `#` symbols on hover to headings so you can copy the URL with its extra fragment for deep linking). And I’d probably reach for this over Nokogiri going forward, although if you already have Nokogiri in your project I don’t know that I’d say there’s a compelling reason to switch.

Still I like the fact that Ruby has this new(ish) option available, especially as **I believe DOM-like transformation of HTML server-side will become more and more common in Ruby web frameworks** as traditionally client-side view techniques transition back to the server.

## Concurrent Ruby

The [Concurrent Ruby gem](https://github.com/ruby-concurrency/concurrent-ruby) offers a huge collection of features and data structures which provide for writing Ruby code that is, well, _concurrent_. What does that mean? It could mean creating a thread-safe data structure for sharing between multiple threads executing in tandem. It could mean creating “promises” — aka code blocks which run in threads and return values to the main thread. These and many more use cases are difficult to write in “vanilla Ruby” all on your own (at least in a bug-free manner!), so it’s helpful to use a library like this instead.

See also: the [Async gem](https://socketry.github.io/async/) which lets you schedule asynchronous tasks using fibers instead of threads.

## Money

Just like ice_cube lets you work easily with date series, the [Money gem](https://github.com/RubyMoney/money) lets you work easily with currency values. You can parse strings into currency values (also requires [monetize](https://github.com/RubyMoney/monetize)), perform math between values, exchange one currency for another (as long as an exchange rate is configured), and much more.

Values are stored internally as integers in cents, avoiding errors which can arise with floating-point arithmetic. And when you need to print out the money value, the `format` method makes this straightforward.

## Phonelib

Dates, cash, now phone numbers! The [Phonelib gem](https://github.com/daddyz/phonelib) is specifically designed to let you validate phone numbers. The variety of phone number formats across countries and regions makes phone numbers uniquely difficult to work with, especially when you need to ensure you have a correct number and know how to use it in order to send text messages or automated callbacks.

Phonelib makes use of Google [libphonenumber](https://github.com/google/libphonenumber) under the hood to ensure robust validation and introspection features. Trust me, this is the sort of logic you do _not_ want to attempt to cobble together on your own!

## IP Anonymizer

The [IP Anonymizer](https://github.com/ankane/ip_anonymizer) solves a problem you may not even realize you have. One of my own **pet peeves** is the default manner in which many authentication frameworks and code examples just log or store IP addresses verbatim. This is information I never actually want to capture. Knowing roughly what address a user is coming from vs. any other address for **debugging purposes** can be helpful, but I never need to know the _exact_ address.

IP Anonymizer to the rescue! It can mask both IPv4 and IPv6 addresses, and as long as you’re able to configure your authentication & logging subsystems to pass IP addresses through this gem, you’ll keep that PII (Personally Identifiable Information) out of your records—at least in part.

## Bonus Round: HashWithDotAccess

I just couldn’t keep myself to ten! So here’s an eleventh option for you, and it’s one I’ve written. The [HashWithDotAccess gem](https://github.com/bridgetownrb/hash_with_dot_access) is used extensively by [Bridgetown](https://www.bridgetownrb.com), and it started out life as an enhanced version of Active Support’s `HashWithIndifferentAccess` before a recent rewrite to remove that dependency. Now you can use `HashWithDotAccess::Hash` anywhere you need a hash which provides read/write access via dot notation (aka `user.first_name` instead of `user[:first_name]`).

There have been other solutions like this out there for quite a long time, most notably Hashie, and there are also times when you’d simply want to use a `Struct` value (or more recently a `Data` value) instead. But I think having a flavor of `Hash` which allows for interchangeable string, symbol, and dot access is hugely valuable, and this gem tries to provide that in as performant a way possible. (I did a _lot_ of benchmarking as I worked on the most recent refactor, so I’m pretty confident it’s reasonably speedy.)

---

So there you have it folks: my top ~~10~~ 11 favorite gems which are useful across many variations of Ruby web applications. Which ones have you used? What are your favorites? Do you have additional suggestions of gems to cover in a follow-up? [Head on over to Mastodon](https://ruby.social/@fullstackruby/113267337265299335) and let me know your thoughts!