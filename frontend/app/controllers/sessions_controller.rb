class SessionsController < ApplicationController

    def new
        # placeholder for new.html.erb
    end

    # Locate user via the three known FU user logins
    def create
        account = params[:email]
        user    = User.locate(account)

        if user && user.valid_password?(params[:password])
            session[:user_id] = user.id
            redirect_to root_url, notice: "Logged in!"
        else
            flash.now[:alert] = "Account or password is invalid"
            render "new"
        end
    end

    def signup
        # All required fields included?
        unless ['email', 'password', 'password_confirmation'].all? { |e| params.keys.include? e }
            flash.now[:alert] = 'Missing required input.'
            return new
        end

        user = User.new(
            email: params[:email],
            password: params[:password],
        )

        if user.save
            session[:user_id] = user.id
            return redirect_to root_url
        else
            # TODO: Add errors
        end
    end

    def destroy
        session[:user_id] = @fu_user = nil
        redirect_to root_url, notice: "Logged out!"
    end

end
