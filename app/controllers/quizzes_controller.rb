class QuizzesController < ApplicationController
  def index
    @course_id = get_course_id
    with_canvas_api do |connec|
      result = connec.get(path: "/api/v1/courses/#{@course_id}/quizzes")
      if result.status == 200
         @quizzes = JSON.parse(result.body)
      else
        @quizzes = []
        result.status = 404
      end   
  end
end

def new;
end








def create
  @course_id = get_course_id

  quiz_data = {
    "enroll_me": true,
    "quiz": {
      "title": params[:title],
      "points_possible": params[:points_possible].to_i,
      "time_limit": params[:time_limit].to_i,
      "due_at": params[:due_at]
    }
  }

  with_canvas_api do |connec|
    result = connec.post(
      path: "/api/v1/courses/#{@course_id}/quizzes",
      body: quiz_data.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    if result.status == 200
      @quiz = JSON.parse(result.body)
      puts "Quiz creado con éxito. ID del quiz: #{@quiz['id']}"
      redirect_to quizzes_path, notice: 'Quiz creado con éxito.'
    else
      puts "Error al crear el quiz. Código de error: #{result.status}"
      redirect_to quizzes_path, alert: 'Error al crear el quiz.'
    end
  end
end



  
  def get_course_id
    course_id = nil
    with_canvas_api do |canvas|
      result = canvas.get(path: '/api/v1/users/self/courses')
      if result.status == 200
        courses = JSON.parse(result.body)
        if courses.any?
          course_id = courses[0]['id']
        else
          result.status = 404
        end
      else
        result.status = 404
      end
    end
    course_id
  end
  
  
  private
  def with_canvas_api
    yield Excon.new(
      CANVAS_CONFIG['api_base'],
      headers: { 'Authorization' => "Bearer #{CANVAS_CONFIG['api_key']}" }
    )
  end
end
