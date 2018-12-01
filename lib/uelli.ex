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

	@doc """
	Loads all accessible modules, and returns list of loaded modules
	"""

	def load_all_modules do
		:code.get_path
		|> Enum.flat_map(fn(dir) ->
			dir
			|> File.ls!
			|> Stream.filter(&(String.ends_with?(&1, ".beam")))
			|> Stream.map(&(Regex.replace(~r/(\.beam)$/, &1, fn(_, _) -> "" end) |> String.to_atom))
			|> Enum.map(fn(module) ->
				module
				|> __MODULE__.ensure_loaded?
				|> case do
					true ->
						:ok
					false ->
						{:module, ^module} =
							"#{dir}/#{module}"
							|> String.to_charlist
							|> :code.load_abs
				end
				module
			end)
		end)
	end

	def ensure_loaded?(module) when is_atom(module) do
		module
		|> Code.ensure_loaded?
	end

	def makestamp do
		{a, b, c} = :os.timestamp
		((a * 1_000_000_000) + (b * 1000) + div(c, 1000))
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
			rescue
				error -> {:error, {error, __STACKTRACE__}}
			catch
				error -> {:error, {error, __STACKTRACE__}}
				signal, error -> {:error, {{signal, error}, __STACKTRACE__}}
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

	def destruct(map = %{}) do
		Map.delete(map, :__struct__)
		|> Enum.reduce(%{}, fn({k, v}, acc = %{}) ->
			Map.put(acc, k, destruct(v))
		end)
	end
	def destruct(lst = [_|_]), do: Enum.map(lst, &destruct/1)
	def destruct(some), do: some

	defmacro non_nil_atom(some) do
		quote do
			((unquote(some) != nil) and is_atom(unquote(some)))
		end
	end

	defmacro pos_integer(some) do
		quote location: :keep do
			(is_integer(unquote(some)) and (unquote(some) > 0))
		end
	end

	defmacro pos_number(some) do
		quote location: :keep do
			(is_number(unquote(some)) and (unquote(some) > 0))
		end
	end

	defmacro non_neg_integer(some) do
		quote location: :keep do
			(is_integer(unquote(some)) and (unquote(some) >= 0))
		end
	end

	defmacro non_neg_number(some) do
		quote location: :keep do
			(is_number(unquote(some)) and (unquote(some) >= 0))
		end
	end

	defmacro non_empty_binary(some) do
		quote location: :keep do
			(is_binary(unquote(some)) and (unquote(some) != ""))
		end
	end

	defmacro binary_or_nil(some) do
		quote location: :keep do
			(is_binary(unquote(some)) or (unquote(some) == nil))
		end
	end

	def pmap(lst, chunk_len, threads_limit, func) when (pos_integer(chunk_len) and pos_integer(threads_limit) and is_function(func, 1)) do
		lst = Enum.to_list(lst)
		lst_len = length(lst)
		case (lst_len / chunk_len) > threads_limit do
			true -> ((lst_len / threads_limit) + 0.5)
			false -> chunk_len
		end
		|> round
		|> pmap_process(lst, func)
	end
	defp pmap_process(chunk_len, lst, func) do
		:rpc.pmap({__MODULE__, :pmap_proxy}, [func], Enum.chunk_every(lst, chunk_len, chunk_len, []))
		|> :lists.concat
	end
	def pmap_proxy(lst, func) when (is_list(lst) and is_function(func, 1)), do: Enum.map(lst, func)

end
