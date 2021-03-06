defmodule ElixirStatus.Router do
  use ElixirStatus.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :assign_current_user
  end

  scope "/", ElixirStatus do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about

    resources "/postings", PostingController
    get "/p/:permalink", PostingController, :show, as: :permalink_posting

    get "/=:uid", ShortLinkController, :show
  end

  scope "/auth", alias: ElixirStatus do
    pipe_through :browser

    get "/", GitHubAuthController, :sign_in
    get "/sign_out", GitHubAuthController, :sign_out
    get "/callback", GitHubAuthController, :callback
  end

  scope "/users", ElixirStatus do
    pipe_through :browser # Use the default browser stack

    get "/", UserController, :index
  end

  # Other scopes may use custom stacks.
  scope "/impression", ElixirStatus do
    pipe_through :api

    post "/", ImpressionController, :create, as: :impression
  end

  # Other scopes may use custom stacks.
  scope "/api", ElixirStatus do
    pipe_through :api

    post "/external", ImpressionController, :external, as: :external
  end

  # Fetch the current user from the session and add it to `conn.assigns`. This
  # will allow you to have access to the current user in your views with
  # `@current_user`.
  defp assign_current_user(conn, _) do
    user_id = get_session(conn, :current_user_id)
    assign(conn, :current_user, ElixirStatus.UserController.find_by_id(user_id))
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirStatus do
  #   pipe_through :api
  # end
end
