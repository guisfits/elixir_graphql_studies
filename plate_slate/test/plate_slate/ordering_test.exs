defmodule PlateSlate.OrderingTest do
  use PlateSlate.DataCase

  alias PlateSlate.Ordering

  setup do
    PlateSlate.Data.seed()
  end

  describe "orders" do
    alias PlateSlate.Ordering.Order

    import PlateSlate.OrderingFixtures

    @invalid_attrs %{customer_number: nil, items: nil, ordered_at: nil, state: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Ordering.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Ordering.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      # arrange
      chai = Repo.get_by!(PlateSlate.Menu.Item, name: "Masala Chai")
      fries = Repo.get_by!(PlateSlate.Menu.Item, name: "French Fries")

      attrs = %{
        ordered_at: "2010-04-17 14:00:00.000000Z",
        state: "created",
        items: [
          %{menu_item_id: chai.id, quantity: 1},
          %{menu_item_id: fries.id, quantity: 2}
        ]
      }

      # act
      {:ok, %Order{} = order} = Ordering.create_order(attrs)

      # assert
      expected_items = [
        %{name: "Masala Chai", quantity: 1, price: chai.price},
        %{name: "French Fries", quantity: 2, price: fries.price}
      ]

      assert Enum.map(order.items, &Map.take(&1, [:name, :quantity, :price])) == expected_items
      assert order.state == "created"

      # valid_attrs = %{customer_number: 42, items: %{}, ordered_at: ~U[2022-10-11 21:10:00Z], state: "some state"}

      # assert {:ok, %Order{} = order} = Ordering.create_order(valid_attrs)
      # assert order.customer_number == 42
      # assert order.items == %{}
      # assert order.ordered_at == ~U[2022-10-11 21:10:00Z]
      # assert order.state == "some state"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ordering.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()

      update_attrs = %{
        customer_number: 43,
        items: %{},
        ordered_at: ~U[2022-10-12 21:10:00Z],
        state: "some updated state"
      }

      assert {:ok, %Order{} = order} = Ordering.update_order(order, update_attrs)
      assert order.customer_number == 43
      assert order.items == []
      assert order.ordered_at == ~U[2022-10-12 21:10:00Z]
      assert order.state == "some updated state"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Ordering.update_order(order, @invalid_attrs)
      assert order == Ordering.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Ordering.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Ordering.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Ordering.change_order(order)
    end
  end
end
