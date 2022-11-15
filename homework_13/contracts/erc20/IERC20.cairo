%lang starknet
from starkware.cairo.common.uint256 import Uint256, uint256_sub
@contract_interface
namespace IErc20 {
    func balanceOf(account: felt) -> (res: Uint256) {
    }

    func transfer(recipient: felt, amount: Uint256) -> (success: felt) {
    }

    func burn(amount: Uint256) -> (level_granted: felt) {
    }

    func faucet(amount: Uint256) -> (success: felt) {
    }

    func exclusive_faucet(amount: Uint256) -> (success: felt) {
    }

    func check_whitelist(account: felt) -> (allowed_v: felt) {
    }

    func request_whitelist() -> (level_granted: felt) {
    }

    func get_admin() -> (admin_address: felt) {
    }

    func approve(spender: felt, amount: Uint256) -> (sucess: felt) {
    }

    func transferFrom(sender: felt, recipient: felt, amount: Uint256) -> (success: felt) {
    }

    func allowance(owner: felt, spender: felt) -> (remaining: Uint256) {
    }
}
