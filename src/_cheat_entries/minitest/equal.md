---
assertion: assert_equal
expectation: must_equal
negative_assertion: refute_equal
negative_expectation: wont_equal 
description: |
  Validates if two values match according to the equality (`==`) operator
negative_description: |
  Fails if two values match according to the equality (`==`) operator
cheat_sheet: minitest
---

```ruby
assert_equal 42, i
expect(i).must_equal 42
```

```ruby
refute_equal 666, i
expect(i).wont_equal 666
```