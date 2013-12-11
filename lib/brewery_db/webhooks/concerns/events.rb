module BreweryDB
  module Webhooks
    module Events
      def event_insert(events = nil)
        klass     = self.class.to_s.demodulize.underscore
        events  ||= @client.get("/#{klass}/#{@brewerydb_id}/events").body['data']
        events    = Array(events).map { |e| e['event'] }
        event_ids = Array(events).map { |e| e['id'] }
        events    = ::Event.where(brewerydb_id: event_ids)

        if events.count == event_ids.count
          @model.events = events
          @model.save!
        else
          raise OrderingError, "Received a new #{klass} before we had its events!"
        end
      end
      alias :event_delete :event_insert

      # This is a no-op; we get the same information in an Event hook.
      def event_edit
        true
      end
    end
  end
end
