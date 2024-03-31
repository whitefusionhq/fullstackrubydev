---
title: Teaching Ruby to Beginners? Trying New Gems or Techniques? Use Bridgetown!
subtitle: "The next big release of Bridgetown provides an intriguing new environment for teaching and learning Ruby and trying out new tools in the Ruby ecosystem."
categories:
- Jamstack Frameworks
author: jared
image: "/images/posts/fremont-bridge.jpg"
image_hero: "/images/posts/fremont-bridge.jpg"
published: true
---

As a core member of the [Bridgetown](https://beta.bridgetownrb.com) project, I realize I'm biased. I think every Rubyist who works on or even near the web should take a look—especially anyone who has current or past experience using Jekyll. But today's post isn't about Bridgetown per se but about how the next big release, v0.21 "Broughton Beach" (currently in beta and due out in late May), provides an intriguing new environment for teaching and learning Ruby and trying out new tools in the Ruby ecosystem.

### Ruby Ruby Everywhere

One of the new features in Broughton Beach which is germane to this discussion is the ability to write web pages in pure Ruby. Previously, you could write a webpage in a template language such as Liquid, ERB, Haml, etc., similar to other Ruby frameworks like Rails.

*Wait*, I hear you say. *Isn't ERB just Ruby inside the* `<% %>` *delimiters?*

Sure, it is. But you usually don't see people writing an entire Ruby script in an ERB file. It's mainly intended for first authoring the raw text of the template and then sprinkling bits of Ruby into it.

What's changed in v0.21 is you can now add a page, or a layout, or a data file, using nothing more than `.rb`. Basically you can write any Ruby code you want, and the value returned at the end of the file becomes the content of the page. So you can build up web page markup using string concatenation, fancy DSLs, transformations of incoming data, the whole nine yards. And you can add methods and inner classes and anything else you need to accomplish your objective.

### Demo Time

**Check out this [sample repo on GitHub](https://github.com/jaredcwhite/minimal-bridgetown-ruby-site), along with [the demo site here](https://minimal-bridgetown-ruby-site.onrender.com).**

Feel free to fork the repo and take it for a spin! The only top-level files needed are the typical `Gemfile`/`Gemfile.lock` pair, and the `bridgetown.config.yml` file loaded by Bridgetown. Everything else goes in `src`. Let's see what we have inside:

* In `_data/site_metadata.rb`, we return a simple hash of key/value pairs we can access in any page via `site.metadata`. Only `title` is defined here but you can add any site-wide values you like.
* In `_layouts/default.rb`, we define a simple HTML wrapper that can be used for any page on the site. First we obtain the logo SVG (aka {%= ruby_gem %}) we'll use for our site-wide header. Next, we define a small stylesheet we'll inject into the HTML head using a `style` tag. Then, we return the HTML itself using heredoc string interpolation to add in a few variables.
* `index.md` is where things really get interesting. First we define a block of front matter using Ruby rather than YAML. (Note, we use the `###ruby … ###` formatting in order for the front matter to get extracted and parsed separately at an earlier time than the rest of the page.) It references our `default` layout and sets the page title. Then in the body of the page, we create a few helper methods and values and begin constructing the page content using our home-grown DSL. Finally we return the `@output` of the page produced by our helper methods.

Is this the right way to build a Bridgetown site? 🤔 Well I certainly wouldn't recommend shipping it to production! 😅 The point isn't if you should use any of these techniques to build a website—rather that **you can if you want to**. (Just keep in mind that meme about scientists getting so preoccupied…)

Because you can, this becomes a compelling way to teach or to learn Ruby in the guise of building a website. Try out new techniques, new syntax, new parts of the standard library, new gems…the sky's the limit! In the past, I might write one-off Ruby scripts and execute them on the command line, or maybe fiddle around in IRB. But now, with Bridgetown 0.21, I can actually maintain an experimental website full of pages which house various tips & tricks of Ruby programming I've picked up. Git init a repo, deploy it in mere minutes on [Render](https://render.com), and we're all set!

### Further Experimentation

Want to get really fancy? Add the [method_source](https://github.com/banister/method_source) gem to your project, and then inside a Ruby page you can grab a string representation of a proc or a method in the page and use that to output the source code to the webpage itself. Mind blown! 🤯

Another thing you can do (even if your pages use traditional ERB or another template language) is use the `src/_data` folder to drop `.rb` files that could load in data from filesystems or APIs (or generate data directly) and do all kinds of interesting things to it before returning either an array or a hash which is then accessible via `site.your_data_file_here` (tack on `.rows` if an array).

My goal in creating Bridgetown was always to consider the "Ruby-ness" of the tool a feature, not a bug. (By contrast it's progenitor, Jekyll, strangely doesn't  overtly spell out that it's a Ruby tool built by Rubyists for Rubyists).

I'm *very excited* to see what crazy, experimental projects people will build using this new version of [Bridgetown](https://beta.bridgetownrb.com). Feel free to hop on over to our [Discord chat room](https://discord.gg/4E6hktQGz4) and let us know! {%= ruby_gem %}