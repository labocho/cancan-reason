require "cancan"
require "cancan/reason/version"

module CanCan
  module Reason
    module Ability
      def reasons
        @reasons ||= Hash.new{|hash, key| hash[key] = {} }
      end

      def reason(action, subject)
        reasons[action][subject]
      end

      # Override
      def can(action = nil, subject = nil, conditions = nil, reason_hash = {}, &block)
        reason = extract_reason(conditions, reason_hash)
        conditions = nil if conditions && conditions.empty?
        add_rule(::CanCan::Rule.new(true, action, subject, conditions, reason, block))
      end

      # Override
      def cannot(action = nil, subject = nil, conditions = nil, reason_hash = {}, &block)
        reason = extract_reason(conditions, reason_hash)
        conditions = nil if conditions && conditions.empty?
        add_rule(::CanCan::Rule.new(false, action, subject, conditions, reason, block))
      end

      # Override
      def can?(action, subject, *extra_args)
        match = extract_subjects(subject).lazy.map do |a_subject|
          relevant_rules_for_match(action, a_subject).detect do |rule|
            rule.matches_conditions?(action, a_subject, extra_args)
          end
        end.reject(&:nil?).first
        if match && (result = match.base_behavior)
          result
        else
          reasons[action][subject] = match.reason
          false
        end
      end

      def extract_reason(conditions, reason_hash)
        reason_hash[:because] || begin
          conditions.is_a?(Hash) && conditions.delete(:because)
        end
      end
    end

    module Rule
      def initialize(base_behavior, action, subject, conditions, reason, block)
        super(base_behavior, action, subject, conditions, block)
        @reason = reason
      end

      def reason
        @reason
      end
    end
  end
end

CanCan::Ability.send(:prepend, CanCan::Reason::Ability)
CanCan::Rule.send(:prepend, CanCan::Reason::Rule)
