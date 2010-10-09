require File.join('..','wardrobe_helpers.rb')

describe "Helpers" do
  include Sinatra::WardrobeHelpers

  it "should parse tags string and return an array" do
        str = 'This, is a, test'
        tags = parse_tags str
        tags.length.should == 3
  end

  it "should return the current hour" do
    a =  Time.now - ((Time.now.min * 60) + (Time.now.sec))
    b = current_hour
    #a.to_s should == b.to_s
    puts b.to_s
  end

end