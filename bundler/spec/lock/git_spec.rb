# frozen_string_literal: true

RSpec.describe "bundle lock with git gems" do
  before :each do
    build_git "foo"

    install_gemfile <<-G
      source "#{file_uri_for(gem_repo1)}"
      gem 'foo', :git => "#{lib_path("foo-1.0")}"
    G
  end

  it "doesn't break right after running lock" do
    expect(the_bundle).to include_gems "foo 1.0.0"
  end

  it "doesn't print errors even if running lock after removing the cache" do
    FileUtils.rm_rf(Dir[default_cache_path("git/foo-1.0-*")].first)

    bundle "lock --verbose"

    expect(err).to be_empty
  end

  it "locks a git source to the current ref" do
    update_git "foo"
    bundle :install

    run <<-RUBY
      require 'foo'
      puts "WIN" unless defined?(FOO_PREV_REF)
    RUBY

    expect(out).to eq("WIN")
  end

  it "provides correct #full_gem_path" do
    run <<-RUBY
      puts Bundler.rubygems.find_name('foo').first.full_gem_path
    RUBY
    expect(out).to eq(bundle("info foo --path"))
  end
end
