---
title: If Ruby Had Imports…
subtitle: Sometimes it’s bonkers how much you have to import in other languages in every file before you get to the actual code. Thankfully Ruby provides a better way.
categories:
- Syntax and Metaprogramming
author: jared
image: "/images/posts/filing-system.jpg"
image_hero: "/images/posts/filing-system.jpg"
rainbow_hero: true
image_credit:
  url: https://unsplash.com/photos/Q9y3LRuuxmg
  label: Maksym Kaharlytskyi on Unsplash
published: true
---

Here is some [example code from a Rails controller](https://github.com/discourse/discourse/blob/master/app/controllers/badges_controller.rb) in the widely-used Discourse forum software:

```ruby
class BadgesController < ApplicationController
  skip_before_action :check_xhr, only: [:index, :show]
  after_action :add_noindex_header

  def index
    raise Discourse::NotFound unless SiteSetting.enable_badges

    badges = Badge.all

    if search = params[:search]
      search = search.to_s
      badges = badges.where("name ILIKE ?", "%#{search}%")
    end

    if (params[:only_listable] == "true") || !request.xhr?
      # NOTE: this is sorted client side if needed
      badges = badges.includes(:badge_grouping)
        .includes(:badge_type)
        .where(enabled: true, listable: true)
    end

    badges = badges.to_a

    user_badges = nil
    if current_user
      user_badges = Set.new(current_user.user_badges.select('distinct badge_id').pluck(:badge_id))
    end
    serialized = MultiJson.dump(serialize_data(badges, BadgeIndexSerializer, root: "badges", user_badges: user_badges, include_long_description: true))
    respond_to do |format|
      format.html do
        store_preloaded "badges", serialized
        render "default/empty"
      end
      format.json { render json: serialized }
    end
  end

  # and more actions here...
end
```

Now, if you’re looking at this code coming from a JavaScript/TypeScript background—or a number of other programming languages—the first thing you might immediately think is:

_Where are all the import statements??_

That’s right, there’s nary an import statement to be found! Where does `ApplicationController` come from? `SiteSetting`? `Badge`? Heck, even `MultiJson`? _How is this all just accessible without requiring it somehow?!_

Ah my friend—welcome to the wonderful world of **Ruby autoloading**.

### How to Acquire an Instinctual Hatred of Explicit Import Statements

**Step 1:** write Rails apps full-time for several years.

**Step 2:** go peek at the top of a file written for virtually any large NodeJS framework.

**Step 3:** 🤢

Look, I don’t mean to pick on poor JavaScript. When you’re trying to write performant code for eventual download to a browser where you need to keep the bundle sizes lean and mean, you **want** to import and export and tree-shake and chunk-split and do _everything you can do_ to avoid megabytes of unnecessary code clogging up the wires.

But riddle me this: _why do you need 20 import statements at the top of a file…in a server environment??_

![Excuse me, what does NodeJS need with a small bundle size?](/images/posts/nodejs-imports-meme.jpg)
{:.has-text-centered .mx-auto .my-6}
{:style="max-width:750px"}

If you would indulge me for a moment, let’s imagine a world where you had to import all of the objects and functions needed in each file in your Rails application. Revisiting the example above, it might look something like this:

```ruby
import ApplicationController from "./application_controller"
import { skip_before_action, after_action, params, respond_to, format } from "@rails/actionpack"
import Discourse from "../lib/global/discourse"
import SiteSetting from "../models/site_setting"
import Badge from "../models/badge"
import MultiJson from "@intridea/multi_json"

class BadgesController < ApplicationController
  # etc...
end
```

And that’s just for **a single controller action**! 🤪

This leaves us with only one question: since your Ruby on Rails code obviously _doesn’t_ have to import/require anything for it to work, how does it do that? How does it know how to simply autoload all these objects?

### Introducing Zeitwerk

Actually, before we dive into [Zeitwerk](https://github.com/fxn/zeitwerk), let’s quickly review built-in Ruby autoloading.

Ruby comes out of the box with a form of autoloading attached to `Module`. You can use this in any Ruby program you write:

```ruby
# my_class.rb
module MyModule
  class MyClass
  end
end

# main.rb
module MyModule
  autoload :MyClass, "my_class.rb"
end

MyModule::MyClass.new # this triggers the autoload
```

This is handy in a pinch, but for larger applications or gems and particularly for Rails, you need something that’s broader-reaching and more easily configurable—plus supports concepts like “eager loading” and “reloading” (in development).

That’s where Zeitwerk comes in.

With Zeitwerk, you can define one or more source trees, and within that tree, as long as your Ruby constants (modules and classs) and hierarchy thereof match the file names and folder structure via a particular convention, _it all just works_. Magic!

Here’s an example from the readme:

```
lib/my_gem.rb         -> MyGem
lib/my_gem/foo.rb     -> MyGem::Foo
lib/my_gem/bar_baz.rb -> MyGem::BarBaz
lib/my_gem/woo/zoo.rb -> MyGem::Woo::Zoo
```

And here’s how you instantiate a Zeitwerk loader. It’s incredibly easy!

```ruby
loader = Zeitwerk::Loader.new
loader.push_dir("lib")
loader.setup # ready!
```

Once you’ve instantiated a Zeitwerk loader, at any point in the execution of your Ruby program after that setup is complete you can call upon any class/module defined within that loader’s source tree and Zeitwerk will automatically load the class/module.

In addition, if you use the `loader.eager_load` method, you can load all of the code into memory at once. This is preferred in production for performance reasons: once your app first boots, it doesn’t have to load anything else later. On the other hand, in development you want to be able to reload code if it’s changed and run it without having to terminate your app and boot it up again. With the `loader.reload` method, Zeitwerk supports that too!

You may be surprised to hear that Zeitwerk is somewhat new to the Ruby scene (Rails used a different autoloader before it and there have been other techniques in that vein over time). What makes Zeitwerk so cool is how easy it is to integrate into any Ruby app or gem. I myself am starting to integrate it into [Bridgetown](https://www.bridgetownrb.com) now. The only caveat is you do need to be a little strict with how you structure your source files and folders and what you name within those files. But once you do that, it’s a cinch.

### Still a Use for `require` Though

Even with Zeitwerk on the loose, you’ll still need to use a `require` statement now and then to load Ruby code from a gem or some other random file you’ve pulled into your project. But the nice thing is that Ruby’s `require` doesn’t work the way that `import` does in JavaScript. It simply adds the requested file/gem to the current execution scope of your program and then it’s available everywhere proceeding from that point. So if you add `require` to a main or top-level file within your application codebase, there’s no need to then “`import Foo from "bar"`” later on in file B and “`import Foo from "bar"`” in file C all over again.

This does mean that you may have to fish a bit to find out where `MyObscureClassName.what_the_heck_is_this` actually comes from. This is likely how some of the “argh, Ruby is _too_ magical!” sentiment out there arises. But given a choice between Ruby magic, and JS import statement soup at the top of Every. Single. Darn. File. In. The. Entire. Codebase…

…well, I believe in magic. [Do you?](https://www.youtube.com/watch?v=JnbfuAcCqpY) {%= ruby_gem %}

<style>
  .hero-body h2 {
    max-width: 1320px;
    margin-left: auto;
    margin-right: auto;
  }
</style>