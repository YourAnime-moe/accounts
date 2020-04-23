module ApplicationHelper
  def app_title
    @app_title
  end

  def set_title(before: nil, after: nil)
    @app_title = t('app.title')
    @app_title = "#{before} | #{@app_title}" unless before.nil?
    @app_title << " | #{after}" unless after.nil?
    @app_title
  end
end
