Goodbrews::Application.routes.draw do
  api vendor_string: 'goodbrews', default_version: 1, path: nil do
    version 1 do
      cache as: 'v1' do
      end
    end
  end

  # BreweryDB won't send the requisite Accept header, so these routes must
  # reside outside of the api-versions DSL.
  namespace :api, path: nil do
    namespace :v1, path: nil do
      namespace :brewery_db do
        resources :webhooks, only: [] do
          collection do
            post 'beer'
            post 'brewery'
            post 'location'
            post 'guild'
            post 'event'
          end
        end
      end
    end
  end
end
