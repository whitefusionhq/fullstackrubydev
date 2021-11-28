---
layout: home
exclude_from_search: true
---

{%= liquid_render "sponsor" %}

{{ site.metadata.description | sub: "Futuristic #WebDev That’s Fast and Fun. ", "" }}
{:.has-text-weight-bold .has-text-centered .mt-6}

[Read our tidy little manifesto](/about) or explore the articles below.
{:.has-text-weight-bold .has-text-centered}

{%= liquid_render "subscribe" %}

----
{: .my-6}

# Latest Articles
{: .mb-6 .title .has-text-centered}

{% posts = collections.posts.resources[0...4] %}
{%= liquid_render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{% if collections.posts.resources.size > 4 %}
  <a href="/articles" class="button is-primary is-outlined is-small"><span>Previous Articles</span> <span class="icon"><i class="fa fa-arrow-right"></i></span></a>
  {: .mt-6 .has-text-centered}
{% end %}


<p class="mt-6 is-size-7 has-text-centered"><em>Banner image by <a href="https://unsplash.com/photos/g9Ek7TzdMVc">Aldebaran S on Unsplash</a></em></p>
