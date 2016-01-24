Make the following changes:

```ruby
# features/support/database_cleaner.rb

# remove
FileUtils.rm_rf Dir['assets/img/usr/test/**/*.jpg']

# add
FileUtils.rm_rf Dir['pdf/test/**/*.jpg']

```

```shell
$ touch pdf/production/.keep
```

```
# .gitignore

.env
pdf/test/*
.DS_Store

```

When you are done, make sure to add new files and commit your changes.

```shell
$ git add .
$ git commit -am "fix for missing folder on heroku"
$ git push origin master
$ git push heroku master
```
