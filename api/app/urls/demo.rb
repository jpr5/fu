# Demo Example - nuke when you put something real in the server.
# (Mostly) Equivalent to Rails DevController demo.

class Server

    # Sinatra Docs: http://sinatrarb.com/intro.html
    #
    # Helpful shit:
    #
    # halt 402, {'Content-Type' => 'text/plain'}, 'revenge'
    # status 418
    # headers \
    #    "Allow"   => "BREW, POST, GET, PROPFIND, WHEN",
    #    "Refresh" => "Refresh: 20; http://www.ietf.org/rfc/rfc2324.txt"
    # body "I'm a tea pot!"
    # content_type :foo

    get "/" do
        # Test session functionality
        session[:iter] ||= 0
        session[:iter] = @i = session[:iter] + 1

        # Test the flash functionality
        flash[:notice] = :unf if @i % 4 == 0

        # Test the session manip functionality
        if @i == 12
            renew_session
            flash[:notice] = "session renewed"
        end

        reset_session if @i > 24

        erb(:index)
    end

    get "/login" do
        erb(:new_session)
    end

    post "/login" do
        account = params[:email]
        user    = User.locate(account)

        if user && user.valid_password?(params[:password])
            session[:user_id] = user.id
            flash[:notice] = "Logged in!"
            return redirect "/"
        else
            flash.now[:alert] = "Account or password is invalid"
            return erb(:new_session)
        end
    end

    get "/logout" do
        session[:user_id] = @fu_user = nil
        flash[:notice] = "Logged out!"
        return redirect "/"
    end

end
