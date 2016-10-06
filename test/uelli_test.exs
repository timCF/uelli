defmodule UelliTest do
	use ExUnit.Case
	doctest Uelli
	require Uelli

	defstruct foo: 123,
						bar: "hello"

	test "tc" do
		assert :qwe == (
			IO.puts("\nhello tc ?")
			Uelli.makestamp |> IO.inspect
			:timer.sleep(1000)
			Uelli.makestamp |> IO.inspect
			:qwe
			) |> Uelli.tc(fn(time) -> IO.puts("hello tc #{time}\n") end)
	end

	test "try_catch" do
		assert 2 == (1+1) |> Uelli.try_catch
		assert :error == (1 / 0) |> Uelli.try_catch |> elem(0)
		assert :error == exit("hello") |> Uelli.try_catch |> elem(0)
	end

	test "retry" do
		assert 1 == Uelli.retry( fn() -> :rand.uniform(25) end , &(&1 == 1) , :infinity )
		assert 2 == Uelli.retry( fn() -> 2 end , &(&1 == 1) , 10 )
	end

	test "destruct" do
		data = %UelliTest{foo: %{qwe: [1, 2, "hello",  %UelliTest{bar: [1, 2, 3]}]}}
		assert %{foo: %{qwe: [1, 2, "hello", %{bar: [1, 2, 3], foo: 123}]}, bar: "hello"} = Uelli.destruct(data)
	end

end
