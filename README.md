# CanCan::Reason

CanCan::Reason provides unauthorized reason.

## Installation

Add this line to your application's Gemfile:

    gem 'cancan-reason'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cancan-reason


## Usage

Add `because` option to `cannot` statement.

    class Ability
      include CanCan::Ability

      def initialize(user)
        cannot :follow, User, because: "Sign in required"
        if user
          can :follow, User
          cannot :follow, User, because: "You are blocked" do |followee|
            followee.blocked?(user)
          end
        end
      end
    end

    ability = Ability.new(nil)
    ability.can?(:follow, user) #=> false
    ability.reason(:follow, user) #=> "Sign in required"

    ability = Ability.new(blocked)
    ability.can?(:follow, user) #=> false
    ability.reason(:follow, user) #=> "You are blocked"

You must call `reason` after `can?` or `cannot?`.


## Contributing

1. Fork it ( http://github.com/<my-github-username>/cancan-reason/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
