/**
 *Submitted for verification at FtmScan.com on 2021-03-10
*/

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract StakersInterface {
  function getStakerID(address addr) external view returns (uint256);
}

contract StakerInfo is Ownable {
  mapping (uint => string) public stakerInfos;

  address internal stakerContractAddress = 0x1c1cB00000000000000000000000000000000000;

  function updateStakerContractAddress(address _stakerContractAddress) external onlyOwner {
    stakerContractAddress = _stakerContractAddress;
  }

  event InfoUpdated(uint256 stakerID);

  function updateInfo(string calldata _configUrl) external {
    StakersInterface stakersInterface = StakersInterface(stakerContractAddress);

    // Get staker ID from staker contract
    uint256 stakerID = stakersInterface.getStakerID(msg.sender);

    // Check if address belongs to a staker
    require(stakerID != 0, "Address does not belong to a staker!");

    // Update config url
    stakerInfos[stakerID] = _configUrl;

    emit InfoUpdated(stakerID);
  }

  function getInfo(uint256 _stakerID) external view returns (string memory) {
    return stakerInfos[_stakerID];
  }
}