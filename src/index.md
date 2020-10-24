---
layout: home
---

{% render "sponsor" %}

{{ site.metadata.description | replace: "It was dawn of the third age of Ruby… <br/><br/>", "" }}
{:.has-text-weight-bold .has-text-centered .mt-6}

[Read our tidy little manifesto](/about) or explore the articles below.
{:.has-text-weight-bold .has-text-centered}

{% render "subscribe" %}

----
{: .my-6}

# Latest Articles
{: .mb-6 .title .has-text-centered}

{% assign posts = site.posts | slice: 0, 4 %}
{% render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{% if site.posts.size > 6 %}
  <a href="/articles" class="button is-primary is-outlined is-small"><span>Previous Articles</span> <span class="icon"><i class="fa fa-arrow-right"></i></span></a>
  {: .mt-6 .has-text-centered}
{% endif %}


<p class="mt-6 is-size-7 has-text-centered"><em>Hero image by <a href="https://unsplash.com/photos/g9Ek7TzdMVc">Aldebaran S on Unsplash</a></em></p>