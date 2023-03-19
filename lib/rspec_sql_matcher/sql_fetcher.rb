# frozen_string_literal: true

module RspecSqlMatcher
  class SqlFetcher
    SqlQueryInfo = Struct.new(:sql, :type_casted_binds, :times) do
      # Приводит SqlHelper::SqlQueryInfo в читабельный текст
      #
      # @return [String] читабельный текст
      def pretty_to_s
        if type_casted_binds.present?
          "#{times} times: #{sql} with values #{type_casted_binds}"
        else
          "#{times} times: #{sql}"
        end
      end
    end

    class << self
      attr_reader :queries

      # Собирает все sql запросы вызываемые в указанном блоке кода
      #
      # @return [Array<SqlQueryInfo>] список собранных sql-запросов и из кол-во
      # @example
      # [
      #   #<struct SqlHelper::SqlQueryInfo sql="SELECT COUNT(*) FROM \"companies\"", type_casted_binds=[], times=1>,
      #   #<struct SqlHelper::SqlQueryInfo sql="SELECT \"companies\".* FROM \"companies\" LIMIT $1 OFFSET $2",
      #     type_casted_binds=[10, 10], times=1>
      # ]
      def sql_queries(block)
        @queries = []

        ActiveSupport::Notifications.subscribed(method(:active_support_callback), 'sql.active_record') do
          block.call
        end

        queries
      end

      private

      # Колбек для ActiveSupport::Notifications - заполняет список @queries
      def active_support_callback(_name, _started, _finished, _unique_id, payload)
        return if %w[CACHE SCHEMA].include?(payload[:name])

        old_query = exists_query(**payload.slice(:sql, :type_casted_binds))
        #  Если такой запрос уже был, просто увеличиваем его кол-во
        if old_query.present?
          old_query.times = old_query.times + 1
        else
          #  Если не было - добавлем в общий список
          queries << SqlQueryInfo.new(payload[:sql], payload[:type_casted_binds], 1)
        end
      end

      # Находит был ли уже такой SQL-запрос и возвращает его
      #
      # @param sql [String] проверяемый объект
      # @param type_casted_binds [Array] проверяемый объект
      # @return [SqlQueryInfo, nil] найденный запрос
      #   Если не найден nil
      def exists_query(sql:, type_casted_binds:)
        queries.find { |q| q.sql == sql && q.type_casted_binds == type_casted_binds }
      end
    end
  end
end
