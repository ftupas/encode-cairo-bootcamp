// Task:
// Develop logic of set balance and get balance methods
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

// OpenZeppelin dependencies
from openzeppelin.access.ownable.library import Ownable

// Define a storage variable.
@storage_var
func balance() -> (res: felt) {
}

// Constructor
@constructor
func constructor{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(owner: felt) {
    initialize(owner);
    return ();
}

// Internal initialize.
func initialize{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}(owner: felt) {
    Ownable.initializer(owner);
    return ();
}

// Returns the owner.
@view
func owner{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}() -> (owner: felt) {
    return Ownable.owner();
}

// Returns the current balance.
@view
func get_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}() -> (res: felt) {
    let (res) = balance.read();
    return (res=res);
}

// Sets the balance to amount.
@external
func set_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}(amount: felt) {
    Ownable.assert_only_owner();
    balance.write(amount);
    return ();
}
