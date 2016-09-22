defmodule Uelli do
	use Application

	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false

		# Define workers and child supervisors to be supervised
		children = [
		# Starts a worker by calling: Uelli.Worker.start_link(arg1, arg2, arg3)
		# worker(Uelli.Worker, [arg1, arg2, arg3]),
		]

		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Uelli.Supervisor]
		Supervisor.start_link(children, opts)
	end

	def makestamp do
		{a, b, c} = :os.timestamp
		((a * 1000000000) + (b * 1000) + div(c,1000))
	end

	defmacro tc(body, callback) do
		quote location: :keep do
			{time, res} = :timer.tc(fn() -> unquote(body) end)
			unquote(callback).(time)
			res
		end
	end

	defmacro try_catch(body) do
		quote location: :keep do
			try do
				unquote(body)
			catch
				signal, error -> {:error, {{signal, error}, :erlang.get_stacktrace}}
				error -> {:error, {error, :erlang.get_stacktrace}}
			rescue
				error -> {:error, {error, :erlang.get_stacktrace}}
			end
		end
	end

	def retry(lambda, predicate, limit \\ 100, ttl \\ 100, attempt \\ 0)
	def retry(lambda, predicate, :infinity, ttl, attempt) do
		res = lambda.()
		case predicate.(res) do
			true -> res
			false ->
				:timer.sleep(ttl)
				retry(lambda, predicate, :infinity, ttl, attempt)
		end
	end
	def retry(lambda, _, limit, _, attempt) when (attempt > limit), do: lambda.()
	def retry(lambda, predicate, limit, ttl, attempt) when is_integer(limit) do
		res = lambda.()
		case predicate.(res) do
			true -> res
			false ->
				:timer.sleep(ttl)
				retry(lambda, predicate, limit, ttl, attempt + 1)
		end
	end

end
