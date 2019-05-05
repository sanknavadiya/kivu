Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'order_tracking#home'
  post 'order_tracking/order_webhook'
  post 'order_tracking/track_order'
  # match 'order_tracking/order_webhook', to: 'order_tracking#order_webhook', via: :all
end
