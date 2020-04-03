require 'test_helper'

class ModelTest < Minitest::Test
  class FakeModel < ChangeHealth::Models::Model
    property :dateObject, default: Date.new(2020, 5, 30)
    property :someDateString, default: '2020-04-30'
    property :someNotDateString, default: 'cat'
    property :booleanWithDateInName, default: true
    property :daate, default: '2020-06-30'
    property :daateObject, default: Date.new(2020, 7, 30)
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
    end

    describe '#to_h' do
      let(:hmodel) { model.to_h }

      it 'translates any property with date in the name that is a dateish object' do
        assert_equal('20200530', hmodel[:dateObject])
        assert_equal('20200430', hmodel[:someDateString])
      end

      it 'leaves alone proprites named date that are not dates' do
        assert_equal('cat', hmodel[:someNotDateString])
        assert_equal(true, hmodel[:booleanWithDateInName])
      end

      it 'leave other properties completely alone' do
        assert_equal('2020-06-30', hmodel[:daate])
        assert_equal(Date.new(2020, 7, 30), hmodel[:daateObject])
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
