# $Id$
# $LastChangedDate$
# $LastChangedRevision$
#
# acts_as_rateable rails plugin
# Allows ActiveRecord models to have associated ratings with their contents, and
# allows you to query based on those ratings.
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

module FortiusOne #:nodoc:
  module Rateable #:nodoc:
    module Helper #:nodoc:
      # Generates stars for an object that acts_as_rateable (or anything that responds_to 'rating')
      #
      # The first argument is anything that responds_to?("rating")
      #
      # Available options:
      #
      # :editable (default: false) : "Activates" the stars and allows a user to click on them to trigger
      #                              an action to update the rating of rateable
      # :max (default: 5) : The maximum number of stars (and therefore the maximum allowable rating) to show
      # :filled_star (default: "*") : The content to use for a filled star 
      #                               (example: if ratable.rating is 3, stars 1-3 will be filled, stars 4 and 5 will be empty) 
      # :empty_star (default: "") : The content to use for an empty star (see above)
      # :filled_class (default: "star_filled") : The CSS class to associate with a filled star's container
      # :empty_class (default: "star_empty") : The CSS class to associate with an empty star's container
      #
      def stars(rateable, opts={})
        options = options_for_stars(opts)
        the_content = String.new
        1.upto(options[:max]) do |i|
          is_filled = rateable.rating >= i
          the_content << content_tag(:span, (is_filled ? options[:filled_star] : options[:empty_star]),
                                     :id => "rateable_#{rateable.id}_star_#{i}",
                                     :class => (is_filled ? options[:filled_class] : options[:empty_class]))
        end
        return the_content
      end
      
      private
      def options_for_stars(opts={})
        {:editable => false,
         :max => 5,
         :filled_star => "*",
         :empty_star => "",
         :filled_class => "star_filled",
         :empty_class => "star_empty"}.merge(opts)
      end
      
    end
  end
end