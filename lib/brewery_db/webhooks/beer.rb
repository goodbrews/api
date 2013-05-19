module BreweryDB
  module Webhooks
    class Beer < Base
      def process
        self.send(@action)
      end

      private
        def insert

        end

        def edit
          return self.send(@sub_action) if @sub_action
        end

        def delete
          ::Beer.find_by(brewerydb_id: @brewerydb_id).destroy!
        end

        def brewery_insert

        end

        def brewery_delete

        end

        def brewery_edit

        end

        def event_insert

        end

        def event_delete

        end

        def event_edit

        end

        def ingredient_insert

        end

        def ingredient_delete

        end

        def socialaccount_insert

        end

        def socialaccount_delete

        end

        def socialaccount_edit

        end
    end
  end
end
