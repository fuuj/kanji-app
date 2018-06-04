# kanji-app

https://learn.co/lessons/sinatra-user-auth
> -- The get '/registrations/signup' route has one responsibility: render the sign-up form view. This view can be found in app/views/registrations/signup.erb. Notice we have separate view sub-folders to correspond to the different controller action groupings.

    The post '/registrations' route is responsible for handling the POST request that is sent when a user hits 'submit' on the sign-up form. It will contain code that gets the new user's info from the params hash, creates a new user, signs them in, and then redirects them somewhere else.

    The get '/sessions/login' route is responsible for rendering the login form.

    The post '/sessions' route is responsible for receiving the POST request that gets sent when a user hits 'submit' on the login form. This route contains code that grabs the user's info from the params hash, looks to match that info against the existing entries in the user database, and, if a matching entry is found, signs the user in.

    The get '/sessions/logout' route is responsible for logging the user out by clearing the session hash.

    The get '/users/home' route is responsible for rendering the user's homepage view.
