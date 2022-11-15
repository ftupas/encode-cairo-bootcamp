%lang starknet

from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_eq
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE

const MINT_ADMIN = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a91;
const TEST_ACC1 = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a95;
const TEST_ACC2 = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b;

from homework_13.contracts.erc20.IERC20 import IErc20 as Erc20

@external
func __setup__() {
    // Deploy contract
    %{
        context.contract_a_address  = deploy_contract("./homework_13/contracts/erc20/shame_coin.cairo", [
               1536286285721987139918, ## name:   SHAMECOIN
               21315,                  ## symbol: SC
               10000000000,            ## initial_supply[1]: 10000000000
               0,                      ## initial_supply[0]: 0
               ids.MINT_ADMIN
               ]).contract_address
    %}
    return ();
}

@external
func test_admin_transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    local contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    // Call as admin
    %{ stop_prank_callable_admin = start_prank(ids.MINT_ADMIN, ids.contract_address) %}

    // Transfer 1 amount as mint owner to TEST_ACC1
    Erc20.transfer(contract_address=contract_address, recipient=TEST_ACC1, amount=Uint256(1, 0));
    %{ stop_prank_callable_admin() %}
    let (balance: Uint256) = Erc20.balanceOf(contract_address=contract_address, account=TEST_ACC1);
    let (is_eq) = uint256_eq(balance, Uint256(1,0));

    // Call as TEST_ACC1, transfers 1 amount to TEST_ACC2
    // TEST_ACC1's balance should increase by 1
    %{ stop_prank_callable_1 = start_prank(ids.TEST_ACC1, ids.contract_address) %}
    Erc20.transfer(contract_address=contract_address, recipient=TEST_ACC2, amount=Uint256(1, 0));
    let (balance: Uint256) = Erc20.balanceOf(contract_address=contract_address, account=TEST_ACC1);
    let (is_eq) = uint256_eq(balance, Uint256(2,0));
    %{ stop_prank_callable_1() %}

    // Attempt to transfer another amount as mint owner to TEST_ACC1
    %{ stop_prank_callable_admin = start_prank(ids.MINT_ADMIN, ids.contract_address) %}
    %{ expect_revert() %}
    Erc20.transfer(contract_address=contract_address, recipient=TEST_ACC2, amount=Uint256(111, 0));
    %{ stop_prank_callable_admin() %}

    return ();
}

@external
func test_faucet{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    tempvar contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    // Call as test_acc1
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1, ids.contract_address) %}

    // Get airdrop under limit
    Erc20.faucet(contract_address=contract_address, amount=Uint256(666, 0));
    %{ stop_prank_callable() %}

    // Call as test_acc2
    %{ stop_prank_callable = start_prank(ids.TEST_ACC2, ids.contract_address) %}

    //# Get airdrop over limit
    %{ expect_revert() %}
    Erc20.faucet(contract_address=contract_address, amount=Uint256(1000000, 0));
    %{ stop_prank_callable() %}

    return ();
}

@external
func test_burn_haircut{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    tempvar contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    let (admin_address) = Erc20.get_admin(contract_address=contract_address);

    // Start admin balance
    let (start_admin_balance) = Erc20.balanceOf(
        contract_address=contract_address, account=MINT_ADMIN
    );

    // Call as test_acc1
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1, ids.contract_address) %}

    // Get airdrop
    Erc20.faucet(contract_address=contract_address, amount=Uint256(666, 0));

    // Start user balance
    let (start_user_balance) = Erc20.balanceOf(
        contract_address=contract_address, account=TEST_ACC1
    );
    %{print("start_user_balance: ",ids.start_user_balance.low)%}

    // Call burn
    Erc20.burn(contract_address=contract_address, amount=Uint256(500, 0));
    %{ stop_prank_callable() %}

    // Final user balance
    let (final_user_balance) = Erc20.balanceOf(
        contract_address=contract_address, account=TEST_ACC1
    );
    %{print("final_user_balance: ",ids.final_user_balance.low)%}

    // Assert user's balance decreased by 500
    let (user_diff) = uint256_sub( start_user_balance, final_user_balance);
    assert user_diff.low = 500;

    // Final admin balance
    let (final_admin_balance) = Erc20.balanceOf(
        contract_address=contract_address, account=MINT_ADMIN
    );

    // Assert admin's balance increased by 50
    let (admin_diff) = uint256_sub(final_admin_balance, start_admin_balance);
    assert admin_diff.low = 50;

    return ();
}

@external
func test_exclusive_faucet{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    tempvar contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    // Start admin balance
    let (start_TEST_ACC1_balance) = Erc20.balanceOf(
        contract_address=contract_address, account=TEST_ACC1
    );

    // Call as test_acc1
    %{ stop_prank_callable = start_prank(ids.TEST_ACC1, ids.contract_address) %}

    // Ensure TEST_ACC1 is not on the whitelist by defualt
    let (allowed) = Erc20.check_whitelist(contract_address=contract_address, account=TEST_ACC1);
    assert allowed = 0;

    // Apply to get on the whitelist
    let (apply) = Erc20.request_whitelist(contract_address=contract_address);
    assert apply = 1;

    // Ensure TEST_ACC1 is now on the whitelist by defualt
    let (allowed) = Erc20.check_whitelist(contract_address=contract_address, account=TEST_ACC1);
    assert allowed = 1;

    // Call exclusive_faucet asking for more than 10,000
    let (allowed) = Erc20.exclusive_faucet(
        contract_address=contract_address, amount=Uint256(200000, 0)
    );
    %{ stop_prank_callable() %}

    // Final User balance
    let (final_TEST_ACC1_balance) = Erc20.balanceOf(
        contract_address=contract_address, account=TEST_ACC1
    );

    // Assert User's balance increased by 200000
    let (acc1_diff) = uint256_sub(final_TEST_ACC1_balance, start_TEST_ACC1_balance);
    assert acc1_diff.low = 200000;

    return ();
}

@external
func test_approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    // Call as admin
    %{ stop_prank_callable_admin = start_prank(ids.MINT_ADMIN, ids.contract_address) %}

    // Transfer 1 amount as mint owner to TEST_ACC1
    Erc20.transfer(contract_address=contract_address, recipient=TEST_ACC1, amount=Uint256(1, 0));
    let (balance: Uint256) = Erc20.balanceOf(contract_address=contract_address, account=TEST_ACC1);
    let (is_eq) = uint256_eq(balance, Uint256(1,0));
    assert is_eq = TRUE;
    %{ stop_prank_callable_admin() %}

    // Call as TEST_ACC1
    %{ stop_prank_callable_1 = start_prank(ids.TEST_ACC1, ids.contract_address) %}
    Erc20.approve(
        contract_address=contract_address,
        spender=MINT_ADMIN,
        amount=Uint256(1,0),
    );

    // Allowance should be 1
    let (allowance: Uint256) = Erc20.allowance(
        contract_address=contract_address,
        owner=TEST_ACC1,
        spender=MINT_ADMIN,
    );
    let (is_eq) = uint256_eq(allowance, Uint256(1,0));
    assert is_eq = TRUE;

    %{ expect_revert(error_message="Can only spend one token") %}
    // Approving more than one token reverts
    Erc20.approve(
        contract_address=contract_address,
        spender=MINT_ADMIN,
        amount=Uint256(2,0),
    );

    %{ stop_prank_callable_1() %}
    return ();
}

@external
func test_transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    local contract_address;
    %{ ids.contract_address = context.contract_a_address %}

    // Call as admin
    %{ stop_prank_callable_admin = start_prank(ids.MINT_ADMIN, ids.contract_address) %}

    // Transfer 1 amount as mint owner to TEST_ACC1
    Erc20.transfer(contract_address=contract_address, recipient=TEST_ACC1, amount=Uint256(1, 0));
    let (balance: Uint256) = Erc20.balanceOf(contract_address=contract_address, account=TEST_ACC1);
    let (is_eq) = uint256_eq(balance, Uint256(1,0));
    assert is_eq = TRUE;
    %{ stop_prank_callable_admin() %}

    // Call as TEST_ACC1, approve one token to send to TEST_ACC2
    %{ stop_prank_callable_1 = start_prank(ids.TEST_ACC1, ids.contract_address) %}
    Erc20.approve(
        contract_address=contract_address,
        spender=MINT_ADMIN,
        amount=Uint256(1,0),
    );
    %{ stop_prank_callable_1() %}

    // Call as admin (spender of token of TEST_ACC1)
    %{ stop_prank_callable_admin = start_prank(ids.MINT_ADMIN, ids.contract_address) %}
    // Transfer one token from TEST_ACC1 to TEST_ACC2
    Erc20.transferFrom(
        contract_address=contract_address,
        sender=TEST_ACC1,
        recipient=TEST_ACC2,
        amount=Uint256(1,0),
    );

    // Check balance change
    let (balance_1: Uint256) = Erc20.balanceOf(contract_address=contract_address, account=TEST_ACC1);
    let (balance_2: Uint256) = Erc20.balanceOf(contract_address=contract_address, account=TEST_ACC2);

    // TEST_ACC1 should have 0
    let (is_eq) = uint256_eq(balance_1, Uint256(0,0));
    assert is_eq = TRUE;

    // TEST_ACC2 should have 1
    let (is_eq) = uint256_eq(balance_2, Uint256(1,0));
    assert is_eq = TRUE;
    %{ stop_prank_callable_admin() %}

    return ();
}
