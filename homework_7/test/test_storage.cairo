%lang starknet
from homework_7.contracts.storage.storage import get_balance, set_balance, initialize
from starkware.cairo.common.cairo_builtins import HashBuiltin

const ADMIN  = 1;
const ANYONE = 2;

@external
func test_get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (balance) = get_balance();
    assert 0 = balance;

    return ();
}

@external
func test_set_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {

    // Set ADMIN as owner
    initialize(owner=ADMIN);

    // asserts should pass as caller is owner
    %{ stop_prank_admin = start_prank(ids.ADMIN) %}
    set_balance(42);
    let (balance) = get_balance();
    assert 42 = balance;

    set_balance(-8);
    let (balance) = get_balance();
    assert -8 = balance;
    %{ stop_prank_admin() %}


    // asserts should fail as caller is not owner
    %{ 
        stop_prank_anyone = start_prank(ids.ANYONE)
        expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner")
    %}
    set_balance(69);
    %{ stop_prank_anyone() %}
    return ();
}
