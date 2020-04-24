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

  def avatar_tag(size: 200, user: nil, **options)
    user ||= current_user

    content_tag :figure, class: 'avatar' do
      if user.avatar.attached?
        image_tag(user.avatar.variant(resize_to_limit: [size, size]), **options)
      else
        url = "https://api.adorable.io/avatars/#{size}/#{user.username}.png"
        image_tag(url, alt: user.name, size: size, **options)
      end
    end
  end
end
