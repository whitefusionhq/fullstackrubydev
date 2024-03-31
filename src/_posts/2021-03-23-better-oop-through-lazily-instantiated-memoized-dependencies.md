---
title: "Better OOP Through Lazily-Instantiated Memoized Dependencies"
subtitle: "There are various schools of thought around how best to define dependencies in your object graph. Let’s learn about the one I prefer to use the majority of the time. It takes advantage of three techniques Ruby provides for us: variable-like method calls, lazy instantiation, and memoization."
categories:
- Object Orientation
author: jared
image: "/images/posts/modern-house.jpg"
image_hero: "/images/posts/modern-house.jpg"
rainbow_hero: true
image_credit:
  url: https://unsplash.com/photos/9LMRQdVv7hw
  label: Nathan Van Egmond on Unsplash
published: true
---

As you sit down to write a new class in Ruby, you’re very likely going to be calling out to other objects (which in turn call out to other objects). Sometimes this is referred to as an _object graph_.

The outside objects created or required by a particular class in order for it to function broadly are called _dependencies_. There are various schools of thought around how best to define those dependencies. Let’s learn about the one I prefer to use the majority of the time. It takes advantage of three techniques Ruby provides for us: **variable-like method calls, lazy instantiation, and memoization**.

### Let’s Get Object Oriented

First of all, what do I mean by “variable-like method calls”? I mean that this:

```ruby
thing.do_something(123)
```

could refer either to  `thing` (a locally-scoped variable) or `thing` (a method of the current object). What’s groovy about this is when I instantiate `thing`, I can chose *how* to instantiate it. I could either set it up like this:

```ruby
def some_method
  thing = Thing.new(:abc)
  thing.do_something(123)
end
```

or this:

```ruby
def some_method
  thing.do_something(123)
end

def thing
  Thing.new(:abc)
end
```

The beauty of the second example is it makes `thing` available from more than one method—all while using the same initialization values. The problem with this example however is if I access `thing` more than once, it will create a new object instance.

```ruby
def some_method
  thing.do_something(123)
  thing.finalize!
end
```

Oh no! The `thing` of the second line _will be a different object_ than the `thing` of the first line! Yikes! Thankfully, we have a technique to fix that: “memoization via instance variable”.

[Memoization](https://en.wikipedia.org/wiki/Memoization) is a technique used to cache the result of a potentially-expensive operation. In our particular case, we’re less concerned with performance-improving caching as we are with saving a **unique value for reuse**. We want the `thing` which gets used repeatedly to always refer to the same object. So let’s rewrite our `thing` method this way:

```ruby
def thing
  @thing ||= Thing.new(:abc)
end
```

This code uses **Ruby’s conditional assignment operator** to either (a) return the value of the `@thing` instance variable, or (b) assign it and _then_ return it. Now it’s assured we’ll never receive more than a single object instance of the `Thing` class. Let’s put it all together:

```ruby
def some_method
  thing.do_something(123) # first call instantiates @thing
  thing.finalize! # second call uses the same @thing
end

def thing
  @thing ||= Thing.new(:abc)
end
```

### What’s Lazy About This?

Let’s take a look at what we might do if we weren’t using the above technique and we needed `thing` available across multiple methods. We might use an approach like this:

```ruby
class ThingWrangler
  attr_reader :thing # create a read-only accessor method

  def initialize
    @thing = Thing.new(:abc) # create @thing when this object is created
  end

  def some_method
    thing.do_something(123)
    thing.finalize!
  end
end
```

Arguably this is an anti-pattern. Because if `some_method` never actually gets called, `thing` was instantiated for nothing—wasting memory and CPU resources. In addition, it makes swapping out the `Thing` class challenging in tests or subclasses because the `Thing` constant is hard-coded into the `initialize` method.

Some might recommend that you reach for the DI (Dependency Injection) pattern instead:

```ruby
class ThingWrangler
  attr_reader :thing

  def initialize(thing:)
    @thing = thing
  end

  def some_method
    thing.do_something(123) # first call instantiates @thing
    thing.finalize! # second call uses the same @thing
  end
end
```

Then you’d simply need to pass an initialized object to the `new` method of `ThingWrangler` from a higher-level:

```ruby
wrangler = ThingWrangler.new(thing: Thing.new(:important_value))
wrangler.some_method
```

Honestly, **I really don’t like DI**. It often makes for cumbersome APIs which are harder to comprehend as well as exposes implementation details to higher levels in situations where it might not even make sense. Do I _really_ need to know that `ThingWrangler` doesn’t work without a `Thing` to rely on? **Probably not**. Contrast that with our friend the “lazily-instantiated memoized dependency” solution:

```ruby
class ThingWrangler
  def initialize(value)
    @important_value = value # we store useful data for future use
  end

  def some_method
    thing.do_something(123) # first call instantiates @thing
    thing.finalize! # second call uses the same @thing
  end

  def thing
    @thing ||= Thing.new(@important_value) # aha! time to use saved data
  end
end

# This level doesn't need to know about the Thing class!
# It also doesn't cause any premature instantiation of @thing:
wrangler = ThingWrangler.new(:abc)

# NOW we call a method which in turn instantiates @thing:
wrangler.some_method
```

[This is one of the solutions to writing “loosely-coupled” object-oriented code](https://www.informit.com/articles/article.aspx?p=1946176&seqNum=2) talked about in Sandi Metz’ book _ Practical Object-Oriented Design in Ruby_.

What’s great about this pattern is it affords you many opportunities for customization. For example, you can write a subclass which swaps `Thing` out entirely! Dig this:

```ruby
class HugeThingWrangler < ThingWrangler
  def thing
    @thing ||= HugeThing.new(@important_value)
  end
end

wrangler = HugeThingWrangler.new(:abc)
wrangler.some_method # uses HugeThing under the hood
```

Or when testing  `ThingWrangler` where you want `Thing` to be a mock object under your control, you could simply stub the `thing` method so it returns your mock instead of the usual  `Thing` instance.

Or if you wanted to get _real wild_, here’s a bit of **metaprogramming** to add custom functionality around the original method:

```ruby
ThingWrangler.class_eval do
  alias_method :__original_thing, :thing

  def thing
    puts "ThingWrangler#thing has been called!"
    obj = __original_thing
    puts "Now returning the thing object!"
    obj
  end
end
```

Now every time `ThingWrangler` accesses `thing` internally, your custom code will get run. (Careful out there!)

### Some Important Caveats

A memoized method shouldn’t be reliant on changing data, because its job is to return a single instance of `Thing` that gets cached and won’t ever change. So if you had code that looks like this:

```ruby
def value_change(new_value)
  thing = Thing.new(new_value)
  thing.perform_work
end
```

You can’t memoize that instantiation, because you need a new `Thing` instance every time. _However_, what you could do instead is **memoize the class itself!** 🤯

```ruby
def changing_values(new_value)
  thing = thing_klass.new(new_value)
  thing.perform_work
end

def thing_klass
  @thing_klass ||= Thing
end
```

This still provides many of the benefits of the techniques we’ve described in terms of allowing subclasses to alter functionality, mock objects in tests, etc. Depending on the needs of your API, you might even want to create a configuration DSL to allow that `Thing` constant to be officially customizable by consumers of your API. (And to reiterate, still no DI techniques required!)

One other caveat is if the original memoization method is overly complicated or reliant on internal implementation details, you could get into trouble with future subclasses.

```ruby
class ParentClass
  def dependency
    @dependency ||= DependentClass.new(lots, of, input, values)
  end
end

class ChildClass < ParentClass
  def dependency
    # Hmm, what if the parent class changes internally and I don't?!
    @dependency ||= AnotherDependentClass.new(what, should, go, here)
  end
end
```

In fact, expensive custom logic typically isn’t compatible with the memoization technique as-is. Instead, a good pattern (if possible) to use for your dependency is simply to be given a reference to the calling object itself:

```ruby
class ParentClass
  def dependency
    @dependency ||= DependentClass.new(self)
  end
end

class ChildClass < ParentClass
  def dependency
    @dependency ||= AnotherDependentClass.new(self)
  end
end
```

That way, it’s up to the dependency to glean any relevant data from the calling object in order to perform its work when required. This technique is used frequently across the [Bridgetown project](https://www.bridgetownrb.com) which I maintain.

For more on the benefits and caveats around memoization, [read this article by "another" Jared (Norman)](https://supergood.software/class-methods-and-memoization/). 😄

### Conclusion: Trust Your LIM

The Lazily-Instantiated Memoization technique is a powerful one and, when used appropriately and in a consistent fashion, it will help your objects become more modular and more easily customized and tested. Consider it whenever you need to manage dependencies within your Ruby code. {%= ruby_gem %}