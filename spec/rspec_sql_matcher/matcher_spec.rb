# frozen_string_literal: true

require './spec/test_models/relation'

RSpec.describe RspecSqlMatcher::Matcher do
  describe '#check sql query' do
    context 'when ordinary check' do
      it do
        expect { User.count }.to call_sql_query('SELECT COUNT(*) FROM "users"')
      end
    end
  end
end
