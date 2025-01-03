---
assertion: assert_match
expectation: must_match
negative_assertion: refute_match
negative_expectation: wont_match
description: |
  Validates if the value matches a regular expression (according to the `=~` operator)
negative_description: |
  Fails if the value matches a regular expression (according to the `=~` operator)
cheat_sheet: minitest
---

```ruby
assert_match /^[0-9]+/, str
expect(str).must_match /^[0-9]+/
```

```ruby
refute_match /^[0-9]+/, str
expect(str).wont_match /^[0-9]+/
```