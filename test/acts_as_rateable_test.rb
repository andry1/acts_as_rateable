# $Id$
# $LastChangedDate$
# $LastChangedRevision$
#
# acts_as_rateable plugin unit tests
#
# Copyright (c) 2006 FortiusOne, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require File.join(File.dirname(__FILE__), '../../../../test', 'test_helper.rb')
module FortiusOne #:nodoc:
  class RatedThing < ActiveRecord::Base #:nodoc:
    acts_as_rateable
  end
  
  class AverageRatedThing < ActiveRecord::Base #:nodoc:
    acts_as_rateable :average => true
  end
  
  class ActsAsRateableTest < Test::Unit::TestCase #:nodoc:
      def setup  
        ActiveRecord::Schema.define do
          # create_table :ratings, :force => true do |t|
          #   t.column :rateable_id, :integer, :null => false
          #   t.column :rateable_type, :string, :null => false
          #   t.column :rating, :integer, :null => false
          #   t.column :total, :integer, :default => 0
          # end
        
          create_table :rated_things, :force => true do |t|
            t.column :name, :string
          end
          
          create_table :average_rated_things, :force => true do |t|
            t.column :name, :string
          end
        end
        
        RatedThing.new(:name => "My Favorite", :rating => 5).save
        RatedThing.new(:name => "Tied For Second", :rating => 4).save
        RatedThing.new(:name => "Also Tied For Second", :rating => 4).save
        RatedThing.new(:name => "Take it or leave it", :rating => 3).save
        RatedThing.new(:name => "Don't like this thing very much", :rating => 2).save
        RatedThing.new(:name => "My Least Favorite", :rating => 1).save
        
      end
    
      def teardown
        Rating.delete_all
        RatedThing.delete_all
        AverageRatedThing.delete_all
      end
    
      def test_has_rateable_included
        assert RatedThing.singleton_methods.include?('acts_as_rateable'),
               "acts_as_rateable not included in ActiveRecord class"
      end
      
      def test_has_association
        RatedThing.new(:name => "A Rated Thing", :rating => 5).save
        thing = RatedThing.find_by_name("A Rated Thing")
        assert (thing.rating == 5), "Rating should be 5, got #{thing.rating.inspect}"
        RatedThing.delete(thing.id)
      end
      
      def test_find_multiple_by_rating
        things = RatedThing.find_all_by_rating(4)
        assert (things.length == 2), "Should have gotten two things with rating 4"
        assert (((things.first.name == "Tied For Second") or (things.first.name == "Also Tied For Second")) and
                ((things.last.name == "Tied For Second") or (things.last.name == "Also Tied For Second"))),
                "List was the right length, but contained the wrong items => #{things.inspect}"
      end
      
      def test_find_by_rating_list
        things = RatedThing.find_all_by_rating([1,2,3])
        is_things_one_to_three?(things)
      end
      
      def test_find_by_rating_list_with_range
        things = RatedThing.find_all_by_rating([1,2..3])
        is_things_one_to_three?(things)
      end
      
      def test_find_one_by_rating
        assert_kind_of RatedThing, RatedThing.find_by_rating(5)
        assert_equal "My Favorite", RatedThing.find_by_rating(5).name, "Single thing with rating=5 has wrong name"
      end
      
      def test_find_all_with_minimum_rating
        things = RatedThing.find_all_by_rating(4..-1)
        assert_equal 3, things.length
        names = things.collect {|thing| thing.name}
        assert names.include?("Tied For Second")
        assert names.include?("Also Tied For Second")
        assert names.include?("My Favorite")
      end
      
      def test_update_rating
        thing = RatedThing.find_by_rating(5)
        assert_kind_of RatedThing, thing
        assert_equal "My Favorite", thing.name
        thing.rate(4)
        thing = RatedThing.find_by_rating(5)
        assert thing.nil?, thing.inspect
        things = RatedThing.find_all_by_rating(4)
        assert_equal 3, things.length, RatedThing.find_by_name("My Favorite", :include => :rating).inspect
        names = things.collect {|thing| thing.name}
        assert names.include?("My Favorite")
      end
      
      def test_find_all_by_rating_with_args
        things = RatedThing.find_all_by_rating(4, :order => 'name ASC')
        assert (things.length == 2), "Should have gotten two things with rating 4"
        assert_equal "Also Tied For Second", things.first.name
        assert_equal "Tied For Second", things.last.name
      end
      
      def test_find_by_range
        things = RatedThing.find_all_by_rating(1..3)
        is_things_one_to_three?(things)
      end
      
      def test_average_rating
        art = AverageRatedThing.create(:name => "Average Thing", :rating => 1)
        total_rating = 1
        total_times = 1
        assert_equal 1, art.rating
        assert_equal 1, art.total_ratings
        5.times do |i|
          total_rating += 5
          total_times += 1
          art.rating = 5
          assert_equal (total_rating/total_times).to_i, art.rating
          assert_equal total_times, art.total_ratings
        end
      end
      
      private
        def is_things_one_to_three?(things)
          assert_equal 3, things.length, "Incorrect Number of Rated Things with rating between 1 and 3"
          names = things.collect {|thing| thing.name}
          assert (names.include?("My Least Favorite") and names.include?("Don't like this thing very much") and names.include?("Take it or leave it")), "Incorrect records returned"
        end
      
  end
end
