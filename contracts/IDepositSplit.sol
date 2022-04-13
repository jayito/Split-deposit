// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
 * @title Abstract deposit split contract for adding unique award distribution to static addresses.
 * @author TricleStaking Inc Team
 */
interface IDepositSplit {

    event Deposited(
      
        uint256 _amount
    );

    event withdraw(
      
        uint256 _amount
    );
   
    /**
     * @notice The deposite split configuration struct.
     * @dev    The deposite split configuration struct used to award deposit splits during distribution.
     * @param target     Address of recipient receiving the deposite split distribution
     * @param percentage Percentage of deposit split using a 0-1000 range for single decimal precision i.e. 125 = 12.5%
     * @param period     Period of depoist locked
     */
    struct DepositSplitConfig {
        address target;
        uint16 percentage;
        uint32 period;
    }

    /**
     * @notice The deposited token Balance struct.
     * @dev    The deposited token Balance struct used to get balance of deposited token.
     * @param sender   Address of depositor deposited token
     * @param amount   Amount of deposited token
     * @param amount   Period of deposited token
     */
    struct DepositedBalance {
        address depositor;
        uint256 amount;
        uint64 period;
    }


    /**
     * @notice Emitted when a DepositSplitConfig config is added or updated.
     * @dev    Emitted when a DepositSplitConfig config is added or updated in setDepositSplits or setDepositSplit.
     * @param target     Address of deposit split recipient
     * @param percentage Percentage of deposit split. Must be between 0 and 1000 for single decimal precision
     * @param index      Index of deposit split in the depositSplts array
     */
    event DepositSplitSet(address indexed target, uint16 percentage, uint64 period, uint256 index);

    /**
     * @notice Emitted when a DepositSplitConfig config is removed.
     * @dev    Emitted when a DepositSplitConfig config is removed from the depositSplits array.
     * @param target Index of a previously active deposit split config
     */
    event DepositSplitRemoved(uint256 indexed target);

    /**
     * @notice Read deposit split config from active DepositSplits.
     * @dev    Read DepositSplitConfig struct from depositSplits array.
     * @param depositSplitIndex Index position of DepositSplitConfig
     * @return DepositSplitConfig Single deposit split config
     */
    function getDepositSplit(uint256 depositSplitIndex) external view returns (DepositSplitConfig memory);

    /**
     * @notice Read all Deposit splits configs.
     * @dev    Read all DepositSplitConfig structs stored in DepositSplits.
     * @return Array of DepositSplitConfig structs
     */
    function getDepositSplits() external view returns (DepositSplitConfig[] memory);

     /**
     * @notice Set and remove deposit split(s) configs. Only callable by owner.
     * @dev Set and remove deposit split configs by passing a new DepositSplitConfig structs array. Will remove existing DepositSplitConfig(s) if passed array length is less than existing depositSplits length.
     * @param newDepositSplits Array of DepositSplitConfig structs
     */
    function setDepositSplits(DepositSplitConfig[] calldata newDepositSplits) external;

    /**
     * @notice Updates a previously set deposit split config.
     * @dev Updates a deposit split config by passing a new DepositSplitConfig struct and current index position. Limited to contract owner.
     * @param depositStrategySplit DepositSplitConfig config struct
     * @param depositSplitIndex Index position of DepositSplitConfig to update
     */
    function setDepositSplit(DepositSplitConfig memory depositStrategySplit, uint8 depositSplitIndex)external;

    function getDepositTokenBalance(address tokenAddress)external returns(DepositedBalance[] memory);

    function getDepositNativeTokenBalance()external returns(DepositedBalance[] memory);
    
    function withdrawToken(address tokenAddress, uint256 index)external returns(uint256);

    function withdrawNativeToken(uint256 index)external returns(uint256);

    function deposit(uint256 amount )external payable returns(uint256);

    function depositERC20(uint256 amount, address tokenAddress)external returns(uint256);
}
