module ApplicationHelper
  def show_notification(type, content)
    content_tag(:div, content, class: "notification is-#{type}")
  end

  def app_title
    @app_title
  end

  def set_title(before: nil, after: nil)
    @app_title = t('app.title')
    @app_title = "#{before} | #{@app_title}" unless before.nil?
    @app_title << " | #{after}" unless after.nil?
    @app_title
  end

  def domain_for_app(application)
    return unless application.redirect_uri.present?

    regex = %r{([\w\:\/\\.]+)(\/auth\/misete\/callback)\/?}
    application.redirect_uri.match(regex).captures[0]
  end

  def avatar_tag(size: 200, user: nil, no_margin_top: false, **options)
    user ||= current_user

    content_tag :figure, class: "avatar #{'no-margin-top' if no_margin_top}" do
      if user.avatar.attached?
        image_tag(user.avatar.variant(resize_to_limit: [size, size]), **options)
      else
        url = "https://api.adorable.io/avatars/#{size}/#{user.username}.png"
        image_tag(url, alt: user.name, size: size, **options)
      end
    end
  end

  def field_control(&block)
    content_tag :div, class: 'field' do
      content_tag :div, class: 'control' do
        yield block
      end
    end
  end

  def inactive_notification
    return unless logged_in?

    unless current_user.active?
      show_notification(:danger, 'Attention: your account is not active yet.')
    end
  end

  def current_application
    @current_application ||= Connext::Application.find_by(uuid: params[:app_id])
  end

  def application_logo_path
    Rails.configuration.x.hosts[:naka].join('logo.png').to_s
  end
end
