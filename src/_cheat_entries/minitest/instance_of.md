---
assertion: assert_instance_of
expectation: must_be_instance_of
negative_assertion: refute_instance_of
negative_expectation: wont_be_instance_of
description: |
  Validates if the test object is exactly an instance of the expected class
negative_description: |
  Fails if the test object is exactly an instance of the expected class
cheat_sheet: minitest
---

```ruby
assert_instance_of Set, coll
expect(coll).must_be_instance_of Set
```

```ruby
refute_instance_of Float, flt
expect(flt).wont_be_instance_of Float
```