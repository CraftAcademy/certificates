```ruby
# features/support/database_cleaner.rb

# remove
FileUtils.rm_rf Dir['assets/img/usr/test/**/*.jpg']

# add
FileUtils.rm_rf Dir['pdf/test/**/*.jpg']

```

```ruby
# .gitignore

.DS_Store
```
