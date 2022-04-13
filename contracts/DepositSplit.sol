// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IDepositSplit.sol";

/**
 * @title DepositSplit Interface
 * @author TricleStaking Inc Team
 */
 contract DepositSplit is IDepositSplit{
    using SafeERC20 for IERC20;
    /* ============ Global Variables ============ */
    DepositSplitConfig[] internal _depositSplits;
    
 
    struct UserBalance {

        mapping(address => DepositedBalance[]) tokenBalance;
        DepositedBalance[] nativeBalance;
    }

    mapping (address => UserBalance) private _userBalance;

    uint16 public constant ONE_AS_FIXED_POINT_3 = 1000;

    /* ============ External Functions ============ */

    /// @inheritdoc IDepositSplit
    function getDepositSplit(uint256 _depositSplitIndex)
        external
        view
        override
        returns (DepositSplitConfig memory)
    {
        return _depositSplits[_depositSplitIndex];
    }

    /// @inheritdoc IDepositSplit
    function getDepositSplits() external view override returns (DepositSplitConfig[] memory) {
        return _depositSplits;
    }

    /// @inheritdoc IDepositSplit
    function setDepositSplits(DepositSplitConfig[] calldata _newDepositSplits) external override        
    {
        uint256 newDepositSplitsLength = _newDepositSplits.length;
        require(newDepositSplitsLength <= type(uint8).max, "DepositSplit/invalid-depositsplits-length");

        // Add and/or update deposit split configs using _newDepositSplits DepositSplitConfig structs array.
        for (uint256 index = 0; index < newDepositSplitsLength; index++) {
            DepositSplitConfig memory split = _newDepositSplits[index];

            // REVERT when setting the canonical burn address.
            require(split.target != address(0), "DepositSplit/invalid-depositsplit-target");
            require(split.period <= type(uint32).max, "DepositSplit/invalid-depositsplit-period");
            // IF the CURRENT depositSplits length is below the NEW depositSplits
            // PUSH the DepositSplit struct to end of the list.
            if (_depositSplits.length <= index) {
                _depositSplits.push(split);
            } else {
                // ELSE update an existing DepositSplit struct with new parameters
                DepositSplitConfig memory currentSplit = _depositSplits[index];

                // IF new DepositSplit DOES NOT match the current DepositSplit
                // WRITE to STORAGE with the new DepositSplit
                if (
                    split.target != currentSplit.target ||
                    split.percentage != currentSplit.percentage ||
                    split.period != currentSplit.period
                ) {
                    _depositSplits[index] = split;
                } else {
                    continue;
                }
            }

            // Emit the added/updated deposit split config.
            emit DepositSplitSet(split.target, split.percentage, split.period, index);
        }

        // Remove old deposit splits configs. Match storage _depositsSplits.length with the passed newDepositSplits.length
        while (_depositSplits.length > newDepositSplitsLength) {
            uint256 _index;
            unchecked {
                _index = _depositSplits.length - 1;
            }
            _depositSplits.pop();
            emit DepositSplitRemoved(_index);
        }

        // Total deposit split do not exceed 100%
        uint256 totalPercentage = _totalDepositSplitPercentageAmount();
        require(totalPercentage <= ONE_AS_FIXED_POINT_3, "DepositSplit/invalid-depositsplit-percentage-total");
    }

    /// @inheritdoc IDepositSplit
    function setDepositSplit(DepositSplitConfig memory _depositSplit, uint8 _depositSplitIndex)
        external
        override    
    {
        require(_depositSplitIndex < _depositSplits.length, "DepositSplit/nonexistent-depositsplit");
        require(_depositSplit.target != address(0), "DepositSplit/invalid-depositsplit-target");
        require(_depositSplit.period <= type(uint32).max, "DepositSplit/invalid-depositsplit-period");

        // Update the deposit split config
        _depositSplits[_depositSplitIndex] = _depositSplit;

        // Total deposit split do not exceed 100%
        uint256 totalPercentage = _totalDepositSplitPercentageAmount();
        require(totalPercentage <= ONE_AS_FIXED_POINT_3, "DepositSplit/invalid-depositsplit-percentage-total");

        // Emit updated deposit split config
        emit DepositSplitSet(
            _depositSplit.target,
            _depositSplit.percentage,
            _depositSplit.period,
            _depositSplitIndex
        );
    }

    function depositERC20(uint256 _amount, address _tokenAddress) external override returns (uint256) {
        
  
        require(_depositSplits.length > 0, "DepositSplit/nonexistent-depositSplits");
        // REVERT when setting the canonical burn address.  
        require(_tokenAddress != address(0), "DepositSplit/invalid-deposit-tokenAddress");
        require(_amount > 0 , "DepositSplit/invalid-deposit-amount");

        _depositERC20(msg.sender, _amount, _tokenAddress);

        emit Deposited(_amount);

        return _amount;
    }

    function deposit(uint256 _amount) external payable override returns (uint256) {
        require(msg.value == _amount, "DepositSplit/deposit-amount-gt-userbalance");
        require(msg.value == _amount, "DepositSplit/deposit-amount-gt-userbalance");
        require(_depositSplits.length > 0, "DepositSplit/nonexistent-depositSplits");

        // REVERT when setting the canonical burn address.  
      
        require(_amount > 0 , "DepositSplit/invalid-deposit-amount");

        _depositEth(msg.sender, _amount);

        emit Deposited(_amount);

        return _amount;
    }
    
      /// @inheritdoc IDepositSplit
    function getDepositTokenBalance( address _tokenAddress) external  override view returns (DepositedBalance[] memory) {
        return _userBalance[msg.sender].tokenBalance[_tokenAddress]; 
    }

    /// @inheritdoc IDepositSplit
    function getDepositNativeTokenBalance() external override view returns (DepositedBalance[] memory) {
        return _userBalance[msg.sender].nativeBalance; 
    }

    /// @inheritdoc IDepositSplit
    function withdrawToken(address _tokenAddress, uint256 _index)external override returns (uint256) {
        
       require(_tokenAddress != address(0), "DepositSplit/invalid-deposit-tokenAddress");

       DepositedBalance[] memory tokenBalance =  _userBalance[msg.sender].tokenBalance[_tokenAddress];
       uint256 _amount =  tokenBalance[_index].amount;
       uint64  _period =   tokenBalance[_index].period;
       require(_currentTime()> _period, "DepositSplit/deposit-period-greater-than-currentTime");
       IERC20(_tokenAddress).transfer(msg.sender, _amount);
       emit withdraw(_amount);
       return _amount;
    }


    /// @inheritdoc IDepositSplit
    function withdrawNativeToken(uint256 _index)external override returns (uint256) {
        
       DepositedBalance[] memory tokenBalance =  _userBalance[msg.sender].nativeBalance;
       uint256 _amount =  tokenBalance[_index].amount;
       uint64  _period =   tokenBalance[_index].period;
       require(_currentTime()> _period, "DepositSplit/deposit-period-greater-than-currentTime");
       payable(msg.sender).transfer(_amount);
       emit withdraw(_amount);
       return _amount;
    }
    /* ============ Internal Functions ============ */

    /**
     * @notice Calculates total deposit split percentage amount.
     * @dev Calculates total DepositSplitConfig percentage(s) amount. Used to check the total does not exceed 100% of award distribution.
     * @return Total deposit split(s) percentage amount
     */
    function _totalDepositSplitPercentageAmount() internal view returns (uint256) {
        uint256 _tempTotalPercentage;
        uint256 depositSplitsLength = _depositSplits.length;

        for (uint256 index = 0; index < depositSplitsLength; index++) {
            _tempTotalPercentage += _depositSplits[index].percentage;
        }

        return _tempTotalPercentage;
    }



    function _depositEth (address _operator,uint256 _amount) internal returns (bool){

        require(msg.value == _amount, "DepositSplit/deposit-amount-gt-userbalance");
  
        uint256 depositSplitsLength = _depositSplits.length;
          for (uint256 index = 0; index < depositSplitsLength; index++) {
            DepositSplitConfig memory split = _depositSplits[index];

            uint256 _splitAmount = (_amount * split.percentage) / 1000;
            address _splitTarget = split.target;
            uint64 _splitPeriod = _currentTime() +  split.period;

             DepositedBalance memory balance = DepositedBalance(_operator, _splitAmount, _splitPeriod);
            _userBalance[_splitTarget].nativeBalance.push(balance);

        }
        return true;
    }

    function _depositERC20 (address _operator, uint256 _amount , address _tokenAddress) internal returns (bool){
        IERC20(_tokenAddress).safeTransferFrom(_operator, address(this), _amount);

        uint256 depositSplitsLength = _depositSplits.length;

        for (uint256 index = 0; index < depositSplitsLength; index++) {
            DepositSplitConfig memory split = _depositSplits[index];

            uint256 _splitAmount = (_amount * split.percentage) / 1000;
            address _splitTarget = split.target;
            uint64 _splitPeriod = _currentTime() +  split.period;

             DepositedBalance memory balance = DepositedBalance(_operator, _splitAmount, _splitPeriod);
            _userBalance[_splitTarget].tokenBalance[_tokenAddress].push(balance);

        }

         return true;
    }

    /**
     * @notice returns the current time.  Used for testing.
     * @return The current time (block.timestamp)
     */
    function _currentTime() internal view virtual returns (uint64) {
        return uint64(block.timestamp);
    }




}
