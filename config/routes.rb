Rails.application.routes.draw do
  get 'quizzes/index'
  get 'quizzes/new'
  get 'quizzes/edit'
  
  resources :quizzes
  
  root "quizzes#index"
end
