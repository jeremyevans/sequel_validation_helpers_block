require 'rubygems'
require 'sequel'
$: << File.join(File.dirname(__FILE__), '..', 'lib')
Sequel.extension :blank

describe "Sequel::Plugins::ValidationHelpersBlock" do
  before do
    @db = Sequel::Database.new
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
    @m.should_not be_valid
    @m.errors.should == {:name=>["is not present", "is not present"], :date=>["is invalid"], :number=>["is not present", "is not a number"]}
    @m.set(:name=>'1234567890-', :number=>'a', :date=>'Tuesday')
    @m.should_not be_valid
    @m.errors.should == {:name=>["is longer than 10 characters"], :date=>["is invalid"], :number=>["is not a number"]}
    @m.set(:name=>'1234', :number=>'10', :date=>'10/11/2009')
    @m.should be_valid
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
    @m.should be_valid
    @m.errors.should == {}
    @m.set(:name=>'                   ', :number=>nil)
    @m.should be_valid
    @m.errors.should == {}
    @m.set(:name=>'     12             ', :number=>'', :date=>nil)
    @m.should_not be_valid
    @m.errors.should == {:name=>["cannot be more than 10 characters"], :date=>["is invalid"], :number=>["is not a number"]}
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
    ds = @db.dataset
    ds.extend(Module.new {
      def columns(sql)
        [:name, :date, :number]
      end
      
      def fetch_rows(sql)
        yield({:v => /COUNT.*"?name"? = '1234567890'/i.match(sql) ? 0 : 1})
      end
    })
    @c.dataset = ds
    @c.db_schema[:name] = {:type => :string}
    @m.name = ''
    @m.should_not be_valid
    @m.errors.should == {:name=>["is already taken", "is not 10 characters", "is shorter than 8 characters", "is too short or too long"], :date=>["is invalid", "is not in range or set: [\"10/11/2009\"]"], :number=>["is not present", "is not a number", "is not a number"]}
    @m.set(:name=>'123456789', :date=>'10/12/2009', :number=>'12')
    @m.should_not be_valid
    @m.errors.should == {:name=>["is already taken", "is not 10 characters"], :date=>["is not in range or set: [\"10/11/2009\"]"]}
    @m.set(:name=>'1234567890', :date=>'10/11/2009', :number=>12)
    @m.should be_valid
    @m.errors.should == {}
  end
end 
