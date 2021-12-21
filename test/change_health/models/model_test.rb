require 'test_helper'

class ModelTest < Minitest::Test
  class FakeModel < ChangeHealth::Models::Model
    property :dateObject, default: Date.new(2020, 5, 30)
    property :someDateString, default: '2020-04-30'
    property :someNotDateString, default: 'cat'
    property :booleanWithDateInName, default: true
    property :nilDate, default: nil
    property :daate, default: '2020-06-30'
    property :daateObject, default: Date.new(2020, 7, 30)
    property :emptyValue, default: ''
    property :shortPostalCode, default: '12345'
    property :longDashPostalCode, default: '12345-6789'
    property :longNoDashPostalCode, default: '123456789'
    property :crazyPostalCode, default: '123-456-789'
    property :numberPostalCode, default: 123_456_789
    property :nilPostalCode, default: nil
    property :superNested, default: {
      someDate: Date.new(2021, 12, 25),
      funPostalCode: '88888-8888',
      moreNesting: [
        { anotherDate: Date.new(2022, 12, 25) },
        { morePostalCodes: %w[333-33 11-11 2222] }
      ],
      listOfPostalCodes: %w[444-444 55-55]
    }
  end

  describe 'model' do
    let(:model) { FakeModel.new }

    describe '#DATE_FORMATTER' do
      it 'formats dates to Change Health format' do
        assert_equal('20200530', ChangeHealth::Models::DATE_FORMATTER.call(model.dateObject))
      end

      it 'formats date strings to Change Health format' do
        assert_equal('20200430', ChangeHealth::Models::DATE_FORMATTER.call(model.someDateString))
      end

      it 'leaves strings alone that are not dates' do
        assert_equal(model.someNotDateString, ChangeHealth::Models::DATE_FORMATTER.call(model.someNotDateString))
      end

      it 'leaves booleans alone' do
        assert_equal(true, ChangeHealth::Models::DATE_FORMATTER.call(model.booleanWithDateInName))
      end

      it 'handles nil' do
        assert_nil ChangeHealth::Models::DATE_FORMATTER.call(model.nilDate)
      end
    end

    describe '#PARSE_DATE' do
      it 'parses date correctly' do
        assert_equal(Date.new(2012, 5, 1), ChangeHealth::Models::PARSE_DATE.call('20120501'))
        assert_equal(Date.new(2015, 1, 1), ChangeHealth::Models::PARSE_DATE.call('20150101'))
        assert_equal(Date.new(2016, 9, 15), ChangeHealth::Models::PARSE_DATE.call('20160915'))
      end

      it 'returns input if bad date format' do
        fake_date_string = 'lskjdf'
        assert_equal(fake_date_string, ChangeHealth::Models::PARSE_DATE.call(fake_date_string))
      end
    end

    describe '#POSTAL_CODE_FORMATTER' do
      it 'leaves normal zip codes alone' do
        assert_equal(model.shortPostalCode, ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(model.shortPostalCode))
        assert_equal(model.longNoDashPostalCode,
                     ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(model.longNoDashPostalCode))
      end

      it 'formats strings w/ dashses' do
        assert_equal('123456789', ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(model.longDashPostalCode))
        assert_equal('123456789', ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(model.crazyPostalCode))
      end

      it 'formats numbers fine' do
        assert_equal('123456789', ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(model.numberPostalCode))
      end

      it 'handles nil' do
        assert_nil ChangeHealth::Models::POSTAL_CODE_FORMATTER.call(model.nilPostalCode)
      end
    end

    describe '#CONTROL_NUMBER' do
      it 'creates reasonable default control number' do
        assert_equal(9, ChangeHealth::Models::CONTROL_NUMBER.call.size)
      end
    end

    describe '#to_h' do
      let(:hmodel) { model.to_h }

      it 'translates any property with date in the name that is a dateish object' do
        assert_equal('20200530', hmodel[:dateObject])
        assert_equal('20200430', hmodel[:someDateString])
      end

      it 'leaves alone properties named date that are not dates' do
        assert_equal('cat', hmodel[:someNotDateString])
        assert_equal(true, hmodel[:booleanWithDateInName])
      end

      it 'leave other properties completely alone' do
        assert_equal('2020-06-30', hmodel[:daate])
        assert_equal(Date.new(2020, 7, 30), hmodel[:daateObject])
      end

      it 'translates properties with postalcode in name' do
        assert_equal('123456789', hmodel[:longDashPostalCode])
        assert_equal('123456789', hmodel[:crazyPostalCode])
      end

      it 'leaves alone properties named postalcode but already dash free' do
        assert_equal('12345', hmodel[:shortPostalCode])
        assert_equal('123456789', hmodel[:longNoDashPostalCode])
      end

      it 'translates any property with an empty value to nil' do
        assert_nil(hmodel[:emptyValue], 'Model should change values of "" to nil')
      end

      it 'keeps nil properties nil' do
        assert_nil hmodel[:nilPostalCode]
        assert_nil hmodel[:nilDate]
      end

      describe 'handles nesting' do
        it 'hashes' do
          assert_equal '20211225', hmodel[:superNested][:someDate]
          assert_equal '888888888', hmodel[:superNested][:funPostalCode]
        end

        it 'multiple nestings' do
          assert_equal '20221225', hmodel[:superNested][:moreNesting][0][:anotherDate]
          assert_equal %w[33333 1111 2222], hmodel[:superNested][:moreNesting][1][:morePostalCodes]
        end

        it 'arrays' do
          assert_equal %w[444444 5555], hmodel[:superNested][:listOfPostalCodes]
        end
      end
    end

    describe '#as_json' do
      it 'equals the #to_h' do
        assert_equal(model.to_h, model.as_json)
      end

      it 'can take an arg' do
        assert_equal(model.to_h, model.as_json(bob: 10))
      end
    end

    describe '#to_json' do
      it 'equals the #to_h to json' do
        assert_equal(model.to_h.to_json, model.to_json)
      end
    end
  end
end
