---
title: "Adding and Merging ActiveRecord Relations"
subtitle: "The expressive possibilities of assembling ActiveRecord queries out of disparate parts make using Rails so fun."
categories:
- Rails
layout: post
author: jared
image: /images/posts/colorful-prism.jpg
image_hero: /images/posts/colorful-prism.jpg
---

An intriguing scenario arose in a project I was working on. In this application, creators can create plugin presets. Presets themselves are associated with "banks" — aka a bank `has_many` presets. There are also actions that can be taken against either banks or presets: users generally will bookmark them or download them. Thus these actions have a _polymorphic_ association with both presets and banks.

What I wanted to do was package up all the actions users had performed for banks and related presets created by a particular creator. The resulting ActiveRecord query I arrived at expresses that well. Could this be refactored in a more performant way? (For example, using only one SQL query instead of three?) Very likely. But as this code is run only infrequently for reporting reasons, it's a reasonable tradeoff between performance and readability.

Here's the code for the `ItemAction.for_creator(creator_profile)` method:

```ruby
class ItemAction < ApplicationRecord
  belongs_to :actionable, polymorphic: true
  enum action_type: [ :bookmark, :download, :publish ]

  def self.for_creator(creator_profile)
    banks = creator_profile.banks.published.select(:id)
    presets = Preset.where(bank: banks).select(:id)

    where(actionable: banks + presets).merge(
      ItemAction.bookmark.or(
        ItemAction.download
      )
    )
  end

  # other code, etc.
end
```

First, we get the list of banks. We use a `published` scope to limit the list to only banks which have been made available to the public. Also, we only need the id field back, not all the fields in the database table.

Second, we get the list of presets for those banks, again pulling in only the id field.

The last line of the method is where things get interesting. We want actions where the `actionable` association brings in both the banks and the presets we've loaded, so we use the `+` operator to concatenate both result sets together. Once we have that relation, we can use ActiveRecord's `merge` functionality to pull in additional scopes that specify we only want either `bookmark` or `download` actions. We don't want any other actions (say, `publish`), because those are actions taken by creators, not end users.

And that does the trick! Yay! A brief but useful example of the expressive power of adding and merging ActiveRecord relations together to get a final result.

_Cover: [Michael Dziedzic on Unsplash](https://unsplash.com/photos/dSyhpTGhNHg)_
{:.is-size-7 .mt-5}
