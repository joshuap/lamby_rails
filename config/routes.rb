Rails.application.routes.draw do
  root to: "application#index"
  get "/badgers", to: "application#badgers"
end
