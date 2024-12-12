---
date: Thu, 12 Dec 2024 11:40:08 -0800
title: Tired of Dealing with Arguments? Just Forward Them Anonymously!
subtitle: We have new syntactic sugar options available to use we didn’t before. Let’s take a look!
category: Ruby 3 Fundamentals
---

I don't know about you, but after a while, I just get tired of the same arguments. Wouldn't it be great if I could simply _forward_ them instead? Let somebody else handle those arguments!

OK I kid, I kid…but it's definitely true that argument forwarding is an important aspects of API design in Ruby, and **anonymous argument forwarding** is a pretty awesome feature of recent versions of Ruby.

Let's first step through a history of argument forwarding in Ruby.

----

<aside markdown="1">

**Pedantic Ruby Question:** Are they called method arguments, or method parameters? And when are they called arguments and when are they called parameters? And are keyword arguments also called named parameters?! I'm not entirely sure. I'm just sticking with arguments! 😂

</aside>

----

## The Era Before Keyword Arguments

In the days before Ruby 2.0, Ruby didn't actually have a language construct for what we call keyword arguments at the method definition level. All we had were positional arguments. So to "simulate" keyword arguments, you could call a method with what looked like keyword arguments (really, it was akin to Hash syntax), and all those key/value pairs would be added to a Hash argument at the end.

```ruby
{% capture do %}
def method_with_hash(a, b, c = {})
  puts a, b, c
end

method_with_hash(1, 2, hello: "world", numbers: 123)
{% end.strip => code %}{%= code %}
```

[Run in Try Ruby](https://try.ruby-lang.org/playground/#code={{ code | cgi_escape }}&engine=cruby-3.2.0){: .button}

Fun fact, you can still do this even today! But it's not recommended. Instead, we were graced with true language-level keyword arguments in Ruby 2. To build on the above:

```ruby
{% capture do %}
def method_with_kwargs(a, b, hello:, **kwargs)
  puts a, b, hello, kwargs
end

method_with_kwargs(1, 2, hello: "world", numbers: 123)
{% end.strip => code %}{%= code %}
```

[Run in Try Ruby](https://try.ruby-lang.org/playground/#code={{ code | cgi_escape }}&engine=cruby-3.2.0){: .button}

Here we're specifying `hello` as a true keyword argument, but also allowing additional keyword arguments to get passed in via an argument splat.

Back to the past though. When we just had positional arguments, it was "easy" to forward arguments because there was only one type of argument:

```ruby
def pass_it_along(*args)
  you_take_care_of_it(*args)
end

def pass_the_block_too(*args, &block) # if you want the forward a block
  do_all_the_things(*args, &block)
end
```

There is also a way to say "ignore all arguments, I don't need them" which is handy when a subclass wants to override a superclass method and really doesn't care about arguments for some reason:

```ruby
def ignore_the_args(*)
  bye_bye!
end
```

## The Messy Middle

Things became complicated when we first got keyword arguments, because the question becomes: when you forward arguments the traditional way, do you get real keyword arguments forwarded as well, or do you just get a boring Hash?

For the life of Ruby 2, this worked one way, and then we got a big change in Ruby 3 (and really it took a few iterations before a fully clean break).

In Ruby 2, forwarding positional arguments only would automatically convert keywords over to keyword arguments in the receiving method:

```ruby
def pass_it_along(*args)
  you_take_care_of_it(*args)
end

def you_take_care_of_it(*args, abc: 0)
  puts "#{args} #{abc}"
end

pass_it_along("hello", abc: 123) # ["hello"] 123
```

However, in the Ruby of today, this works differently. There's a special `ruby2_keywords` method decorator that lets you simulate how things used to be, but it's well past its sell date. What you should do instead is forward keyword arguments separately:

```ruby
def pass_it_along(*args, **kwargs)
  you_take_care_of_it(*args, **kwargs)
end

def you_take_care_of_it(*args, abc: 0)
  puts "#{args} #{abc}"
end

pass_it_along("hello", abc: 123) # ["hello"] 123
```

But…by the time you also add in block forwarding, this really starts to look messy. And as Rubyists, who likes messy?

```ruby
def pass_it_along(*args, **kwargs, &block)
  you_take_care_of_it(*args, **kwargs, &block) # Ugh!
end
```

Thankfully, we have a few syntactic sugar options available to use, some rather recent. Let's take a look!

## Give Me that Sweet, Sweet Sugar

The first thing you can do is use triple-dots notation, which we've had since Ruby 2.7:

```ruby
{% capture do %}
def pass_it_along(...)
  you_take_care_of_it(...)
end

def you_take_care_of_it(*args, **kwargs, &block)
  puts [args, kwargs, block.()]
end

pass_it_along("hello", abc: 123) { "I'm not a blockhead!" }
{% end.strip => code %}{%= code %}
```

[Run in Try Ruby](https://try.ruby-lang.org/playground/#code={{ code | cgi_escape }}&engine=cruby-3.2.0){: .button}

This did limit the ability to add anything extra in method definitions or invocations, but since Ruby 3.0 you can prefix with positional arguments if you wish:

```ruby
{% capture do %}
def pass_it_along(str, ...)
  you_take_care_of_it(str.upcase, ...)
end

def you_take_care_of_it(*args, **kwargs, &block)
  puts [args, kwargs, block.()]
end

pass_it_along("hello", abc: 123) { "I'm not a blockhead!" }
{% end.strip => code %}{%= code %}
```

[Run in Try Ruby](https://try.ruby-lang.org/playground/#code={{ code | cgi_escape }}&engine=cruby-3.2.0){: .button}

However, for more precise control over what you're forwarding, first Ruby 3.1 gave us an "anonymous" block operator:

```ruby
{% capture do %}
def block_party(&)
  lets_party(&)
end

def lets_party
  "Oh yeah, #{yield}!"
end

block_party { "baby" }
{% end.strip => code %}{%= code %}
```

[Run in Try Ruby](https://try.ruby-lang.org/playground/#code={{ code | cgi_escape }}&engine=cruby-3.2.0){: .button}

And then Ruby 3.2 gave us anonymous positional and keyword forwarding as well:

```ruby
{% capture do %}
def pass_it_along(*, **)
  you_take_care_of_it(*, **)
end

def you_take_care_of_it(*args, abc: 0)
  puts "#{args} #{abc}"
end

pass_it_along("hello", abc: 123)
{% end.strip => code %}{%= code %}
```

[Run in Try Ruby](https://try.ruby-lang.org/playground/#code={{ code | cgi_escape }}&engine=cruby-3.2.0){: .button}

So at this point, you can mix 'n' match all of those anonymous operators however you see fit.

The reason you'd still want to use syntax like `*args`, `**kwargs`, or `&block` in a method definition is if you need to do something with those values **before** forwarding them, or in some metaprogramming cases. Otherwise, using anonymous arguments (or just a basic `...`) is likely the best solution going, uh, _forward_. 😎

----

<aside markdown="1">

**Background:** you can read about some of the particulars of _how_ we got these features and the personalities involved, as well as some potential gotchas, [here in zverok's excellent writeup](https://zverok.space/blog/2023-11-24-syntax-sugar4-argument-forwarding.html).

</aside>

----

## Do You Need More Advanced Delegation?

There are also higher-level constructs available in Ruby to forward, or _delegate_, logic to other objects:

The [Forwardable](https://ruby-doc.org/3.3.6/stdlibs/forwardable/Forwardable.html) module is a stdlib mixin which lets you specify one or more methods to forward using class methods `def_delegator` or `def_delegators`.

The [Delegator](https://ruby-doc.org/3.3.6/stdlibs/delegate/Delegator.html) class is part of the stdlib and lets you wrap a another class and then add on some additional features.

So depending on your needs, it may make more sense to rely on those additional stdlib features rather than handle argument forwarding yourself at the syntax level.

No matter what though, it's clear we have many good options for defining an API where one part of the system can hand logic off to another part of the system. This isn't perhaps as common when you're writing application-level code, but if you're working on a gem or a framework, it can come up quite often. **It's nice to know that what was once rather cumbersome is now more streamlined in recent releases of Ruby.** {%= ruby_gem %}
