class ObjectsController < AuthenticatedUsersController
  get '/objects/:type' do
    type = params[:type].singularize.humanize
    object_class = Tendrl.const_get type
    presenter_class = Object.const_get("#{type}Presenter")
    { params[:type] => presenter_class.list(object_class.all) }.to_json
  end

  get '/objects/:type/:id' do
    type = params[:type].singularize.humanize
    object_class = Tendrl.const_get type
    presenter_class = Object.const_get("#{type}Presenter")
    { params[:type] => presenter_class.list(object_class.single) }.to_json
  end

  get '/objects/:type/:id/:sub_object_type' do
    type = params[:type].singularize.humanize
    sub_object_type = params[:sub_object_type].singularize.humanize
    object_class = Tendrl.const_get type
    sub_object_class = Tendrl.const_get sub_object_type
    list = sub_object_class.public_send "find_all_by_#{type.snake_case}_id"
    presenter_class = Object.const_get("#{sub_object_type}Presenter")
  end
  #post '/objects/:type/:object_id/:flow_name'
end
