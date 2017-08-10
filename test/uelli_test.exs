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

	test "number-macro" do
		assert Uelli.pos_integer(123)
		assert not(Uelli.pos_integer(-123))
		assert not(Uelli.pos_integer(0))

		assert Uelli.pos_number(123)
		assert not(Uelli.pos_number(-123))
		assert not(Uelli.pos_number(0))

		assert Uelli.pos_number(1.1)
		assert not(Uelli.pos_number(-123.1))
		assert not(Uelli.pos_number(0.0))

		assert Uelli.non_neg_integer(123)
		assert not(Uelli.non_neg_integer(-123))
		assert Uelli.non_neg_integer(0)

		assert Uelli.non_neg_number(123)
		assert not(Uelli.non_neg_number(-123))
		assert Uelli.non_neg_number(0)

		assert Uelli.non_neg_number(1.1)
		assert not(Uelli.non_neg_number(-123.1))
		assert Uelli.non_neg_number(0.0)

		assert not(Uelli.pos_integer("foo"))
		assert not(Uelli.pos_number("foo"))
		assert not(Uelli.non_neg_integer("foo"))
		assert not(Uelli.non_neg_number("foo"))
	end

	test "binary-macro" do
		assert (Uelli.non_empty_binary("foo"))
		assert (Uelli.non_empty_binary(<<1, 2, 3>>))
		assert not(Uelli.non_empty_binary(1.23))
		assert not(Uelli.non_empty_binary(123))
		assert not(Uelli.non_empty_binary(:foo))
		assert not(Uelli.non_empty_binary(nil))
		assert Uelli.binary_or_nil(nil)
		assert Uelli.binary_or_nil("foo")
		assert Uelli.binary_or_nil("")
		assert not(Uelli.non_empty_binary(1))
	end

	test "pmap" do
		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 1, 1, &(&1+1))
		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 100, 1, &(&1+1))
		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 1, 100, &(&1+1))
		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 100, 100, &(&1+1))

		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 2, 2, &(&1+1))
		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 100, 2, &(&1+1))
		assert [2,3,4,5,6] == Uelli.pmap([1,2,3,4,5], 2, 100, &(&1+1))
	end

	use Uelli.LazyLogger
	test "lazylogger level warn" do
		assert :ok = Logger.debug("debug #{self |> send(:debug) |> inspect}")
		assert :ok = Logger.info("info #{self |> send(:info) |> inspect}")
		assert :ok = Logger.warn("warn #{self |> send(:warn) |> inspect}")
		assert_receive :warn
		assert :ok = Logger.error("error #{self |> send(:error) |> inspect}")
		assert_receive :error

		assert :ok = Logger.debug("debug #{self |> send(:debug) |> inspect}", [metadata_test: "metadata_debug"])
		assert :ok = Logger.info("info #{self |> send(:info) |> inspect}", [metadata_test: "metadata_info"])
		assert :ok = Logger.warn("warn #{self |> send(:warn) |> inspect}", [metadata_test: "metadata_warn"])
		assert_receive :warn
		assert :ok = Logger.error("error #{self |> send(:error) |> inspect}", [metadata_test: "metadata_error"])
		assert_receive :error

		receive do
			some -> raise("unexpected msg")
		after
			100 -> assert true
		end
	end

end
