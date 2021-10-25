# Chat

## Overview
Chat is a Phoenix LiveView application for communication. It allows users to create rooms and multiple users to chat in a room. Phoenix Presence is used to show the number of online users joined in a chat room at any point of time.   
It doesn't use browser based session to identify an user. Each window is considered a new user and assigned a random username.

## Containerization
Dockerfile is provided for containerization.

## Cluster Formation
When the chat app is deployed (refer k8s.yaml file) as a multi-replica application, each of the app replica must be aware of the other replica present. [libcluster](https://github.com/bitwalker/libcluster) library is used to automatically create cluster of elixir replicas that are aware of the other one. A sample cluster formation using k8s is provided as part of the repo
## Distributed Registry and Supervisor

In order for the supervisor to be able to supervise processes across the dynamic cluster and monitor them, a distributed dynamic supervisor (Horde Supervisor) is used along with a distributed process registry (Horde Registry)

## Distributed State Management and State Handoff
In a distributed deployment, nodes could be transient. Since the applications run inside nodes, they could be transient too. The state of the chat rooms (messages) are maintained in-memory and a handoff is done when a replica containing the state goes down because of node shutdown. Conflict-free Replicated Data Type (CRDTs) are used for replicating and distributing data across the available replicas.

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


## References
  * libcluster - https://github.com/bitwalker/libcluster
  * horde - https://github.com/derekkraan/horde
  * DeltaCRDT - https://github.com/derekkraan/delta_crdt_ex
  * Talk by Daniel Azuma - https://www.youtube.com/watch?v=nLApFANtkHs
