---
date: Mon, 20 May 2024 07:41:00 -0700
title: Expressive Class Hierarchies through Dynamically-Instantiated Support Objects
subtitle: Abstract classes don't always stand alone, but spring to life as a part of an object cluster. Here's how to ensure you're always instantiating the right ones.
categories:
- Object Orientation
---

When you're designing an abstract class for the purpose of **subclassing**—very common when looking at the framework/app divide—it's tempting to want to throw a whole bunch of loosely-related functionality into that one parent class. But as we all know, that's rarely the right approach to designing the models of your system.

So we start to reach for other tools…**mixins** perhaps. But while I _love_ mixins on the app side of the divide, I'm not always a huge fan of them on the framework side. I'm not saying I won't do it—I certainly have before—but I more often tend to consider the possibility that in fact I'm working with a cluster of related classes, where one "main" class needs to talk to a few other "support" classes which are most likely nested within the main class' namespace.

The question then becomes: once a subclass of this abstract class gets authored, what do you do about the support classes? The naïve way would be to reference the support class constant directly. Here's an example:

```ruby
class WorkingClass
  def perform_work
    config = ConfigClass.new(self)
    
    do_stuff(strategy: config.strategy)
  end

  def do_stuff(strategy:) = "it worked! #{strategy}"

  class ConfigClass
    def initialize(working)
      @working = working
    end

    def strategy
      raise NoMethodError, "you must implement 'strategy' in concrete subclass"
    end
  end
end
```

Now this code would work perfectly fine…_if all you need_ is `WorkingClass` alone. But since that's simply an abstract class, and the nested `ConfigClass` is _also_ an abstract class, then **Houston, we have a problem.**

For you see, once you've subclassed both, you may find to your great surprise the _wrong class_ has been instantiated!

```ruby
class WorkingHarderClass < WorkingClass
  class ConfigClass < WorkingClass::ConfigClass
    def strategy
      # a new purpose emerges
      "easy as pie!"
    end
  end
end

WorkingHarderClass.new.perform_work
# ‼️ you must implement 'strategy' in concrete subclass (NoMethodError)
```

_Oops!_ 😬

Thankfully, there's a simple way to fix this problem. All you have to do is change that one line in `perform_work`:

```ruby
class WorkingClass
  def perform_work
    config = self.class::ConfigClass.new(self) # changed
    
    do_stuff(strategy: config.strategy)
  end
end
```

Courtesy of the reference to `self.class`, now when you run `WorkingHarderClass.new.perform_work`, it will instantiate the correct supporting class, call that object, and return the phrase **"it worked! easy as pie!"**

_**Note:** in an earlier version of this article, I used `self.class.const_get(:ConfigClass)`, but I received feedback the above is an even cleaner approach. 🧹_

What's also nice about this pattern is you can easily swap out supporting classes on a whim, perhaps as part of testing (automated suite, A/B tests, etc.)

```ruby
# Save a reference to the original class:
_SavedClass = WorkingHarderClass::ConfigClass

# Try a new approach:
WorkingHarderClass::ConfigClass = Class.new(WorkingClass::ConfigClass) do
  def strategy = "another strategy!"
end

WorkingHarderClass.new.perform_work # => "it worked! another strategy!"

# Restore back to the original:
WorkingHarderClass::ConfigClass = _SavedClass

WorkingHarderClass.new.perform_work # => "it worked! easy as pie!"
```

This _almost_ feels like monkey-patching, but it's really not. You're merely tweaking a straightforward class hierarchy and the nested constants thereof. **Which, when you think about it, is actually rather cool.**

**Note:** the code examples above are written in a simplistic fashion. In production code, I'd move the setup of `config` into its own method and utilize the memoization pattern. [Read all about it in this Fullstack Ruby article](https://www.fullstackruby.dev/object-orientation/2021/03/23/better-oop-through-lazily-instantiated-memoized-dependencies/). {%= ruby_gem %}
