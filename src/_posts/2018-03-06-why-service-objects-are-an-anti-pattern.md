---
title: "Why Service Objects are an Anti-Pattern"
subtitle: "Article after article has been published in recent years about the benefits of adding service objects to Rails applications. I’m here to tell you they’re wrong. There is a better way."
categories:
- Object Orientation
layout: post
author: jared
image: "/images/posts/software-patterns.jpg"
image_hero: "/images/posts/software-patterns.jpg"
rainbow_hero: true
---

I have been vocal from time to time in internet discussions regarding service objects and why I believe they are the wrong solution to a legitimate problem. In fact, not only do I think better solutions exist than service objects in the majority of cases, I maintain that service objects are an _anti-pattern_ which indicates a troubling lack of regard for sound object-oriented design principles.

![What if I told you that adding service objects doesn't make your Rails codebase any better](/images/posts/what-if-i-told-you-adding-service-objects-doesnt-make-your-rails-codebase-any-better.jpg){:style="border: 5px solid #8a1024;width:100%"}
{:.has-text-centered .mx-auto .my-5}
{:style="max-width:500px"}

It’s hard to get such lofty points across in a random tweet here or comment there. So I decided to write this article and dig into some real-world code that illustrates my position precisely.

**_Quick Aside:_** If you read this article and still think I'm off my rocker, [here's another recent take on the subject (with code examples!) by Jason Swett](https://www.codewithjason.com/rails-service-objects/) that I think does a great job illustrating the issue.<br/>&nbsp;

So…what do I mean when I use the term _anti-pattern_? Here’s a reasonable description from StackOverflow:

> Anti-patterns are certain patterns in software development that are considered bad programming practices. As opposed to design patterns which are common approaches to common problems which have been formalized and are generally considered a good development practice, anti-patterns are the opposite and are undesirable.
>
> <footer><p markdown="1">Source: [https://stackoverflow.com/a/980616](https://stackoverflow.com/a/980616)</p></footer>

In order to demonstrate why I don’t like service objects, I’m going to look at some code I inherited from a past development team for a client project. I can’t go too much into context since this application is still in private beta, but let’s just say it’s a social platform where you can rate media (images or videos) and those ratings trigger certain callback-style actions such as updating algorithmic data and adding activities to various users’ timelines.

We have a pretty simple data model where a `Rating` object can be created in the database that `belongs_to` both a `User` object and a `Media` object (all these examples are shortened from the production files):

```ruby
class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :media
end
```

```ruby
class Media < ActiveRecord::Base
  has_many :ratings
end
```
You get the idea. Now in order to handle an incoming rating from a user, the previous developer created a service object called `MediaRating` which gets called from the controller:

```ruby
class MediaRating
  def self.rate(user, media, rating)
    mr = MediaRating.new(user)
    rating_record = mr.update_rating(media, rating)
  end

  def initialize(user)
    @user = user
  end

  def update_rating(media, rating)
    rating_record = @user.ratings.where(media: media).first
    if rating_record.nil?
      # do create stuff
    else
      # do update stuff
    end

    # do some extra stuff here like run algorithmic data processing,
    # add social activities to timelines, etc.
  end
end
```

And here’s the relevant controller code:

```ruby
media = Media.find(params[:media_id])
rating = params[:rating].to_i
MediaRating.rate(current_user, media, rating)
```

Bear in mind that this code was originally written quite a while ago. These days, all the cool cats writing service objects have settled on a bit of formality in terms of the API presented, so if I were to rewrite this service object, I’d probably do something like this:

```ruby
# add this to Gemfile:
gem 'smart_init'

class UserMediaRater
  extend SmartInit

  initialize_with :user, :media, :rating
  is_callable

  def call
    rating_record = @user.ratings.where(media: @media).first
    # etc.
  end
end

# updated command from the controller:
UserMediaRater.call(current_user, media, rating)
```

### Problem Time

Now this code doesn’t look so bad, right? It seems pretty clean and well-structured and easy to test. Well, the problem is that what you are seeing here is my polished up, greatly simplified version of this service object. The actual one in the codebase is 74 lines of spaghetti code with methods calling other methods which call other methods because the code to trigger algorithmic data processing and timeline updates and so forth is all shoehorned into this one service object. So actually, the flow is more like this:

> Controller \> Service Object \> Rate Method \> Update Rating \> Some Other Update Method + (Run Algorithm \> Refresh Related Data), then Invalidate Caches + Add Timeline Activities

So every time I open up the codebase fresh and want to look at the block of code that simply creates or updates a rating of a media object by a user, I’m forced to wade through a bunch of ancillary functionality to get at the basic code path.

_Well_, you might say, _that developer obviously didn’t do a very good job writing the service object! They should have kept it simple and focused, and instead put additional processing code in other objects (maybe even other service objects!)_

Now wait a minute! The **whole reason** we are told we need to extract code contained within standard Rails MVC patterns into service objects is because they help us break up complex code flows into standalone functions. But the problem is that there’s nothing to enforce that rule. _Nothing!_ You can write a simple service object, no doubt about it. But you can equally write a complex service object containing a bunch of methods that quickly turn into spaghetti code.

What does this mean? It means **the service object pattern has no intrinsic ability to make your codebase easier to read, easier to maintain, simpler, or exhibit  better separation of concerns**.

If a pattern can foster nearly any sort of programming style with a nearly infinite spectrum of simple to highly complicated, then it ceases to be a useful pattern and describes nothing specific to developers.

### So What Should We Do Instead?

When I’m preparing to write a fair bit of code that I know will have to process incoming data and either create or update records along with other related functionality, I typically start by writing a class method on the most appropriate model. Now hold your horses, I’m not saying this is a superior pattern. I’m saying this is where I begin, _before_ I start looking for another pattern that might be a better fit.

Let’s take a look what what it might look like if rating media were done using a class method on `Rating` itself:

```ruby
class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :media

  def self.rate(user, media, rating)
    rating_record = Rating.find_or_initialize_by(user: user, media: media)
    rating_record.rating = rating
    rating_record.save

    # do some extra stuff here like run algorithmic data processing,
    # add social activities to timelines, etc.
  end
end
```

And the updated controller code:

```ruby
media = Media.find(params[:media_id])
rating = params[:rating].to_i
Rating.rate(current_user, media, rating)
```

Now I’m already breathing a sigh of relief when I read this code, because putting the rating code directly in the `Rate` model ensures that the functionality is closer to the data structures that are most impacted by the code.  Want to open up the codebase and find out how to rate something? Look in the `Rate` model! It’s very straightforward.

_However_...I’m ultimately still not happy with this code for one big reason. As a rule of thumb, I like to call instance methods and use Rails associations whenever possible. To me it’s code smell to sprinkle class methods all over the place and avoid using associations and standard OOP principles as intended.  In this case, it seems weird to me that I can’t do something along the lines of `@media.rate` in the controller.  After all, I’m loading up a media object and I want to rate it. Why isn’t there a clear interface to do that?

### Concerns and POROs are Your Friends

Once I’m convinced I need to start moving complex code out of a model class method, I’m going to want to find a better pattern than just stuffing a bunch of bits into various models’ instance methods. After all, the problems that come with fat models is why people recommend breaking code out into service objects in the first place!

But in reality, the downsides of fat models isn’t so much that you have a single object with a lot of methods, it’s that those methods (and presumably related unit tests) are all jumbled together in one file. What you really need is a way to keep bits of key functionality separated out from other bits of key functionality in terms of code comprehension, and then you need some sort of rule of thumb for which bits of code really should be relocated into separate objects altogether.

Let’s take a look at what we could do with this media rating business. First, I’m going to extract the chunk of code we’ve been wrestling with into a concern (which is just a slightly enhanced Rails version of the standard Ruby mixin). Let’s call this concern `Ratable`:

```ruby
module Ratable
  extend ActiveSupport::Concern

  included do
    has_many :ratings
  end

  def create_or_update_user_rating(user:, rating:)
    rating_record = ratings.find_or_initialize_by(user: user)
    rating_record.rating = rating
    rating_record.save

    # do some extra stuff here like run algorithmic data processing,
    # add social activities to timelines, etc.

    rating_record
  end
end
```

The `Media` class now benefits as well, as we can take that `has_many :ratings` directive out and keep that contained within the new concern:

```ruby
class Media < ActiveRecord::Base
  include Ratable
end
```

And the updated controller code:

```ruby
rating = params[:rating].to_i
Media.find(params[:media_id]).create_or_update_user_rating(
  user: current_user,
  rating: rating
)
```

Ah, this is already feeling much better. All I have to do in the controller is find the media object and call a single instance method that’s clearly named as to what it does. It’s a friendly interface that feels Rails-y in the best possible way.

There’s still a problem though. This `create_or_update_user_rating` method is trying to do way too much. It makes sense to handle the database access here, but the algorithmic data processing and timeline updates seem like actions that should be triggered to happen after the fact and defined someplace else.

The standard Rails way would be to put this code into ActiveRecord callbacks. Now I have no problem with callbacks, and I’ll gladly use them if it feels like a reasonable fit. But in this case, the two main things that need to happen seem like totally unrelated bits of functionality that are only tangentially related to the particular media, rating, and user objects involved.

So let’s use this opportunity to do some proper domain modeling and move that extra functionality out of the concern and into other POROs. We’ll keep our `create_or_update_user_rating` method nice and simple by pointing to those new objects:

```ruby
def create_or_update_user_rating(user:, rating:)
  rating_record = ratings.find_or_initialize_by(user: user)
  rating_record.rating = rating
  rating_record.save

  # Let's extract out additional functionality to POROs or relevant models.
  # Better yet, encapsulate these into background jobs?
  # Left as an exercise for the reader...
  Rating::Processor.run(rating_record)
  Timeline::Activities.add_for_rating(rating_record)

  rating_record
end
```

Now before you start to get twitchy there, `Rating::Processor` and `Timeline::Activites` aren’t more “service objects.” These are POROs (Plain Old Ruby Objects) that are modeled using carefully considered OOP paradigms. One object is what I call a “processor” pattern: it takes input, crunches some numbers, and then saves the output somewhere. The other is a collection pattern that manages adding and removing items and the consequence of those actions. Nothing fancy or original here, but that’s the point.

We could have attempted to use the service object pattern here instead, perhaps by refactoring `UserMediaRater` to call additional services objects such as `ProcessNewRating` and `AddTimelineActivityForRating`. But how is that any more readable or any more well-structured than using concerns and POROs? Instead of succumbing to a huge `app/services` folder filled with what are essentially functions, we can engage instead in real domain modeling to come up with class names, data structures, and object methods that are designed for readability and ease of use.

And that’s my final point: **using concerns and POROs instead of service objects encourages better interfaces, proper separation of concerns, sound use of OOP principles, and easier code comprehension.**

I’m out of time to talk about testing strategies, but if you’re worried that using concerns or more advanced POROs will cause additional problems with your tests as compared with service objects, here are a couple of useful resources:

* [On Writing Software Well—Video by David Heinemeier Hansson](https://youtu.be/5hN6OZDyQtk)
* [Speed up Rails tests 10x by using PORO domain models](http://blog.honeybadger.io/poro-plain-old-ruby-object-tests-and-specs/)

There’s a lot more I could talk about regarding how model or controller-level Rails concerns combined with useful PORO patterns is a better fit than service objects in the vast majority of cases, so keep an eye out for future articles in this vein.

**TL;DR:** service objects are crappy and better solutions exist most of the time. Please use those instead. Thank you!

_Send your thoughtful, rage-free responses to [@jaredcwhite](https://twitter.com/jaredcwhite)_ 😊

