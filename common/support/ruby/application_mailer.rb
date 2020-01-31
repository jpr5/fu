require 'fu/rails/mailer'

class ApplicationMailer < ActionMailer::Base
    include ::FU::Rails::Mailer

    # default from: $ENV['USER'] + "@yourmom.com"
    default from: "dev@yourmom.com"

    layout 'mailer'
end
