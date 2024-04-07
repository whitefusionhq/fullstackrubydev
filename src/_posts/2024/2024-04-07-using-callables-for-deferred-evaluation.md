---
date: Sun, 07 Apr 2024 10:34:02 -0700
title: Using Lambdas and Callables for Deferred Evaluation, Control Flow, and New Language Patterns
subtitle: Something which confused me early on as I learned Ruby was when to write a block vs. lambda. Here are my detailed thoughts around the distinctions and the possibilities.
categories:
- Syntax and Metaprogramming
---
 
Ruby blocks are simply amazing, and I’ve written about [some of the cool things](https://www.fullstackruby.dev/syntax-and-metaprogramming/2020/11/19/where-do-blocks-come-from/) you can do with them.

But something which confused me early on as I learned Ruby and started using gems and frameworks was when to write a block vs. when to write an explicit proc or lambda.

For example, [here’s some example code provided by Faraday](https://lostisland.github.io/faraday/#/getting-started/quick-start?id=using-middleware), a popular HTTP client for Ruby:

```ruby
conn = Faraday.new(url: 'http://httpbingo.org') do |builder|
  builder.request :authorization, 'Bearer', -> { MyAuthStorage.get_auth_token }
  # more code here...
end
```

As you can see, there are _two_ different use of blocks/procs here. The first one is the one passed to `Faraday.new` — it yields `builder` so you can configure the request. But the second one is a “stabby lambda” (`-> {}`) which is passed to the authorization configuration. Why do it this way? I mean, in theory you could write an API which swaps the two:

```ruby
weird_conn = Appleaday.new("keeps the doctor away!", ->(builder) {
  builder.make_me_a(:treehouse, 'Painted') { MyFavoriteColors.default }
})
```

Now I don’t have a particularly valid technical reason why the Faraday syntax is “correct” and my silly example is not. The simplistic answer would be “idiomatic Ruby”. We know it when we see it, and otherwise it looks off.

But I think that’s a cop-out. There _must_ be some greater heuristic we can keep top of mind as we evaluate the best shapes for an API.

Here are some thoughts I have as I study these sorts of APIs and design new ones in my own apps and gems.

## Deferring Evaluation

Let's start with blocks. In the original Faraday example, using a block to provide configuration via the `builder` local variable is a very common Ruby pattern and lies at the heart of many DSLs. Some APIs provide a block without even yielding a variable, in which case you’re calling methods on the DSL object directly—like in [Rodauth](https://github.com/jeremyevans/rodauth#label-Usage):

```ruby
plugin :rodauth do
  enable :login, :logout
end
```

In this example, `enable` is a method of the DSL object that is the execution context of the block. If this were written like Faraday’s API instead, it might instead look like this:

```ruby
plugin :rodauth do |config|
  config.enable :login, :logout
end
```

You with me? Cool. So blocks are great for configuration DSLs and for setting up various sorts of “declarative” data structures. Heck, what is a `.gemspec` file if not a DSL using a block?

```ruby
# faraday.gemspec

Gem::Specification.new do |spec|
  spec.name    = 'faraday'
  spec.version = Faraday::VERSION
  # etc.
end
```

OK, but what about lambdas? When is it appropriate to use a lambda instead of just a typical block? (FWIW I just _love_ stabby lambdas…aka the `-> (variables) { ... }` syntax as opposed to `lambda { |variables| ... }`.)

I think it makes a lot of sense to use lambdas when you need to **provide an expression which later gets resolved to a value**—perhaps over and over again. We might call this **deferred evaluation**. Some APIs for example will accept either a data value or a lambda…the data expression would be evaluated right at the call site, but the lambda would be evaluated at runtime when it’s needed.

```ruby
HypotheticalConfiguration.new do
  immediate_evaluation Time.now
  deferred_evaluation -> { Time.now }
end
```

In this example, the hypothetical configuration option has been provided two settings. The first setting receives the _current time_. That setting can never change—whatever the current time was when the statement was evaluated has been "baked" into the configuration. However, the second setting receives a lambda. Executing this lambda returns the current time _at the time the setting is later accessed_. Each occurrence of runtime logic accessing that setting would get the time _at that precise moment_, not a previous time when the configuration was created.

**Here's a real-world example.** In the Bridgetown web framework I work on, this is part and parcel of our “[Ruby front matter DSL](https://www.bridgetownrb.com/docs/front-matter#the-power-of-ruby-in-front-matter)”. Front matter is resolved immediately when a page template is read, which occurs at an earlier time than when a page template is transformed (aka rendered) to its final format (typically HTML). In an example provided by the Bridgetown documentation:

```markdown
~~~ruby
# some_page.md
front_matter do
  layout :page

  url_segments = ["custom"]
  url_segments << "permalink"
  segments url_segments

  title "About Us"
  permalink -> { "#{data.segments.join("/")}/#{Bridgetown::Utils.slugify(data.title)}" }
end
~~~

This will now show up for the path: **/custom/permalink/about-us**.
```

Here we see code providing front matter variables such as `layout`, `segments`, and `title`. But it’s also providing a lambda for `permalink`. Because the value of `permalink` is a lambda, Bridgetown knows that at the time it’s about to transform the page template, it should then resolve that expression to the `permalink` variable.

We don’t use standard blocks for this because we _also_ allow nested data structures via standard blocks. So you’d mix and match depending on the use case. For example:

```ruby
front_matter do
  image do
    url "/path/to/image.jpg"
    alt -> { "My alternative text for #{data.title}" }
  end

  title "My Wonderful Page"
end
```

Here we can see there’s an `image` variable which will resolve to a hash: `{ image: "/path/to/image.jpg", alt: -> { ... } }`. Because the value of `alt` is a lambda, it will resolve when the page renders to become `"My alternative text for My Wonderful Page`. We can then use those variables in the template:

```erb
<img url="<%= data.image[:url] %>" alt="<%= data.image[:alt] %>" />
```

## Controlling the Flow

Another interesting use of lambdas I’ve experimented with at various times is utilizing them in control flow scenarios. For instance, did you know you could write your _own_ `if` and `unless` statements?

```ruby
def do_if(condition, &block)
  condition.().then { _1 ? block.(_1) : nil }
end

def do_unless(condition, &block)
  condition.().then { _1 ? nil : block.(_1) }
end

a = 123

do_if -> { a == 123 } do |result|
  puts "it's #{result}" # => "it's true!"
end

unless_if -> { a == 123 } do |result|
  puts "it's #{result}" # => oops, this never gets run!
end
```

Now I don’t exactly know why you’d write anything like this, other than as a cool experiment. But maybe you need to write a method which takes two lambdas, one for the “success” case and one for the “failure” case:

```ruby
def perform_work(value:, success:, failure:)
  go_do_other_stuff(value) => result

  result.completed ? success.(result) : failure.(result)
end

perform_work value: [:abc, 123],
             success: ->(result) do
               puts "Yay, it was a success! #{result.output}"
             end,
             failure: ->(result) do
               raise "Darn, we blew it. :( #{result.problem}"
             end
```

Sure you could write this another way, like if `perform_work` yielded a config object and you could pass blocks to its `success` and `failure` methods. But the nice thing about this pattern is you could use other object methods instead by converting them into lambda-like callables. Oh yes!

```ruby
def time_for_work(value)
  perform_work value:, success: method(:success), failure: method(:failure)
end

def success(result)
  puts "Yay, it was a success! #{result.output}"
end

def failure(result)
  puts "Darn, we blew it. :( #{result.problem}"
end
```

Because you can call lambdas and Method objects the same way, the API doesn’t need to care which is which.

```ruby
# calling a lambda
my_lambda.call(:abc)
# or my preferred syntax:
my_lambda.(:abc)

# calling a method object
my_method.(:abc)

# did you know any object can be callable
# if it responds to a `call` method?
class MyCallable
  def call(value)
    "Value is: #{value}"
  end
end

MyCallable.new.(123) # => 123
```

So actually with that last example, we see that you can pass _any_ callable object to an API which accepts lambdas (more or less). How cool is that?!

Wait, could we try that with our earlier `do_if` example?

```ruby
class ValueCallable
  def initialize(value)
    @value = value
  end

  def call
    @value
  end
end

do_if ValueCallable.new(123) do |result|
  puts "it's as easy as #{result}" # => "it's as easy as 123!"
end

do_if ValueCallable.new(nil) do |result|
  puts "nope" # this never executes
end
```

And if we wanted to make that _ever slicker_, we could make the class itself callable!

```ruby
class ValueCallable
  def self.call(...)
    # forward all arguments
    new(...).call
  end

  # ...
end

MyCallable.(123) # => new instance of MyCallable with @value: 123
```

## Discovering New Language Patterns

I hope you’re starting to get a sense for how understanding the difference between blocks and lambdas—or perhaps we just think of them as “callables”—can help you build more expressive APIs utilizing modular building-blocks which offer deferred evaluation, control flow, and entirely new patterns.

**This is what I love so much about Ruby.** We think of Ruby as a programing language, and it certainly is—and a “high level” one at that with an impressive heaping of abstractions. When “all cylinders are firing”, “programmer happiness” ensues.

But Ruby goes even a step beyond. Because of the expressiveness of the syntax Ruby provides us, we can in a sense _write our own languages_. Our APIs can have an advanced shape, with many affordances people typically assume must be baked into the language itself.

I’ve been hard at work on [Bridgetown 2.0](https://www.bridgetownrb.com/blog), and one of the areas of improvements I hope to focus on is our use of blocks vs. callables and the distinction between the two. Blocks are so easily used (and abused!), but I think **the callable pattern may be one of Ruby’s best unsung heroes**. The fact you can not only pass a lambda but _any_ object method or really _any_ object of any kind as a “callable” is, well, pretty mind-blowing.

I’ll close with one more **wild factoid** I always forget until I remember…you can convert methods directly to procs! What's the point of doing that? Because then you can pass your callables into any standard methods which expect blocks. _Like, for real!_

```ruby
class MultiplyNumber
  def initialize(multiplicand)
    @multiplicand = multiplicand
  end

  def call(multiplier)
    @multiplicand * multiplier
  end

  def to_proc = method(:call).to_proc
end

multi = MultiplyNumber.new(10)

[1, 2, 3].map(&multi) # => [10, 20, 30]
```

Ruby is so weird. _I love it._ {%= ruby_gem %}
