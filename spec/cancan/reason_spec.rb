require 'spec_helper'
require "ostruct"

describe CanCan::Reason do
  before :all do
    class Article < OpenStruct
    end

    class Ability
      include CanCan::Ability
    end
  end

  context 'Conditons are Hash' do
    before do
      Ability.class_eval do
        # override by lower one
        # https://github.com/ryanb/cancan/wiki/Ability-Precedence
        define_method :initialize do |user|
          cannot :read, Article, because: "Private article"
          can :read, Article, author: user
          can :read, Article, public: true
          cannot :read, Article, removed: true, because: "Removed"
        end
      end
    end

    let (:user) { Object.new }
    let (:removed_article) { Article.new(removed: true, author: user) }
    let (:private_article) { Article.new(public: false) }
    let (:ability) { Ability.new(user) }

    context 'Reject by last cannot statement' do
      it "shoud have reason defined in last cannot statement" do
        expect(ability.can?(:read, removed_article)).to eq false
        expect(ability.reason(:read, removed_article)).to eq "Removed"
      end
    end

    context 'Reject by first cannot statement' do
      it "shoud have reason defined in first cannot statement" do
        expect(ability.can?(:read, private_article)).to eq false
        expect(ability.reason(:read, private_article)).to eq "Private article"
      end
    end

    context 'Reject by no statement' do
      it "shoud have reason defined in first cannot statement" do
        expect(ability.can?(:delete, private_article)).to eq false
        expect(ability.reason(:delete, private_article)).to be_nil
      end
    end

    context '#authorize!' do
      before do
        class I18n; end
        String.any_instance.stub(:underscore) { |word| word.downcase.gsub(/\s+/, '_') }
        String.any_instance.stub(:humanize) { |word| word.gsub(/[a-zA-Z](?=[A-Z])/, '\0 ').downcase }
        String.any_instance.stub(:blank?) { |word| word == '' }
        I18n.stub(:translate).and_return('')
        I18n.stub(:t) { |sentence| sentence.to_s }
      end
      it 'should raise CanCan::AccessDenied with the reason as error message' do
        expect { ability.authorize!(:read, private_article) }.to raise_error(CanCan::AccessDenied, 'Private article')
      end
      it 'should raise the custom reason if any' do
        expect { ability.authorize!(:read, private_article, message: 'Another reason') }.to raise_error(CanCan::AccessDenied, 'Another reason')
      end
    end
  end

  it 'should have a version number' do
    expect(CanCan::Reason::VERSION).not_to be_nil
  end
end
