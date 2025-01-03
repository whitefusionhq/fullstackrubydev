---
assertion: assert_includes
expectation: must_include
negative_assertion: refute_includes
negative_expectation: wont_inlude
description: |
  Validates if the value can found within the collection
negative_description: |
  Fails if the value can be found within the collection
cheat_sheet: minitest
---

```ruby
assert_includes [31, 42, 53], 42
expect([31, 42, 53]).must_include 42
```

```ruby
refute_includes [31, 42, 53], 666
expect([31, 42, 53]).wont_include 666
```