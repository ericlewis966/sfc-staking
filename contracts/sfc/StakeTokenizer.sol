pragma solidity ^0.5.0;

import "./SFC.sol";
import "../erc20/base/ERC20Burnable.sol";
import "../erc20/base/ERC20Mintable.sol";
import "../common/Initializable.sol";

contract Spacer {
    address private _owner;
}

contract StakeTokenizer is Spacer, Initializable {
    SFC internal sfc = SFC(0x1c1cB00000000000000000000000000000000000);
    mapping(address => mapping(uint256 => uint256)) public outstandingSICICB;
    address public sICICBTokenAddress = 0x1C1CB000000000000000000000000000000000c1;

    constructor (address _sICICBTokenAddress ) public {
        sICICBTokenAddress = _sICICBTokenAddress;
    }

    function mintSICICB(uint256 toValidatorID) external {
        address delegator = msg.sender;
        uint256 lockedStake = sfc.getLockedStake(delegator, toValidatorID);
        require(lockedStake > 0, "delegation isn't locked up");
        require(lockedStake > outstandingSICICB[delegator][toValidatorID], "sFTM is already minted");

        uint256 diff = lockedStake - outstandingSICICB[delegator][toValidatorID];
        outstandingSICICB[delegator][toValidatorID] = lockedStake;

        // It's important that we mint after updating outstandingSICICB (protection against Re-Entrancy)
        require(ERC20Mintable(sICICBTokenAddress).mint(delegator, diff), "failed to mint sFTM");
    }

    function redeemSICICB(uint256 validatorID, uint256 amount) external {
        require(outstandingSICICB[msg.sender][validatorID] >= amount, "low outstanding sFTM balance");
        require(IERC20(sICICBTokenAddress).allowance(msg.sender, address(this)) >= amount, "insufficient allowance");
        outstandingSICICB[msg.sender][validatorID] -= amount;

        // It's important that we burn after updating outstandingSICICB (protection against Re-Entrancy)
        ERC20Burnable(sICICBTokenAddress).burnFrom(msg.sender, amount);
    }

    function allowedToWithdrawStake(address sender, uint256 validatorID) public view returns(bool) {
        return outstandingSICICB[sender][validatorID] == 0;
    }
}
