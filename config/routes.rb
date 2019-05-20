Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'order_tracking#home'
  post 'order_tracking/order_webhook'
  # post 'order_tracking/track_order'
  match 'order_tracking/track_order', to: 'order_tracking#track_order', via: [:get, :post]
end
