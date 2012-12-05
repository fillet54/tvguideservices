class Guide

   def initialize 
   end
end

describe Guide do
   subject { Guide.new }

   it { should respond_to :start_time }
   
   describe "when converting to JSON" do
      describe "with no lineups" do
         it "should print out guide json" do

         end
      end
   end
end
