require 'sequel'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
gem 'minitest'
require 'minitest/global_expectations/autorun'

describe "Sequel::Plugins::ValidationHelpersBlock" do
  before do
    @db = Sequel.mock
    @c = Class.new(Sequel::Model(@db)) do
      def self.set_validations(&block)
        define_method(:validate, &block)
      end
      set_columns([:name, :date, :number])
    end
    @c.plugin :validation_helpers_block
    @m = @c.new
  end

  specify "should allow specifying validations in a block format" do
    @c.set_validations do
      validates do
        name do
          presence
          max_length 10
        end
        date do
          format %r{\d\d/\d\d/\d\d\d\d}
        end
        number do
          presence
          integer
        end
      end
    end
    @m.wont_be :valid?
    @m.errors.must_equal(:name=>["is not present", "is not present"], :date=>["is invalid"], :number=>["is not present", "is not a number"])
    @m.set(:name=>'1234567890-', :number=>'a', :date=>'Tuesday')
    @m.wont_be :valid?
    @m.errors.must_equal(:name=>["is longer than 10 characters"], :date=>["is invalid"], :number=>["is not a number"])
    @m.set(:name=>'1234', :number=>'10', :date=>'10/11/2009')
    @m.must_be :valid?
  end

  specify "should accept options for validation methods" do
    @c.set_validations do
      validates do
        name do
          max_length 10, :message=>'cannot be more than 10 characters', :allow_blank=>true
        end
        date do
          format %r{\d\d/\d\d/\d\d\d\d}, :allow_missing=>true
        end
        number do
          integer :allow_nil=>true
        end
      end
    end
    @m.must_be :valid?
    @m.errors.must_equal({})
    @m.set(:name=>'                   ', :number=>nil)
    @m.must_be :valid?
    @m.errors.must_equal({})
    @m.set(:name=>'     12             ', :number=>'', :date=>nil)
    @m.wont_be :valid?
    @m.errors.must_equal(:name=>["cannot be more than 10 characters"], :date=>["is invalid"], :number=>["is not a number"])
  end
  
  specify "should support all validation_helpers methods" do
    @c.set_validations do
      validates do
        name do
          unique
          max_length 12
          exact_length 10
          min_length 8
          length_range 9..11
          type String
          schema_types
        end
        date do
          format %r{\d\d/\d\d/\d\d\d\d}
          includes ['10/11/2009']
        end
        number do
          presence
          integer
          numeric
        end
      end
    end
    ds = @db.dataset.with_extend do
      def columns
        [:name, :date, :number]
      end
      
      def fetch_rows(sql)
        yield({:v => /COUNT.*"?name"? = '1234567890'/i.match(sql) ? 0 : 1})
      end
    end
    @c.dataset = ds
    @c.db_schema[:name] = {:type => :string}
    @m.name = ''
    @m.wont_be :valid?
    @m.errors.must_equal(:name=>["is already taken", "is not 10 characters", "is shorter than 8 characters", "is too short or too long"], :date=>["is invalid", "is not in range or set: [\"10/11/2009\"]"], :number=>["is not present", "is not a number", "is not a number"])
    @m.set(:name=>'123456789', :date=>'10/12/2009', :number=>'12')
    @m.wont_be :valid?
    @m.errors.must_equal(:name=>["is already taken", "is not 10 characters"], :date=>["is not in range or set: [\"10/11/2009\"]"])
    @m.set(:name=>'1234567890', :date=>'10/11/2009', :number=>12)
    @m.must_be :valid?
    @m.errors.must_equal({})
  end
end 
