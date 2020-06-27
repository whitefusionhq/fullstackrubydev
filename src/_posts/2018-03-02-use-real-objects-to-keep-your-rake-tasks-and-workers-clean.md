---
title: "Use Ruby Objects to Keep Your Rake Tasks Clean"
subtitle: "In the spirit of DHH's On Writing Software Well series, I'll be demonstrating by looking at live production code."
categories:
- Object Orientation
layout: post
author: jared
---

I've been inspired by David Heinemeier Hansson's [new YouTube series _On Writing Software Well_](https://www.youtube.com/playlist?list=PL9wALaIpe0Py6E_oHCgTrD6FvFETwJLlx), because I think it's positively delightful when somebody takes the time and care to walk through real-world, production code and discuss why things were done the way they were and the tradeoffs involved, as well as the possibilities for improving that code further.

Today, I want to talk about how to keep ancillary pieces of your infrastructure fairly clean and minimalist. In terms of Rails, one place I've seen where it's easy to end up with "bags of code" that aren't really structured or straightforward to test are Rake tasks.

Let's look at a Rake task I recently refactored on a client project. We were  using Heroku's new Review Apps functionality, which allows every pull request on GitHub to spawn a new application. QA specialists or product managers are then able to look at that particular feature branch's functionality in isolation, which is a good thing. However, the post-deploy rake task we had in place to make sure we were setting up the proper subdomains, SSL certificates, indexing data for search, etc., was getting increasingly unwieldy. It was just a big "bag of code," and that to me was a sign some refactoring was sorely needed.

Let's take a look at the _before_ code (a few bits of private data have been changed to protect the innocent):

```ruby
namespace :heroku do
  desc "Run as the postdeploy script in heroku"
  task :setup do
    heroku_app_name = ENV['HEROKU_APP_NAME']
    begin
      new_domain = "#{ENV['HEROKU_APP_NAME']}.domain.com"

      # set up Heroku domain (or use existing one on a redeploy)
      heroku_domains = heroku.domain.list(heroku_app_name)
      domain_info = heroku_domains.find{|item| item['hostname'] == new_domain}
      if domain_info.nil?
        domain_info = heroku.domain.create(heroku_app_name, hostname: new_domain)
      end

      key = ENV['CLOUDFLARE_API_KEY']
      email = ENV['CLOUDFLARE_API_EMAIL']
      connection = Cloudflare.connect(key: key, email: email)
      zone = connection.zones.find_by_name("domain.com")

      # delete old dns records
      zone.dns_records.all.select{|item| item.record[:name] == new_domain}.each do |dns_record|
        dns_record.delete
      end

      response = zone.dns_records.post({
        type: "CNAME",
        name: new_domain,
        content: domain_info['cname'],
        ttl: 240,
        proxied: false
      }.to_json, content_type: 'application/json')

      # install SSL cert
      s3 = AWS::S3.new
      bucket = s3.buckets['theres_a_hole_in_the_bucket']
      crt_data = bucket.objects['__domain_com.crt'].read
      key_data = bucket.objects['__domain_com.key'].read
      if heroku.ssl_endpoint.list(heroku_app_name).length == 0
        heroku.ssl_endpoint.create(heroku_app_name, certificate_chain: crt_data, private_key: key_data)
      end

      sh "rake heroku:start_indexing"
    rescue => e
      output =  "** ERROR IN HEROKU RAKE **\n"
      output << "#{e.inspect}\n"
      output << e.backtrace.join("\n")
      puts output
    ensure
      heroku.app.update(heroku_app_name, maintenance: false)
    end
    puts "Postdeploy script complete"
  end

  def heroku
    @heroku ||= PlatformAPI.connect_oauth(ENV['HEROKU_PLATFORM_KEY'])
  end
end

```

Whew! That's a lot to wade through. Not only is the task getting pretty long at this point, there are certain dependencies between the blocks of code being executed that are difficult to ascertain just by a cursory examination.

Now let's look at how I refactored this. First, I created a new class in the `lib` folder called `HerokuReviewAppPostDeploy` and extracted each block into a separate method. You'll notice we are actually doing even more in this new object, such as connecting to the GitHub repository and getting the branch name of the pull request so we can put a Jira ticket number right in the review app's subdomain. That requirement turned up right as I was in the middle of refactoring, so I was thankful I avoided an even larger bag of code!

Here's the full class:

```ruby
class HerokuReviewAppPostDeploy
  attr_accessor :heroku_app_name, :heroku_api

  def initialize(heroku_app_name)
    self.heroku_app_name = heroku_app_name
    self.heroku_api = PlatformAPI.connect_oauth(ENV['HEROKU_PLATFORM_KEY'])
  end

  def turn_on_maintenance_mode
    heroku_api.app.update(heroku_app_name, maintenance: true)
  end

  def turn_off_maintenance_mode
    heroku_api.app.update(heroku_app_name, maintenance: false)
  end

  def determine_subdomain
    new_subdomain = heroku_app_name
    pull_request_number = begin
      heroku_app_name.match(/pr-([0-9]+)/)[1]
    rescue NoMethodError; nil; end
    unless pull_request_number.nil?
      github_info = HTTParty.get('https://api.github.com/repos/organization/reponame/pulls/' + pull_request_number, basic_auth: {username: 'janedoe', password: ENV["GITHUB_API_KEY"]}).parsed_response
      if github_info["head"]
        branch = github_info["head"]["ref"]
        jira_id = begin
          branch.match(/WXYZ-([0-9]+)/)[1]
        rescue NoMethodError; nil; end
        unless jira_id.nil?
          new_subdomain = "#{heroku_app_name.match(/^([a-z]+)/)[1]}-wxyz-#{jira_id}"
        end
      end
    end
    new_subdomain
  end

  def determine_domain
    "#{determine_subdomain}.domain.com"
  end

  def setup_domain_on_heroku(new_domain)
    # set up Heroku domain (or use existing one on a redeploy)
    heroku_domains = heroku_api.domain.list(heroku_app_name)
    domain_info = heroku_domains.find{|item| item['hostname'] == new_domain}
    if domain_info.nil?
      heroku_api.domain.create(heroku_app_name, hostname: new_domain)
    else
      domain_info
    end
  end

  def setup_domain_on_cloudflare(new_domain, heroku_domain_info)
    key = ENV['CLOUDFLARE_API_KEY']
    email = ENV['CLOUDFLARE_API_EMAIL']
    connection = Cloudflare.connect(key: key, email: email)
    zone = connection.zones.find_by_name("domain.com")
    zone.dns_records.all.select{|item| item.record[:name] == new_domain}.each do |dns_record|
      dns_record.delete
    end
    response = zone.dns_records.post({
      type: "CNAME",
      name: new_domain,
      content: heroku_domain_info['cname'],
      ttl: 240,
      proxied: false
    }.to_json, content_type: 'application/json')
  end

  def setup_ssl_cert_on_heroku
    # install SSL cert
    s3 = AWS::S3.new
    bucket = s3.buckets['theres_a_hole_in_the_bucket']
    crt_data = bucket.objects['__domain_com.crt'].read
    key_data = bucket.objects['__domain_com.key'].read
    if heroku_api.ssl_endpoint.list(heroku_app_name).length == 0
      heroku_api.ssl_endpoint.create(heroku_app_name, certificate_chain: crt_data, private_key: key_data)
    end
  end
end
```

Not only does this new approach allow us to use an object to break out bits of functionality into single-purpose methods, but because certain methods require data generated by other methods, we can include those variables as method arguments (for example, passing `new_domain` explicitly into `setup_domain_on_heroku`).

So how does our Rake task look now? Much, much better:

```ruby
namespace :heroku do
  desc "Run as the postdeploy script in heroku"
  task :setup do
    heroku_app_name = ENV['HEROKU_APP_NAME']
    post_deploy = HerokuReviewAppPostDeploy.new(heroku_app_name)
    begin
      post_deploy.turn_on_maintenance_mode
      new_domain = post_deploy.determine_domain
      heroku_domain_info = post_deploy.setup_domain_on_heroku(new_domain)
      post_deploy.setup_domain_on_cloudflare(new_domain, heroku_domain_info)
      post_deploy.setup_ssl_cert_on_heroku
      Rake::Task['db:migrate'].invoke
      sh "rake heroku:start_indexing"
    rescue => e
      output =  "** ERROR IN HEROKU RAKE **\n"
      output << "#{e.inspect}\n"
      output << e.backtrace.join("\n")
      puts output
    ensure
      post_deploy.turn_off_maintenance_mode
    end
    puts "Postdeploy script complete"
  end
end
```

It's way easier to see the individual steps needed to go through the process of completing the review app setup, and through the use of setting a variable returned from one method and passing it along to another, the data dependencies between the steps are now clear. In addition, because `HerokuReviewAppPostDeploy` uses straightforward method names that describe exactly what's going on, the explanatory need for code comments is greatly reduced.

You can use this **extract-into-a-standalone-object** technique for other "bag of code" areas of your application. Background jobs are another good example. I prefer to keep my Sidekiq workers very minimalist...a lot of the time I make sure they call a single method on a single model and that's all.

I hope this was helpful in giving you some new ideas on how to improve your own codebase, based on live production code. Stay tuned for the next article in this series.
