defmodule ThousandIsland.Transport do
  @moduledoc """
  This module describes the behaviour required for Thousand Island to interact 
  with low-level sockets. It is largely internal to Thousand Island, however users
  are free to implement their own versions of this behaviour backed by whatever
  underlying transport they choose. Such a module can be used in Thousand Island
  by passing its name as the `transport_module` option when starting up a server,
  as described in `ThousandIsland`.
  """

  @typedoc "A listener socket used to wait for connections"
  @opaque listener_socket() :: port()

  @typedoc "A socket representing a client connection"
  @opaque socket() :: port()

  @typedoc "Information about an endpoint (either remote ('peer') or local"
  @type socket_info() :: %{address: String.t(), port: :inet.port_number()}

  @typedoc "The direction in which to shutdown a connection in advance of closing it"
  @type way() :: :read | :write | :read_write

  @typedoc "The return value from a recv/3 call"
  @type on_recv() :: {:ok, binary()} | {:error, String.t()}

  @doc """
  Create and return a listener socket bound to the given port and configured per
  the provided options.
  """
  @callback listen(:inet.port_number(), keyword()) :: {:ok, listener_socket()}

  @doc """
  Return the local port number that the given lsitener socket is accepting 
  connections on.
  """
  @callback listen_port(listener_socket()) :: {:ok, :inet.port_number()}

  @doc """
  Wait for a client connection on the given listener socket. This call blocks until
  such a connection arrives, or an error occurs (such as the listener socket being 
  closed).
  """
  @callback accept(listener_socket()) :: {:ok, socket()} | {:error, any()}

  @doc """
  Performs an initial handshake on a new client connection (such as that done
  when negotiating an SSL connection). Transports which do not have such a 
  handshake can simply pass the socket through unchanged.
  """
  @callback handshake(socket()) :: {:ok, socket()} | {:error, any()}

  @doc """
  Transfers ownership of the given socket to the given process. This will always
  be called by the process which currently owns the socket.
  """
  @callback controlling_process(socket(), pid()) :: :ok | {:error, any()}

  @doc """
  Returns available bytes on the given socket. Up to `num_bytes` bytes will be
  returned (0 can be passed in to get the next 'available' bytes, typically the 
  next packet). If insufficient bytes are available, the functino can wait `timeout` 
  milliseconds for data to arrive.
  """
  @callback recv(socket(), num_bytes :: non_neg_integer(), timeout :: timeout()) :: on_recv()

  @doc """
  Sends the given data (specified as a binary or an IO list) on the given socket.
  """
  @callback send(socket(), data :: IO.iodata()) :: :ok | {:error, String.t()}

  @doc """
  Shuts down the socket in the given direction.
  """
  @callback shutdown(socket(), way()) :: :ok

  @doc """
  Closes the given socket.
  """
  @callback close(socket() | listener_socket()) :: :ok

  @doc """
  Returns information in the form of `t:socket_info()` about the local end of the socket.
  """
  @callback local_info(socket()) :: socket_info()

  @doc """
  Returns information in the form of `t:socket_info()` about the remote end of the socket.
  """
  @callback peer_info(socket()) :: socket_info()
end
