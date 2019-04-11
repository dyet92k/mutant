# frozen_string_literal: true

module Mutant
  module Runner
    class Sink
      include Concord.new(:env, :reporter)

      # Initialize object
      #
      # @return [undefined]
      def initialize(*)
        super
        @start           = Timer.now
        @subject_results = {}
      end

      # Runner status
      #
      # @return [Result::Env]
      def status
        Result::Env.new(
          env:             env,
          runtime:         Timer.now - @start,
          subject_results: @subject_results.values
        )
      end

      # Test if scheduling stopped
      #
      # @return [Boolean]
      def stop?
        status.stop?
      end

      # Handle mutation finish
      #
      # @param [Result::Mutation] mutation_result
      #
      # @return [self]
      def result(mutation_result)
        report(mutation_result)

        subject = mutation_result.mutation.subject

        @subject_results[subject] = Result::Subject.new(
          subject:          subject,
          mutation_results: previous_mutation_results(subject) + [mutation_result],
          tests:            env.selections.fetch(subject)
        )

        self
      end

    private

      # Return previous results
      #
      # @param [Subject]
      #
      # @return [Array<Result::Mutation>]
      def previous_mutation_results(subject)
        subject_result = @subject_results.fetch(subject) { return EMPTY_ARRAY }
        subject_result.mutation_results
      end

      # Report mutation result
      #
      # @param [Result::Mutation] mutation_result
      #
      # @return [undefined]
      def report(mutation_result)
        reporter.alive(mutation_result) unless mutation_result.success?
      end

    end # Sink
  end # Runner
end # Mutant
