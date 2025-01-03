---
assertion: assert_nil
expectation: must_be_nil
negative_assertion: refute_nil
negative_expectation: wont_be_nil
description: |
  Validates if the value is `nil?`
negative_description: |
  Fails if the value is `nil?`
cheat_sheet: minitest
---

```ruby
assert_nil hsh[:nothing]
expect(hsh[:nothing]).must_be_nil
```

```ruby
refute_nil hsh[:something]
expect(hsh[:something]).wont_be_nil
```