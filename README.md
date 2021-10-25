# Chat

## Overview
Chat is a Phoenix LiveView application for communication. It allows users to create rooms and multiple users to chat in a room. Phoenix Presence is used to show the number of online users joined in a chat room at any point of time.   
It doesn't use browser based session to identify an user. Each window is considered a new user and assigned a random username.

To start your Phoenix Chat server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Multiple users can join to the chat room via the room URL. http://<hostname:port>/<room_id>

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
