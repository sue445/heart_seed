# HeartSeed

seed util (convert excel to yaml and insert yaml to db)

[![Gem Version](https://badge.fury.io/rb/heart_seed.svg)](http://badge.fury.io/rb/heart_seed)
[![Build Status](https://travis-ci.org/sue445/heart_seed.svg)](https://travis-ci.org/sue445/heart_seed)
[![Code Climate](https://codeclimate.com/github/sue445/heart_seed.png)](https://codeclimate.com/github/sue445/heart_seed)
[![Coverage Status](https://img.shields.io/coveralls/sue445/heart_seed.svg)](https://coveralls.io/r/sue445/heart_seed?branch=master)
[![Dependency Status](https://gemnasium.com/sue445/heart_seed.svg)](https://gemnasium.com/sue445/heart_seed)

[![Stories in Ready](https://badge.waffle.io/sue445/heart_seed.png?label=ready&title=Ready)](https://waffle.io/sue445/heart_seed)

## Require
* ruby 2.0+
* [Ruby on Rails](http://rubyonrails.org/) , [Padrino](http://www.padrinorb.com/) or other ruby app

## Installation

Add this line to your application's Gemfile:

    gem 'heart_seed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heart_seed

## Usage

1. `bundle exec rake heart_seed:init`
  * create `config/heart_seed.yml`, `db/xls`, `db/seeds`
  * append to `db/seeds.rb`
2. Create xls
  * sheet name (xls,xlsx) = table name (DB)
  * example https://github.com/sue445/heart_seed/tree/master/spec/dummy/db/xls
3. `bundle exec rake heart_seed:xls`
  * Generate yml to `db/seeds`
  * If you want to specify files: `FILES=comments_and_likes.xls SHEETS=comments,likes bundle exec rake heart_seed:xls`
4. `bundle exec rake db:seed` or `bundle exec rake heart_seed:db:seed`
  * Import yml to db
  * Exists `TABLES`, `CATALOGS` options

examples

```sh
TABLES=articles,comments bundle exec rake db:seed
CATALOGS=article,user bundle exec rake db:seed
```

### not Rails

append this to `Rakefile`

```ruby
require 'heart_seed/tasks'
```

### Note
* if production `db:seed`, require `ENV["TABLES"]` or `ENV["CATALOGS"]`

### Snippets
#### config/heart_seed.yml
```yml
seed_dir: db/seeds
xls_dir: db/xls
catalogs:
#  user:
#  - users
#  - user_profiles
```

#### db/seeds.rb
```ruby
# Appended by `rake heart_seed:init`
HeartSeed::DbSeed.import_all
```

## Specification
### Supported xls/xlsx format

Example sheet

id  | title	 | description  | created_at     |     | this is dummy
--- | ------ | ------------ | -------------- | --- | --------------
1   | title1 | description1 | 2014/6/1 12:10 |     | foo
2   | title2 | description2 | 2014/6/2 12:10 | 	   | baz

* Sheet name is mapped table name
  * If sheet name is not found in database, this is ignored
* 1st row : table column names
  * If the spaces are included in the middle, right columns are ignored
* 2nd row ~ : records
  * [ActiveSupport::TimeWithZone](http://api.rubyonrails.org/classes/ActiveSupport/TimeWithZone.html) is used for timezone

### Yaml format

example

```yaml
---
articles_1:
  id: 1
  title: title1
  description: description1
  created_at: '2014-06-01 12:10:00 +0900'
articles_2:
  id: 2
  title: title2
  description: description2
  created_at: '2014-06-02 12:10:00 +0900'
```

* same as [ActiveRecord::FixtureSet](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html) format

### Catalog
Catalog is table groups defined in heart_seed.yml

example

```yml
catalogs:
  user:
  - users
  - user_profiles
```

`user` catalog = `users`, `user_profiles` tables


You can specify the catalogs at `db:seed` task

```sh
CATALOGS=user bundle exec rake db:seed
# same to) TABLES=users,user_profiles bundle exec rake db:seed
```

### Shard DB
When you use shard DB, write like this to `db/seeds.rb`.

Rails example

```ruby
SHARD_NAMES = %W(
  #{Rails.env}
  shard_#{Rails.env}
  shard2_#{Rails.env}
)
HeartSeed::DbSeed.import_all_with_shards(shard_names: SHARD_NAMES)
```

## Contributing

1. Fork it ( https://github.com/sue445/heart_seed/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
