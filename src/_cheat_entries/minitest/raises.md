---
assertion: assert_raises
expectation: must_raise
description: |
  Validates if the code executed within the block raises the provided exception
cheat_sheet: minitest
---

```ruby
assert_raises(CustomError) { run_code_that_raises_error }
expect { run_code_that_raises_error }.must_raise CustomError
```
