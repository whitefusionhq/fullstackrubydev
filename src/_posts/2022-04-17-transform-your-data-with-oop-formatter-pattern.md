---
title: Transform Your Data Object-Oriented Style with Formatters
subtitle: I truly adore this design pattern. Once you know it, you start to see its usefulness across a wide variety of scenarios, codebases, and even programming languages.
categories:
- Object Orientation
author: jared
image: "/images/posts/so-many-roads.jpg"
image_hero: "/images/posts/so-many-roads.jpg"
image_credit:
  url: https://unsplash.com/photos/SXsxdZ5shaw
  label: Mukund Nair on Unsplash
---

I admit it. I'm a design pattern nerd. I've been a massive fan of object-oriented design patterns ever since I read [Patterns of Enterprise Application Architecture](https://www.martinfowler.com/books/eaa.html) in the mid-2000s. One of the aspects which first drew me to Ruby, via Rails, was the in-depth adoption of so many of these patterns and how easy it is to write elegant Ruby code using OOP (Object-Oriented Programming) design patterns.

Today, we'll talk about a variant of the [Template Method design pattern](https://en.wikipedia.org/wiki/Template_method_pattern) I've used in a number of scenarios. I don't know of a formal name for this pattern, so I like to call it the Formatter pattern. By executing a sequence of formatters, you achieve a process which I think of as a **data pipeline**. The data pipeline itself can also be represented as an object.

(At first glance, you might think this pattern is better described as a [Chain of Responsibility](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern), but that pattern is better suited to cases where each link in the chain should determine whether it can handle all processing and stop, or pass some of the processing directly on to the next link in the chain.)

### Perfect for Refactors

The Formatter pattern is so useful that I recently refactored a huge "spaghetti function" in a TypeScript (yes, _that_ TypeScript) codebase to use this OOP pattern instead. The number of bugs and "gotchas" working with that part of the codebase plummeted to nearly zero—_and_ we were able to write unit tests for each formatter in the pipeline to verify the data transformations therein.

It's safe to say that you wouldn't necessarily reach for the Formatter pattern the moment you need to author a sequence of steps to transform some data. Rather, you'd start by writing your code in a simple linear fashion, and then as you slowly begin to realize your process is turning into a [big ball of mud](https://en.wikipedia.org/wiki/Big_ball_of_mud), it's time to refactor. ([Remember DOEY!](/the-art-of-code/2022/02/11/dry-doey-dont-overexert-yourself/))

**NOTE:** fans of functional programming, you'll probably want to leave now. This pattern encompasses everything you _don't_ like about object-oriented programming: abstract classes, inheritance, encapsulation, mutation, and polymorphism. So don't **at** me—you've been warned!

### The Format of Formatters

Formatters in a particular data pipeline all inherit from a base class. Let's create a new `ExampleFormatters` Ruby module to house our `Base` class and future subclasses:

```ruby
module ExampleFormatters
  class Base
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def format
      raise "Method should be implemented in subclass"
    end
  end
end
```

You can name the `format` method however you wish—perhaps in your case `convert` would be more appropriate. At any rate, the idea here is you pass a data object of some type into your initializer, and then by calling the `format` method, a transformation would occur for that data. Let's implement a subclass to see this in action (and let's assume the data object is a `Hash`):

```ruby
module ExampleFormatters
  class TitleFormatter < Base
    def format
      # ensure the title string is in Title Case
      data[:title] = data[:title].split.map do |str|
        str.capitalize
      end.join(" ")

      self
    end
  end
end
```

Now let's call this formatter with some data:

```ruby
hsh = { title: "hello   world!" }

p ExampleFormatters::TitleFormatter.format(hsh).data

# => {:title=>"Hello World!"}
```

Note that we're not returning a copy of the data object. We're mutating the data in-place. This is by design (generally better performance and lower memory usage). So in the above example, both `hsh` and the `data` method are equivalent after running the formatter. If you need to preserve the original state of the data, you should ensure you make a duplicate object before passing that along to the formatters—perhaps in the data pipeline (described further below).

This is the most basic example of how to write a formatter. However, you might want to add a bit of smarts, such that you can't run `format` more than once on the same dataset. We can change our base class then to this:

```ruby
module ExampleFormatters
  class Base
    attr_reader :data

    def initialize(data)
      self.data = data
    end

    def data=(new_data)
      @already_formatted = false
      @data = new_data
    end

    def format
      if @already_formatted
        raise "Cannot run formatter a second time on the same dataset."
      end
  
      process

      @already_formatted = true

      self
    end

    protected

    def process
      raise "Method should be implemented in subclass"
    end
  end
end
```

Now refactor your subclasses to override `process` rather than `format`:

```ruby
module ExampleFormatters
  class TitleFormatter < Base
    protected # keep `process` hidden from the public API:

    def process
      # ensure the title string is in Title Case
      data[:title] = data[:title].split.map do |str|
        str.capitalize
      end.join(" ")

      self
    end
  end
end
```

This will ensure you can only run `format` once on the same data. In order to run it again, you'll need to use `formatter.data = some_new_data` to reset the process.

One reason it's so nice to have a base class from which to inherit is you can add to the base API and your formatter subclasses will have full access to those methods. For instance, if this "titleize" formatting is something you'll need to do several times across different formatters, you can abstract the implementation:

```ruby
module ExampleFormatters
  class Base
    # …
    
    # convert a "lower   case" string to "Title Case"
    def titleize(str)
     str.to_s.split.map do { |str| str.capitalize }.join(" ")
    end  
  end
end
```

```ruby
module ExampleFormatters
  class TitleFormatter < Base
    protected # keep `process` hidden from the public API:

    def process
      data[:title] = titleize(data[:title])

      self
    end
  end
end
```

Not only does this DRY up your code, but it fixes a subtle bug as well. Before, if `data[:title]` was `nil`, your code would error and crash. Now, by using a separate method which is written defensively (i.e., don't naively assume the incoming object will always be a `String`), the worst you'll get is a value of `""`. If a blank string itself will cause a problem down the road, make sure you write _that_ code defensively as well!

### Constructing the Data Pipeline

Now that we have some formatters working and transforming our data in bite-sized pieces, we need a way to kick off the whole process. Let's write our data pipeline object. You'll notice it contains some similar shapes to the formatter base class.

```ruby
class ExampleDataPipeline
  attr_reader :data

  def initialize(data)
    self.data = data
  end
  
  # Construct the sequence of formatters for the pipeline.
  # Modify or add to this list to update the pipeline:
  def formatters
    [
      TitleFormatter,
      DatesFormatter,
      LineItemsFormatter,
      # future formatters here
    ]
  end

  def data=(new_data)
    @already_formatted = false
    @data = new_data.dup # make a shallow clone
  end

  def run
    if @already_formatted
      raise "Cannot run pipeline a second time on the same dataset."
    end

    formatters.each do |formatter_class|
      formatter_class.new(data).format
    end

    # further processing here?

    @already_formatted = true

    data
  end
end
```

For the final step, you can run the pipeline with a single statement!

```ruby
transformed_data = ExampleDataPipeline.new(input_data).run
```

**Boom.**

And thanks to the power of object-oriented programming, you can easily experiment with your pipeline—for example by changing the order of formatters or swapping out one formatter for another.

```ruby
class FasterDataPipeline < ExampleDataPipeline
  def formatters
    [
      TitleFormatter,
      DatesFormatter,
      FasterLineItemsFormatter
    ]
  end
end

# Try benchmarking these two pipelines…

ExampleDataPipeline.new(input_data).run
# vs.
FasterDataPipeline.new(input_data).run
```

It goes without saying that unit testing formatters in isolation will ensure your formatters don't become too dependent on each other (aka it would be **bad** if a formatter only worked if executed after another particular formatter).

### Audit Trails? External APIs? Dynamic Converters?

You can build upon this pattern in increasingly sophisticated ways as your business logic needs grow. One idea might be to log the before/after of each formatter as it runs in the pipeline in order to performing an audit of data integrity after the fact. Another idea might be to encapsulate expensive or complex external API calls within formatters so you can work with your overall pipeline steps at a higher level without messy API calls getting in your way. (And then swapping those formatter(s) out with stubs during unit tests becomes quite straightforward.)

In [Bridgetown](https://www.bridgetownrb.com), the subsystem of template converter plugins (which itself is based on Jekyll's converter subsystem) is architected in a similar fashion to this Formatter pattern. In the Bridgetown case, the order of converters (aka formatters) is determined by a priority designation. High priority converters run first, then medium priorities, then lower priorities. In Bridgetown, I actually did implement an "audit trail" for the conversions, so if you're curious how a particular resource changed throughout all the conversions, you can inspect that trail and see the state of the template before/after a particular conversion. The precise nature of the converter pipeline is constructed based on extension matches or other metadata (aka `.liquid` will be converted differently from `.erb`). Your data pipeline might similarly need to dynamically construct its list of formatters based on the nature of the incoming data.

In summary, I truly adore this design pattern. Once you know it, you start to see its usefulness across a wide variety of scenarios, codebases, and even programming languages! {%= ruby_gem %}