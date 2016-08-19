defmodule UelliTest do
	use ExUnit.Case
	doctest Uelli
	require Uelli

	test "tc" do
		assert :qwe == (
			IO.puts("\nhello tc ?")
			:timer.sleep(1000)
			:qwe
			) |> Uelli.tc(fn(time) -> IO.puts("hello tc #{time}\n") end)
	end

	test "try_catch" do
		assert 2 == (1+1) |> Uelli.try_catch
		assert :error == (1 / 0) |> Uelli.try_catch |> elem(0)
	end

	test "retry" do
		assert 1 == Uelli.retry( fn() -> :rand.uniform(25) end , &(&1 == 1) , :infinity )
		assert 2 == Uelli.retry( fn() -> 2 end , &(&1 == 1) , 10 )
	end

end
