# frozen_string_literal: true

require './spec/test_models/relation'

RSpec.describe RspecSqlMatcher::Matcher do
  describe '#check sql query' do
    context 'when #call_sql_query' do
      it 'simple sql query' do
        expect { User.count }.to call_sql_query('SELECT COUNT(*) FROM "users"')
      end

      it 'sql query with parameters' do
        expect { Document.where(owner: User.last, status: 'new').last(5) }.to call_sql_query('SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1')
      end
    end

    context 'when #call_sql_query n times' do
      it 'when 1 times' do
        expect { User.count }.to call_sql_query('SELECT COUNT(*) FROM "users"').once
      end

      it 'when some times' do
        expect { 3.times { User.count } }.to call_sql_query('SELECT COUNT(*) FROM "users"').times(3)
      end

      it 'when negative times' do
        expect do
          expect { User.count }.to call_sql_query('SELECT COUNT(*) FROM "users"').times(-1)
        end.to raise_error(ArgumentError)
      end

      it 'when zero times' do
        expect { User.count }.to call_sql_query('SELECT COUNT(*) FROM "documents"').times(0)
      end
    end

    context 'when #call_sql_query with bind values' do
      it 'when 1 bind value' do
        expect { User.last }.to call_sql_query('SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1').with(1)
      end

      it 'when some bind value' do
        expect { User.where(name: 'Karl').last }.to call_sql_query('SELECT "users".* FROM "users" WHERE "users"."name" = $1 ORDER BY "users"."id" DESC LIMIT $2').with('Karl', 1)
      end

      it 'when string bind value' do
        expect { User.where(name: 'Karl').map(&:id) }.to call_sql_query('SELECT "users".* FROM "users" WHERE "users"."name" = $1').with('Karl')
      end

      it 'when array bind value' do
        expect { User.where(name: %w[Karl Gerald]).last }.to call_sql_query('SELECT "users".* FROM "users" WHERE "users"."name" IN ($1, $2) ORDER BY "users"."id" DESC LIMIT $3').with('Karl', 'Gerald', 1)
      end
    end

    context 'when not to #call_sql_query' do
      it 'simple sql query' do
        expect { User.count }.not_to call_sql_query('SELECT COUNT(*) FROM "documents"')
      end

      it 'when some times' do
        expect { User.count }.not_to call_sql_query('SELECT COUNT(*) FROM "users"').times(3)
      end

      it 'when with bind values' do
        expect { User.where(name: 'Karl').map(&:id) }.not_to call_sql_query('SELECT "users".* FROM "users" WHERE "users"."name" = $1').with('Marry')
      end
    end
  end
end
