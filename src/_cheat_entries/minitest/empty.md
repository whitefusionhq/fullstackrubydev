---
assertion: assert_empty
expectation: must_be_empty
negative_assertion: refute_empty
negative_expectation: wont_be_empty
description: |
  Validates if the collection is empty
negative_description: |
  Fails if the collection is empty
cheat_sheet: minitest
---

```ruby
assert_empty []
expect([]).must_be_empty
```

```ruby
refute_empty [:hello]
expect([:hello]).wont_be_empty
```