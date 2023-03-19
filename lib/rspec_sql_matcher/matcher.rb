# frozen_string_literal: true

require_relative 'sql_fetcher'

module RspecSqlMatcher
  module Matcher
    # rubocop:disable Metrics/BlockLength
    # Матчер для SQL запросов
    # Проверяет был ли вызыван запрос, с какими параметрами и сколько раз
    #
    # @example
    #   expect{ subject }.not_to call_sql_query('SELECT "companies".* FROM "companies" LIMIT $1 OFFSET $2')
    #   expect{ subject }.to call_sql_query('SELECT COUNT(*) FROM "companies"').times(1)
    RSpec::Matchers.define :call_sql_query do |expected|
      supports_block_expectations

      chain :with do |*bind_values|
        @bind_values = *bind_values
      end

      chain :times do |count|
        @count = count
      end

      match do |block|
        find_queries(block)
        @count ? @res_times == @count : @res_times.positive?
      end

      match_when_negated do |block|
        find_queries(block)
        @count ? @res_times != @count : @res_times.zero?
      end

      # Тест ошибки в случае, если такие запросы не найдены
      #
      # @example
      #     Expected to call SQL query SELECT "companies".* FROM "companies" LIMIT $1 OFFSET $2 with values [1, 2]
      #                                                                               1 times, but found this queries:
      #     3 times: SELECT COUNT(*) FROM "companies"
      #     1 times: SELECT COUNT(*) FROM (SELECT 1 AS one FROM "companies" LIMIT $1 OFFSET $2) subquery_for_count with
      #                                                                                                 values [5, 10]
      #     1 times: SELECT "companies".* FROM "companies" LIMIT $1 OFFSET $2 with values [5, 10]
      failure_message do |_|
        prelude = "Expected to call SQL query #{expected}"
        prelude += " with values #{@bind_values}" if @bind_values.present?

        prelude += " #{@count} times" if @count.present?

        "#{prelude}, but found this queries:\n#{pretty_queries(@all_queries)}"
      end

      # Тест ошибки в случае, если такие запросы найдены
      #
      # @example
      #     Expected not to call SQL query SELECT "companies".* FROM "companies" LIMIT $1 OFFSET $2 1 times, but found
      #                                                                                                 this query:
      #     1 times: SELECT "companies".* FROM "companies" LIMIT $1 OFFSET $2 with values [5, 10]
      failure_message_when_negated do |_|
        prelude = "Expected not to call SQL query #{expected}"
        prelude += " with values #{@bind_values}" if @bind_values.present?

        prelude += " #{@count} times" if @count.present?

        "#{prelude}, but found this query:\n#{pretty_queries(@exp_queries)}"
      end

      private

      # Приводит SqlHelper::SqlQueryInfo в читабельный текст
      def pretty_queries(queries)
        queries.map(&:pretty_to_s).join("\n")
      end

      # Находит был ли  SQL-запрос c таким телои и параметрами
      #   Также считает сколько раз он вызывался
      def find_queries(block)
        # Находим все sql запросы
        @all_queries ||= SqlFetcher.sql_queries(block)

        # Находим запросы с таким sql-телом
        @exp_queries = @all_queries.select { |q| q.sql == expected }

        # Находим запросы с такими значениями
        @exp_queries = @exp_queries.select { |q| q.type_casted_binds == @bind_values } if @bind_values

        # Считаем кол-во раз
        @res_times = @exp_queries.sum(&:times)
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
