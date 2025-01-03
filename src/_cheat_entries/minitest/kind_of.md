---
assertion: assert_kind_of
expectation: must_be_kind_of
negative_assertion: refute_kind_of
negative_expectation: wont_be_kind_of
description: |
  Validates if the test object is an instance of the expected class (or subclass)
negative_description: |
  Fails if the test object is an instance of the expected class (or subclass)
cheat_sheet: minitest
---

```ruby
assert_kind_of Set, coll
expect(coll).must_be_kind_of Set
```

```ruby
refute_kind_of Float, flt
expect(flt).wont_be_kind_of Float
```