// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title SanctionedToken
 * @dev Implementation of a basic ERC20 token with sanctions,
 * preventing banned addresses from sending and receiving tokens.
 * Only the owner can ban and unban addresses.
 */
contract SanctionedToken is ERC20, Ownable2Step {

    /// @notice A mapping to track banned addresses.
    mapping(address => bool) private _bannedAddresses;

    /// @notice Event emitted when an address is banned.
    event AddressBanned(address indexed account);

    /// @notice Event emitted when an address is unbanned.
    event AddressUnbanned(address indexed account);

    /**
     * @dev Initializes the token with an initial supply given to the owner.
     * @param initialSupply Address of the initial owner.
     */
    constructor(uint256 initialSupply) ERC20("SanctionedToken", "SNT") {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Bans an address, preventing it from sending and receiving tokens.
     * Can only be called by the owner.
     * @param account Address to be banned.
     */
    function banAddress(address account) external onlyOwner {
        _bannedAddresses[account] = true;
        emit AddressBanned(account);
    }

    /**
     * @dev Unbans an address, allowing it to send and receive tokens.
     * Can only be called by the owner.
     * @param account Address to be unbanned.
     */
    function unbanAddress(address account) external onlyOwner {
        _bannedAddresses[account] = false;
        emit AddressUnbanned(account);
    }

    /**
     * @dev Returns true if the address is banned.
     * @param account Address to check.
     */
    function isBanned(address account) external view returns (bool) {
        return _bannedAddresses[account];
    }

    /**
     * @dev Override OpenZeppelin's _beforeTokenTransfer hook to implement the sanctions functionality.
     * @param from Sender of the tokens.
     * @param to Receiver of the tokens.
     * @param amount Amount of tokens being transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!_bannedAddresses[from], "Token transfer from banned address denied");
        require(!_bannedAddresses[to], "Token transfer to banned address denied");
    }
}
