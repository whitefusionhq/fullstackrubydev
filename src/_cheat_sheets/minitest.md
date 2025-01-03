---
title: "Cheat Sheet: Minitest"
---

==WIP — check back soon!==

----

Writing a unit-style test:

```ruby
class TestArrays < Minitest::Test
  def test_array_includes_symbols
    assert_includes [:a, :b], :a
  end
end
```

Writing a spec-style test:

```ruby
describe "namespace support" do
  def to_js(string)
    _(Ruby2JS.convert(string, eslevel: 2017, filters: []).to_s)
  end

  describe "open modules" do
    it "should extend modules" do
      to_js( 'module M; def f(); end; end;' +
             'module M; def g(); end; end').
      must_equal('const M = {f() {}}; ' +
        'M.g = function() {}');
    end
  end
end
```

The nice thing is, you even can leverage the expressive DSL of spec tests and expectations even in a unit test class.

```ruby
###
```

It's common to subclass tests from a common superclass you can augment with your own helpers and other setup code:

```ruby
require "minitest_helper"

class TestAllTheThings < MyUnitTest
  # test cases here
end
```

```ruby
# minitest_helper.rb

class MyUnitTest < Minitest::Test

end
```

## Checking Your Data

<table>
  <thead>
    <tr>
      <th>Assertion / Expectation</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>

  {% resource.relations.cheat_entries.each do |entry| %}
  <tr>
  <td markdown="block">

```ruby
{{ entry.data.assertion }}
{{ entry.data.expectation }}
```

{% if entry.data.negative_assertion %}
```ruby
{{ entry.data.negative_assertion }}
{{ entry.data.negative_expectation }}
```
{% end %}

  </td>
  <td>
  <div markdown="block" style="display: grid">

{{ entry.data.description }}

{{ entry.data.negative_description }}

  </div>
  </td>
  <td markdown="block">

{{ entry.content }}

  </td>
  </tr>
  {% end %}

  </tbody>
</table>
